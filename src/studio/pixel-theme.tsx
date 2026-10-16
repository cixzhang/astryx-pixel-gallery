/**
 * pixel theme — a pure defineTheme factory parameterised by the pixel
 * unit P (in CSS px) and a retro colour palette. Everything snaps to P:
 *
 *  - Type: Silkscreen's design pixel is size/8 (measured from the font
 *    file, glyph-coordinate GCD). It point-samples perfectly only when
 *    its design pixel equals the cell, so every text size is a multiple
 *    of 8P: body/label/supporting/headings/code at 8P, display and
 *    heading-1 at 16P, display-1 at 24P. Hierarchy comes from weight,
 *    colour and spacing — not from off-grid sizes. (Experiments round 6:
 *    one step off the multiple and the font/sampling grids beat and
 *    text disintegrates.) Code uses Silkscreen too — Pixelify Sans was
 *    tried and rejected on looks (2026-10-16).
 *  - Leading: size + 2P, always a multiple of P (grid-locked baselines).
 *  - Spacing scale snapped to multiples of P; border width = P; element
 *    heights snapped; hard offset shadows; steps() easing.
 *  - Corners: stepped clip-paths (pixel radius) replace arcs across the
 *    component set — boxes get a 2-step staircase, small controls a
 *    1-step, and round things (circle avatars, status dots, step
 *    indicators) get a staircase pixel-circle.
 *  - Colour: each palette seeds Astryx's HCT generator (accent +
 *    neutralStyle) and pins the surface/text tokens to the source
 *    palette's own colours in both schemes.
 *
 * The companion GL display pipeline (drawElement texture + point
 * sampling) is an app-level concern; this theme makes the DOM worth
 * sampling. P should equal the app's sprite pixel scale (Forest: P=2).
 */
import {defineTheme} from '@astryxdesign/core/theme';
import {
  pixelIcons,
  PixelCheckboxIndicator,
  PixelCheckIndicator,
  PixelRadioIndicator,
} from './pixel-icons.tsx';

const snap = (v: number, p: number) => Math.round(v / p) * p;

/** Stepped corner: 2 steps of P per corner (experiments round 1, T5). */
const pixelCorner = [
  'polygon(',
  'calc(var(--pixel) * 2) 0,',
  'calc(100% - var(--pixel) * 2) 0,',
  'calc(100% - var(--pixel) * 2) var(--pixel),',
  'calc(100% - var(--pixel)) var(--pixel),',
  'calc(100% - var(--pixel)) calc(var(--pixel) * 2),',
  '100% calc(var(--pixel) * 2),',
  '100% calc(100% - var(--pixel) * 2),',
  'calc(100% - var(--pixel)) calc(100% - var(--pixel) * 2),',
  'calc(100% - var(--pixel)) calc(100% - var(--pixel)),',
  'calc(100% - var(--pixel) * 2) calc(100% - var(--pixel)),',
  'calc(100% - var(--pixel) * 2) 100%,',
  'calc(var(--pixel) * 2) 100%,',
  'calc(var(--pixel) * 2) calc(100% - var(--pixel)),',
  'var(--pixel) calc(100% - var(--pixel)),',
  'var(--pixel) calc(100% - var(--pixel) * 2),',
  '0 calc(100% - var(--pixel) * 2),',
  '0 calc(var(--pixel) * 2),',
  'var(--pixel) calc(var(--pixel) * 2),',
  'var(--pixel) var(--pixel),',
  'calc(var(--pixel) * 2) var(--pixel))',
].join(' ');

/** Stepped corner for small controls: 1 step of P per corner. */
const pixelCornerSm = [
  'polygon(',
  'var(--pixel) 0,',
  'calc(100% - var(--pixel)) 0,',
  'calc(100% - var(--pixel)) var(--pixel),',
  '100% var(--pixel),',
  '100% calc(100% - var(--pixel)),',
  'calc(100% - var(--pixel)) calc(100% - var(--pixel)),',
  'calc(100% - var(--pixel)) 100%,',
  'var(--pixel) 100%,',
  'var(--pixel) calc(100% - var(--pixel)),',
  '0 calc(100% - var(--pixel)),',
  '0 var(--pixel),',
  'var(--pixel) var(--pixel))',
].join(' ');

