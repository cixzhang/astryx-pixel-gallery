/**
 * PROPOSED native theme vocabulary (SPIKE). Nothing here is Astryx API.
 *
 * Each addition is plain data, durable intent first (AST-082 DEC-5), with
 * platform terms only inside `platforms.ios`. The runtime reuses main's
 * defineNativeTheme for validation and web-part reports, then resolves the
 * proposed members the same way main resolves `material`.
 */
import {
  defineNativeTheme,
  resolveNativeTheme,
  type DefineNativeThemeOptions,
  type NativeThemeConfig,
  type PlatformEntry,
  type PlatformIcon,
  type PortableThemeLike,
  type ResolvedNativeTheme,
} from '../vendor/astryx-native/theme/defineNativeTheme.ts';
import type {NativePlatform} from '../vendor/astryx-native/platforms.ts';

/** P1. How surface corners are drawn. */
export type DurableCorners =
  /** The platform's own rounded corner at the radius token (today's look). */
  | 'smooth'
  /**
   * A staircase: square steps the size of `border-width`, as many as fit in
   * the surface's radius token. Borders follow the same steps.
   */
  | 'stepped';

/** P2. How raster images scale up. */
export type DurableImageScaling =
  /** Filtered (today's look). */
  | 'smooth'
  /** Nearest-neighbour: each source pixel stays a hard-edged square. */
  | 'pixelated';

export interface ProposedDurableIntent {
  readonly corners?: DurableCorners;
  readonly imageScaling?: DurableImageScaling;
  /**
   * P3. The typeface's design grid in units per em (Silkscreen: 8). Text sizes,
   * including Dynamic Type growth, snap so one design unit covers a whole
   * number of device pixels, which keeps pixel type crisp at every text size.
   * Omitted: sizes scale continuously (today's behaviour).
   */
  readonly textGrid?: number;
}

/** P4. An image the app ships in its asset catalog (or Android resources). */
export type ProposedPlatformIcon = PlatformIcon | {readonly assetName: string};

export type ProposedPlatformEntry<P extends NativePlatform> = Omit<
  PlatformEntry<P>,
  'icons'
> & {
  readonly icons?: Readonly<Record<string, ProposedPlatformIcon>>;
};

export interface ProposedNativeThemeConfig
  extends Omit<NativeThemeConfig, 'platforms'>,
    ProposedDurableIntent {
  readonly platforms?: {
    readonly [P in NativePlatform]?: ReadonlyArray<ProposedPlatformEntry<P>>;
  };
}

export interface ProposedNativeTheme {
  readonly theme: PortableThemeLike;
  readonly config: ProposedNativeThemeConfig;
}

export function defineNativeThemeProposed(
  theme: PortableThemeLike,
  config: ProposedNativeThemeConfig,
  options: DefineNativeThemeOptions = {},
): ProposedNativeTheme {
  // Main's validation and reports run unchanged on the shared members.
  const base = defineNativeTheme(theme, config as NativeThemeConfig, options);
  return {theme: base.theme, config};
}

export interface ResolvedProposedNativeTheme
  extends Omit<ResolvedNativeTheme, 'icons'>,
    ProposedDurableIntent {
  readonly icons: Readonly<Record<string, ProposedPlatformIcon>>;
}

export function resolveNativeThemeProposed(
  nativeTheme: ProposedNativeTheme,
  target: {readonly platform: NativePlatform; readonly osVersion: string},
): ResolvedProposedNativeTheme {
  const resolved = resolveNativeTheme(
    nativeTheme as unknown as Parameters<typeof resolveNativeTheme>[0],
    target,
  ) as unknown as ResolvedProposedNativeTheme;
  const {corners, imageScaling, textGrid} = nativeTheme.config;
  return {
    ...(corners ? {corners} : {}),
    ...(imageScaling ? {imageScaling} : {}),
    ...(textGrid ? {textGrid} : {}),
    ...resolved,
  };
}
