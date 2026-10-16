# Astryx Pixel Theme

A retro pixel theme for [Astryx](https://github.com/facebook/astryx), expressed
**purely as `defineTheme` config** — no sidecar CSS, no component forks. Built
as a feasibility study for giving the native GitHub repo-gardening app a pixel
look whose UI pixels align exactly with its sprite pixels.

**Live demo:** https://cixzhang.github.io/astryx-pixel-gallery/
(switch pixel size P = 2/3/4 × five retro palettes × light/dark, all live)

## The one idea

Everything in the theme is a function of a single number: the **pixel unit P**
(a `createPixelTheme(P, palette)` factory in `src/studio/pixel-theme.tsx`).

- **Type** — Silkscreen's design pixel is `font-size / 8` (measured from the
  font file). It renders perfectly only when that equals P, so every text size
  is a multiple of `8P` and every leading is grid-locked. Hierarchy comes from
  weight, colour and spacing, not off-grid sizes. (A grid font is
  all-or-nothing: one step off the multiple and the font/sampling grids beat
  and text disintegrates.)
- **Geometry** — spacing, borders (`border-width = P`), element heights and
  shadows (hard offsets, zero blur) all snap to multiples of P. Stepped
  clip-path corners ("pixel radius") replace arcs across ~35 component
  overrides; round things (avatars, status dots) get a staircase pixel-circle.
- **Icons & indicators** — all 27 semantic icons are hand-drawn 12×12 pixel
  matrices (`src/studio/pixel-icons.tsx`), and radio/checkbox indicators are
  pixel components — via defineTheme's first-class `icons` / `indicators`
  fields.
- **Colour** — five palettes (garden, Game Boy DMG, NES, C64, PICO-8). Each
  seeds Astryx's HCT palette generator and pins the surface/text tokens to
  the source palette's own colours in both schemes.
- **Images** — avatar photos are baked to one image-pixel per grid cell
  (sprite-pipeline style), so photo pixels and UI pixels are the same size.

## How it was validated

Six rounds of browser experiments (`experiments/FINDINGS.md`) preceded and
informed the theme: DOM shrink-and-upscale (dead for live DOM), a live
raster pipeline, a WebGL point-sampling shader (the winning pixelation
architecture for full-screen pixelation), curated-palette shader mapping,
legibility floors (glyphs need ≥ ~6 grid cells of height), and font-grid
measurement (glyph-coordinate GCDs).

What `defineTheme` could *not* express is logged honestly in
[`LEAKAGE.md`](LEAKAGE.md) — the Spinner's keyframes, page-level surfaces,
font loading, and a few more.

## Run it

```sh
npm install
npm run dev        # gallery with live P / palette / scheme switchers
```

Production themes are built ahead of time:

```sh
./node_modules/.bin/astryx theme build src/studio/pixel-theme.tsx
```
