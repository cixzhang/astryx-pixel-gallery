# Leakage log — pixel theme

The rule for this project: the theme is **pure `defineTheme` config**
(`src/studio/pixel-theme.tsx`, built by `astryx theme build`). Anything the
pixel look needs that `defineTheme` cannot express goes here instead of
into a sidecar CSS file. No `*-custom.css` exists in this project.
The theme became a `.tsx` on 2026-10-16 to use defineTheme's first-class
`icons` and `indicators` fields (React values) — still config, no
sidecar code in components.

## What defineTheme expressed fine (not leakage)

- Type scale snapped to the font's design grid (Silkscreen sizes 8P/16P/24P
  via `--text-*-size`), grid-locked leadings (`--text-*-leading`).
- Whole spacing scale snapped to multiples of P (`--spacing-*` tokens).
- Border width = P, element heights snapped, focus outline width/offset = P.
- Radius scale from `radius: {base: P}`.
- **Pixel radius**: stepped `clip-path` corners + inset `box-shadow` ring
  survived `astryx theme build` in component overrides for card, button,
  badge, and avatar (`shape:rounded`). Verified in the generated
  `src/studio/pixel.css`.
- **Text dilation** (round 5's legibility fix): `-webkit-text-stroke`
  survived component overrides (`text`, `type:code`).
- Hard offset shadows (zero blur, P offsets) via `--shadow-*` tokens.
- Stepped motion via `--ease-standard: steps(3, end)`.
- Curated palette pinned via semantic color tokens; accent seeded in HCT.

## Found in the gallery and fixed inside the theme (not leakage)

- **Badge height.** Badge hard-sets `height: var(--spacing-5)` in an
  atomic StyleX class and sizes its text from `--text-supporting-*`;
  at 8P text the default height (21px at P=3) sliced the label in half.
  The scoped theme rule wins the cascade over the atomic classes, so the
  theme sets badge `height: 8P + 2P`, `padding: P × 3P`, `lineHeight: 1`
  in the badge override. Verified by measurement: all gallery badges
  compute to 30px at P=3 and render their full label. Lesson worth
  keeping: micro-components carry fixed heights keyed to spacing tokens —
  audit each component's computed height when the type scale moves.

## Leakage

1. **Fonts are named, never loaded.** The theme sets
   `--font-family-body: Silkscreen` etc., but the app must ship the font
   files (this gallery links Google Fonts in `index.html`; production
   should self-host, as glyphdance/Forest do). If the font fails to load,
   the fallback silently becomes the design — and the design-grid math
   (design pixel = size/8) is Silkscreen-specific.
2. **`--radius-full` never scales — but most arcs yielded to clip-path.**
   The token is fixed at 9999px, so the theme steps around it per
   component: circle avatars, status dots, pagination dots and step
   indicators get a staircase pixel-circle clip-path; the Switch track
   gets a 1-step corner and a square thumb; ProgressBar track/fill are
   squared. The **radio dot** initially looked like a gap — it is drawn
   by a React *indicator component* — but the `.tsx` conversion closed
   it: `indicators` now maps radio/checkbox/check to pixel-matrix
   components (stepped ring + dot, stepped box + check), and `icons`
   maps all 27 semantic icon names to 12×12 pixel matrices. What still
   keeps a true arc:
   - the **Spinner** — a rotating arc; its keyframes are not themeable
     (same class as deepsea's keyframe leak).
3. **Hierarchy compression (by design, but a real constraint).** The font
   grid allows exactly three text sizes, so all fourteen Astryx text types
   collapse onto them. Hierarchy must come from weight, color, case and
   spacing. Any future component that *requires* a distinct small size
   (dense data tables, micro-labels) has no grid-legal size to use —
   it would need the dilation route at ≥6P px in a proportional font,
   which only works where a component override target exists.
4. **Dilation only reaches component targets.** `-webkit-text-stroke`
   works inside `components`, i.e. on Astryx components and Text types.
   Raw HTML the app renders itself (a `<pre>`, third-party markup) is
   outside the theme's reach and would need app CSS — the one place a
   sidecar stylesheet may still appear, scoped to non-Astryx content.
5. **Page-level surfaces have no theme surface.** The theme defines
   `--color-background-body`, but *painting* the page is the app shell's
   job — the gallery does it in four lines of app CSS
   (`[data-astryx-theme] { background: var(--color-background-body) }`).
   Body background patterns/textures (a pixel dither backdrop),
   scrollbar styling, and `::selection` color are likewise not
   tokenized or component-scoped; deepsea leaked exactly here
   (background orbs, scrollbar).
6. **The GL display pipeline is app code, not theme.** If the app adopts
   the drawElement + point-sampling shader display (experiments rounds
   3–6), that layer — canvas, shader, coordinate-mapped hit-testing —
   lives entirely outside `defineTheme`. The theme's job is to make the
   DOM worth sampling: grid-true sizes, spacing and corners.

7. **Palette variations pin only the identity tokens.** Each retro
   palette (garden / gameboy / nes / c64 / pico8) seeds the HCT
   generator (accent per scheme + neutral temperature) and pins
   background body/surface/card/popover + primary text to the source
   palette's colours. Status colours (success/warning/error) and the
   categorical hues are *not* derived from the retro palettes — they
   keep generated/default values, which is why a red "Blocked" badge
   appears inside the four-green Game Boy scheme. Pinning the full
   status set per palette is possible in the same tokens map; it is a
   curation task, not a tooling gap.

## Notes

- The gallery switches P at runtime (`createPixelTheme(2|3|4)` through
  `<Theme>`). Production should instead build one P with
  `astryx theme build` and ship the generated CSS (the P=3 build is
  committed at `src/studio/pixel.css`).
- Avatar `size="lg"` (48px) is used in the gallery because 48 is a
  multiple of every offered P (2, 3, 4) — grid-aligned at all settings.