/**
 * Pixel circle: a staircase approximation of a circle, 3 steps per
 * quadrant in eighths. At 48px and P=3 the steps land on 2P multiples;
 * at other sizes it stays proportional and reads as a pixel circle.
 */
const pixelCircle = [
  'polygon(',
  '37.5% 0, 62.5% 0,',
  '62.5% 12.5%, 87.5% 12.5%,',
  '87.5% 37.5%, 100% 37.5%,',
  '100% 62.5%, 87.5% 62.5%,',
  '87.5% 87.5%, 62.5% 87.5%,',
  '62.5% 100%, 37.5% 100%,',
  '37.5% 87.5%, 12.5% 87.5%,',
  '12.5% 62.5%, 0 62.5%,',
  '0 37.5%, 12.5% 37.5%,',
  '12.5% 12.5%, 37.5% 12.5%)',
].join(' ');

// ────────────────────────────────────────────────────────────────────
// Retro palettes. Each one seeds the Astryx HCT palette generator via
// `color` (accent per scheme + neutral temperature) and pins the
// surface / text tokens to the source palette's own colours, so the
// generated ramps harmonise with authentic flats.
// ────────────────────────────────────────────────────────────────────
type PaletteDef = {
  accent: [string, string];
  neutralStyle: 'warm' | 'cool' | 'neutral';
  tokens: Record<string, string | [string, string]>;
};

const surfaces = (
  body: [string, string],
  surface: [string, string],
  text: [string, string],
): Record<string, string | [string, string]> => ({
  '--color-background-body': body,
  '--color-background-surface': surface,
  '--color-background-card': surface,
  '--color-background-popover': surface,
  '--color-text-primary': text,
});

export const PIXEL_PALETTES = {
  garden: {
    accent: ['#3E8948', '#5FAE6B'],
    neutralStyle: 'warm',
    tokens: surfaces(['#F4ECD8', '#131E13'], ['#FFFDF4', '#1E2B1E'], ['#22301F', '#F4ECD8']),
  },
  gameboy: {
    // DMG four greens: #0F380F · #306230 · #8BAC0F · #9BBC0F
    accent: ['#306230', '#8BAC0F'],
    neutralStyle: 'warm',
    tokens: surfaces(['#9BBC0F', '#0F380F'], ['#8BAC0F', '#306230'], ['#0F380F', '#9BBC0F']),
  },
  nes: {
    // NES: blue #0078F8 / sky #3CBCFC, paper #FCFCFC, ink near-black
    accent: ['#0078F8', '#3CBCFC'],
    neutralStyle: 'cool',
    tokens: surfaces(['#FCFCFC', '#0B0B1E'], ['#FFFFFF', '#181830'], ['#101018', '#FCFCFC']),
  },
  c64: {
    // C64 (pepto): blues #0000AA / #352879, light cyan #AAFFEE, yellow #EEEE77
    accent: ['#0000AA', '#EEEE77'],
    neutralStyle: 'cool',
    tokens: surfaces(['#C9C2F5', '#0000AA'], ['#E4E0FA', '#352879'], ['#0000AA', '#AAFFEE']),
  },
  pico8: {
    // PICO-8: ink #1D2B53, paper #FFF1E8, red #FF004D, pink #FF77A8
    accent: ['#FF004D', '#FF77A8'],
    neutralStyle: 'warm',
    tokens: surfaces(['#FFF1E8', '#1D2B53'], ['#FFFBF4', '#27355F'], ['#1D2B53', '#FFF1E8']),
  },
} as const satisfies Record<string, PaletteDef>;

export type PixelPaletteName = keyof typeof PIXEL_PALETTES;

