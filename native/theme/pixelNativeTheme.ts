/**
 * The pixel theme as a native theme (SPIKE).
 *
 * `pixelNativeTheme` type-checks against `defineNativeTheme` exactly as it is
 * on facebook/astryx main (vendored in ../vendor/astryx-native). It is what a
 * person can write today.
 *
 * `pixelNativeThemeProposed` adds the members the pixel look needs that the
 * vocabulary does not have yet. They are typed in ./proposedVocabulary.ts and
 * are proposals, not Astryx API.
 */
import {defineNativeTheme} from '../vendor/astryx-native/theme/defineNativeTheme.ts';
import {pixelTheme} from '../../src/studio/pixel-theme.tsx';
import {defineNativeThemeProposed} from './proposedVocabulary.ts';

/** Web-only parts of the theme that defineNativeTheme reports (FR18). */
export const webPartReports: string[] = [];
const onReport = (message: string) => webPartReports.push(message);

/**
 * Component overrides for swift-ios-1's theme targets. The values are token
 * names, so they follow the theme's light and dark values. The target and
 * member names are not a published vocabulary yet (see gap G-targets).
 */
const pixelSurfaces = {
  // Web: every box gets a P-wide ring in color-border-emphasized.
  button: {borderColor: 'color-border-emphasized', borderWidth: 'border-width'},
  'text-input': {borderColor: 'color-border-emphasized', borderWidth: 'border-width'},
  // Web cards and banners use the same 2-step corner as buttons, and the
  // theme's card padding is spacing-6.
  card: {
    cornerRadius: 'radius-element',
    borderColor: 'color-border-emphasized',
    borderWidth: 'border-width',
    padding: 'spacing-6',
  },
  banner: {
    cornerRadius: 'radius-element',
    borderColor: 'color-border-emphasized',
    borderWidth: 'border-width',
  },
} as const;

export const pixelNativeTheme = defineNativeTheme(
  pixelTheme,
  {
    // Pixel surfaces are flat colour: never glass or blur, on any OS version.
    material: 'opaque',
    platforms: {
      ios: [
        {
          components: pixelSurfaces,
          // Closest to pixel art that SF Symbols offers today: square, not
          // round, status glyphs. Still smooth vector art (gap G-icons).
          icons: {
            info: {systemName: 'info.square.fill'},
            error: {systemName: 'xmark.square.fill'},
            success: {systemName: 'checkmark.square.fill'},
            warning: {systemName: 'exclamationmark.triangle.fill'},
            close: {systemName: 'xmark'},
            check: {systemName: 'checkmark'},
          },
        },
      ],
    },
  },
  {onReport},
);

/** Asset-catalog names the app ships, one per pixel icon (12x12 matrices). */
const pixelIconAssets = Object.fromEntries(
  [
    'close', 'chevronDown', 'chevronLeft', 'chevronRight', 'chevronsLeft', 'chevronsRight',
    'check', 'success', 'error', 'warning', 'info', 'calendar', 'clock', 'externalLink',
    'menu', 'moreHorizontal', 'search', 'arrowUp', 'arrowDown', 'arrowsUpDown', 'funnel',
    'eyeSlash', 'viewColumns', 'copy', 'checkDouble', 'wrench', 'stop', 'microphone',
  ].map(name => [name, {assetName: `pixel.${name}`}]),
);

export const pixelNativeThemeProposed = defineNativeThemeProposed(
  pixelTheme,
  {
    material: 'opaque',
    // PROPOSED durable members: outcomes a person sees, no platform terms.
    corners: 'stepped',
    imageScaling: 'pixelated',
    textGrid: 8,
    platforms: {
      ios: [
        {
          components: pixelSurfaces,
          // PROPOSED platform icon form: an image the app ships in its asset
          // catalog, referenced by name as data.
          icons: pixelIconAssets,
        },
      ],
    },
  },
  {onReport: () => {}},
);