export function createPixelTheme(pixel = 3, paletteName: PixelPaletteName = 'garden') {
  const P = pixel;
  const palette = PIXEL_PALETTES[paletteName];
  const body = 8 * P;
  const display = 16 * P;
  const hero = 24 * P;
  const leading = (size: number) => (size + 2 * P) / size;
  const ring = `inset 0 0 0 ${P}px var(--color-border-emphasized)`;
  // borderRadius MUST be 0: the inset ring shadow takes its shape from
  // the element's border-radius, so a leftover radius token draws a
  // rounded inner edge inside the stepped clip (the "inner radius"
  // bug). At radius 0 the ring is a square frame and the clip-path
  // notches it into a stepped ring of uniform P thickness.
  const box = {clipPath: pixelCorner, borderWidth: '0px', borderRadius: '0px', boxShadow: ring};

  const fontSizeSteps: Record<string, number> = {
    '4xs': 6, '3xs': 7, '2xs': 8, xs: 10, sm: 12, base: 14,
    lg: 17, xl: 20, '2xl': 24, '3xl': 29, '4xl': 35, '5xl': 42,
  };
  const fontTokens: Record<string, string> = {};
  for (const [k, v] of Object.entries(fontSizeSteps)) {
    fontTokens[`--font-size-${k}`] = `${v <= body ? body : v <= display ? display : hero}px`;
  }

  const spacingSteps: Record<string, number> = {
    '0': 0, '0-5': 2, '1': 4, '1-5': 6, '2': 8, '3': 12, '4': 16,
    '5': 20, '6': 24, '7': 28, '8': 32, '9': 36, '10': 40, '11': 44, '12': 48,
  };
  const spacingTokens: Record<string, string> = {};
  for (const [k, v] of Object.entries(spacingSteps)) {
    spacingTokens[`--spacing-${k}`] = `${snap(v, P)}px`;
  }

  const textTokens: Record<string, string> = {};
  const assignText = (name: string, size: number, weight?: string) => {
    textTokens[`--text-${name}-size`] = `${size}px`;
    textTokens[`--text-${name}-leading`] = `${leading(size)}`;
    if (weight) textTokens[`--text-${name}-weight`] = weight;
  };
  assignText('display-1', hero, 'bold');
  assignText('display-2', display, 'bold');
  assignText('display-3', display, 'bold');
  assignText('heading-1', display, 'bold');
  assignText('heading-2', body, 'bold');
  assignText('heading-3', body, 'bold');
  assignText('heading-4', body, 'bold');
  assignText('heading-5', body, 'bold');
  assignText('heading-6', body, 'bold');
  assignText('body', body);
  assignText('large', body);
  assignText('label', body, 'bold');
  assignText('supporting', body);
  assignText('code', body);

  return defineTheme({
    name: 'pixel',
    color: {accent: palette.accent, neutralStyle: palette.neutralStyle, contrast: 'standard'},
    typography: {
      scale: {base: body, ratio: 2},
      body: {family: 'Silkscreen', fallbacks: 'monospace'},
      heading: {family: 'Silkscreen', fallbacks: 'monospace', weight: 'bold'},
      code: {family: 'Silkscreen', fallbacks: 'monospace'},
    },
    radius: {base: P, multiplier: 1},
    motion: {fast: 120, medium: 240, slow: 360, ratio: 0.5},
    localTokens: {
      '--pixel': `${P}px`,
    },
    tokens: {
      '--border-width': `${P}px`,
      '--size-element-sm': `${snap(28, P)}px`,
      '--size-element-md': `${snap(32, P)}px`,
      '--size-element-lg': `${snap(36, P)}px`,
      '--focus-outline-width': `${P}px`,
      '--focus-outline-offset': `${P}px`,
      '--radius-page': `${4 * P}px`,
      '--radius-chat': `${4 * P}px`,
      '--shadow-low': `${P}px ${P}px 0 0 light-dark(rgba(34,48,31,0.25), rgba(0,0,0,0.5))`,
      '--shadow-med': `${2 * P}px ${2 * P}px 0 0 light-dark(rgba(34,48,31,0.25), rgba(0,0,0,0.5))`,
      '--shadow-high': `${3 * P}px ${3 * P}px 0 0 light-dark(rgba(34,48,31,0.3), rgba(0,0,0,0.55))`,
      '--ease-standard': 'steps(3, end)',
      ...palette.tokens,
      ...fontTokens,
      ...spacingTokens,
      ...textTokens,
    },
    // Pixel glyphs for every semantic icon name (12x12 matrices,
    // src/studio/pixel-icons.tsx) and pixel selection indicators:
    // stepped radio ring + dot, stepped checkbox + check.
    icons: pixelIcons,
    indicators: {
      radio: PixelRadioIndicator,
      checkbox: PixelCheckboxIndicator,
      check: PixelCheckIndicator,
    },
    components: {
      // ── Containers & actions (covered from the start) ──
      card: {base: {...box, padding: 'var(--spacing-6)'}},
      'selectable-card': {base: {...box}},
      'clickable-card': {base: {...box}},
      button: {base: {...box}},
      'toggle-button': {base: {...box}},
      badge: {
        base: {
          ...box,
          // Badge hard-sets height: var(--spacing-5); at 8P text the
          // theme must give it the height it needs (gallery finding).
          padding: `${P}px ${3 * P}px`,
          lineHeight: '1',
          height: `${body + 2 * P}px`,
        },
      },
      avatar: {
        // Circle avatars pixelate too: staircase pixel-circle.
        'shape:circle': {clipPath: pixelCircle, borderRadius: '0px'},
        'shape:rounded': {clipPath: pixelCorner, borderRadius: '0px'},
      },
      // ── Inputs ──
      'text-input': {base: {...box}},
      'text-area': {base: {...box}},
      'number-input': {base: {...box}},
      'date-input': {base: {...box}},
      'time-input': {base: {...box}},
      'date-time-input': {base: {...box}},
      selector: {base: {...box}},
      'selector-popup': {base: {...box}},
      'selector-option': {base: {borderRadius: '0px'}},
      // ── Controls ──
      switch: {base: {clipPath: pixelCornerSm, borderRadius: '0px'}},
      'switch-thumb': {base: {borderRadius: '0px'}},
      'checkbox-indicator': {base: {clipPath: pixelCornerSm, borderRadius: '0px'}},
      'slider-track': {base: {borderRadius: '0px', height: `${P}px`}},
      'slider-thumb': {base: {clipPath: pixelCornerSm, borderRadius: '0px'}},
      'progress-bar-track': {base: {borderRadius: '0px', height: `${2 * P}px`}},
      'progress-bar-fill': {base: {borderRadius: '0px'}},
      'step-indicator': {base: {clipPath: pixelCircle, borderRadius: '0px'}},
      // ── Overlays & surfaces ──
      dialog: {base: {...box}},
      'alert-dialog': {base: {...box}},
      'bottom-sheet': {base: {clipPath: pixelCorner, borderRadius: '0px'}},
      'popover-surface': {base: {...box}},
      'hover-card': {base: {...box}},
      tooltip: {base: {clipPath: pixelCornerSm, borderRadius: '0px'}},
      toast: {base: {...box}},
      banner: {base: {...box}},
      'dropdown-menu': {base: {...box}},
      'dropdown-menu-item': {base: {borderRadius: '0px'}},
      'context-menu': {base: {...box}},
      'code-block': {base: {...box}},
      thumbnail: {base: {clipPath: pixelCorner, borderRadius: '0px'}},
      // ── Navigation & misc ──
      tab: {base: {borderRadius: '0px'}},
      'tab-indicator': {base: {borderRadius: '0px', height: `${P}px`}},
      'segmented-control': {base: {...box}},
      'segmented-control-item': {base: {borderRadius: '0px'}},
      'calendar-day': {base: {clipPath: pixelCornerSm, borderRadius: '0px'}},
      token: {base: {clipPath: pixelCornerSm, borderRadius: '0px'}},
      kbd: {base: {clipPath: pixelCornerSm, borderRadius: '0px'}},
      skeleton: {base: {borderRadius: '0px'}},
      'status-dot': {base: {clipPath: pixelCircle, borderRadius: '0px'}},
      'pagination-dot': {base: {clipPath: pixelCircle, borderRadius: '0px'}},
    },
  });
}

export const pixelTheme = createPixelTheme(3);
