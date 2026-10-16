# Pixel UI — CSS experiment findings (2026-10-16)

Question (Cindy): can we shrink components down to source-pixel size and
scale them back up with no aliasing, to get a retro pixel look? And can we
achieve a "pixel radius" (stepped corners instead of arcs)?

Harness: `index.html` — one sample cluster (card, heading, text, button,
pill badge, circular avatar, input, diagonal+circle SVG) authored at source
size (160×120, 1px borders, 4px radius, 11px font) and natively at 3×.
Display target 3× (pixel unit = 3px). Screenshots: `shoot.mjs`
(playwright-core + headless Chromium, deviceScaleFactor=1). Magnified
crops: `crops.py` → `strip-corners.png`, `strip-buttons.png` (5× nearest).
Pixel diffs measured on the aligned cluster region.

## Verdicts

| # | Treatment | Result |
|---|-----------|--------|
| T0 | Control: authored natively at 3× | Smooth arcs, diagonals, subpixel-fringed text. The baseline everything is compared to. |
| T1 | Source cluster + `transform: scale(3)` | **Soft upscale, not pixelated.** Chromium resamples the 1× layer raster with a smoothing filter: corners are a blurry arc, text loses subpixel fringing but goes fuzzy (mean abs diff vs T0 = 4.47, so it did *not* re-rasterize crisply either). Neither crisp nor pixel — the worst middle. |
| T1b | T1 + `image-rendering: pixelated` on the DOM node | **No-op** (diff vs T1 = 0.002). `image-rendering` applies to replaced content (img/canvas/video), not live DOM. Confirmed negative. |
| T2 | Source cluster + `zoom: 3` | **Pixel-identical to T0** (diff = 0.00). zoom re-runs layout and re-renders vector-crisp. The commonly suggested trick does nothing for pixelation. |
| T3 | True raster upscale: 1× screenshot → `<img>` at 3×, `image-rendering: pixelated` | **True pixel grid.** Every source pixel becomes a clean 3×3 block, corners/diagonals/text all step. Costs: completely static (no interaction, selection, or live state), source text's subpixel AA bakes in as coloured blocks, and every state change needs a re-render. Right tool for sprite/world surfaces, wrong tool for UI chrome. |
| T4 | SVG pixelate filter (`feFlood/feTile/feMorphology`) on native 3× DOM | **Mechanically works, quality unacceptable.** It does mosaic the live DOM into blocks, but block sampling amplifies subpixel fringes into cyan/yellow stripes and body text becomes garbled at 3px blocks. Also creates a containing block / filter raster over the subtree. Not viable for text-bearing UI. |
| T5 | Native 3× + stepped corners: `clip-path` staircase (3px steps) + inset box-shadow ring instead of a border | **Pixel radius works.** Corner scanline has only 2 distinct colours (vs 4–5 for arcs) — a true hard staircase, fully live and interactive. Caveats: clip-path clips real borders (hence the inset ring), shadows/focus outlines don't follow the clip, and round things (avatar, SVG) stay smooth — clip only fixes rectangular corners. |
| T6 | T1 + `will-change: transform` (forced layer) | Still a smooth resample (diff vs T1 = 5.37, vs T0 = 8.14 — slightly different phase, same softness). Layer promotion does not preserve a nearest-neighbour raster. |

## Conclusion

There is no CSS switch that pixelates live DOM on upscale: transforms
resample smoothly, zoom re-renders, `image-rendering` ignores DOM, and the
SVG mosaic filter destroys text. The viable split for the repo gardening
app is:

- **UI chrome (Astryx): native pixel geometry** — T5-style stepped corners,
  1-pixel-unit borders, hard offset shadows, spacing/sizes snapped to the
  pixel unit, and pixel *fonts* (Pixelify Sans / Cozette) at integer sizes
  for the typographic pixel feel. All live, selectable, accessible.
- **World / sprite surfaces (canvas): true raster upscale (T3)** — which
  Forest already does with integer zoom + nearest-neighbour in WebGL.

Next: test whether T5's stepped corners + ring borders can be expressed
inside `defineTheme`'s `components` overrides alone (clip-path and
box-shadow as component styles), with the pixel unit as a configurable
factory parameter — `createPixelTheme({ pixel: 3 })`.

---

# Round 2 — raster / filter line, pushed (2026-10-16, later)

Cindy: keep pushing raster/filter, and pixelate *everything*, avatars
included. Harness: `round2.html`; screenshots `r2-cell-*.png`;
HTML-in-Canvas probe in `/tmp/drawel` (shots copied to `drawel/`).

| # | Treatment | Result |
|---|-----------|--------|
| R1 | **Live raster pipeline**: real interactive DOM at 3× → html-to-image capture at pixelRatio 1/3 (downscale *averages*) → 160×120 canvas displayed at 3×, `image-rendering: pixelated`; re-capture on change | **Works, and it's the best-looking full pixelation.** Heading/body text pixelated but legible (averaging beats round 1's point sampling decisively); the Harvest counter incremented through the pipeline (0→2), typed input text ("water the tree") appeared in the display, the photo avatar pixelated with everything else, round crop intact. Costs: **~110–120 ms per capture** of a 480×360 cluster (≈8 fps ceiling, noticeable typing lag); cross-origin webfonts can't be inlined by the capture (Google Fonts stylesheet unreadable here), so captured text fell back to a different font and a badge wrapped — with self-hosted fonts (as glyphdance/Forest bundle theirs) this failure mode goes away. The interactive source DOM still has to exist and receive the real events; the canvas is a picture of it. |
| R2 | SVG mosaic v2: `feGaussianBlur` average → flood/tile sample → dilate | **Colour fixed, contrast killed.** No more cyan/yellow fringe stripes; button and photo avatar look good. But thin text strokes average toward the background — body text washes out to faint grey, input text barely readable. Bold display text survives. Averaging is a contrast tax small text can't pay at 3px blocks. |
| R3 | Screen-door: blurred native + repeating 1px grout grid every 3px | **Dead.** Reads as halftone/LED screen door, not pixels; grid darkens everything, body text illegible. |
| R4 | **HTML-in-Canvas** `ctx.drawElementImage` (Chromium 153, `--enable-features=CanvasDrawElement`) | **The real thing, behind a flag.** Canvas + child need `layoutsubtree`; then a live DOM subtree rasterises directly into a 160×120 canvas — no serialisation — and displays perfectly pixelated at 3× (`drawel/initial.png`). DOM updates + `requestPaint()` re-render live (message change verified, `drawel/after-dom-update.png`). Blockers: flag-gated (absent without it), canvas children are **not hit-testable** (clicks land on the canvas; the app must map coordinates to actions itself — which Forest's sprite UI already does), `getImageData` readback is blocked, and the drawn element's size/offset had quirks (~71% of expected width, slight top clip). Most promising line long-term; not shippable today. |
| R5 | **Avatars** (150×150 photo): (a) img + `image-rendering: pixelated` at 96px; (b) canvas downscale-in-halving-steps to 32²/16²/12², displayed 96px pixelated, round via border-radius; (c) SVG mosaic filter at 8px blocks; (d) 18² canvas at real UI size 54px | **Avatars pixelate cleanly, three ways.** (a) is a no-op (pixelated doesn't affect downscaling a larger bitmap). (b) is the winner: 32² = clearly pixel, face recognisable; 16² = chunky mosaic; round crop survives because border-radius clips the canvas; cost is a one-time bake per avatar, zero per frame. (c) works on photos (no subpixel fringe to amplify) but (b) is simpler and controllable. (d) at real size, 3px blocks read as a slightly chunky photo — the effect is honest but subtle at 54px; stronger blocks (6px) read more "pixel". |

---

# Round 3 — GL shader pixelation on the drawElement texture (2026-10-16)

Cindy's call: the 2D drawElement display looked blurry, but with GL we
control the resampling — apply the pixelation in a shader instead. Correct,
and measurable. Harness: `gl.html` + `shoot3.mjs`; shots `gl-*.png`.

Setup: the cluster is rasterised by `drawElementImage` at full 480×360
into a capture canvas; four WebGL2 panels texture that capture and
resample in a fragment shader onto a 160×120 grid (pixel unit 3px).

**Why the round-2 shot looked blurry, settled:** the source element
rasterises with ordinary AA (it's just a texture), and the browser's
compositor/screenshot path resamples the low-res canvas with no grid
discipline — in headless screenshots the drawn content didn't even get
CSS-upscaled (it sat at backing size, top-left). The blur is a
*resampling* failure, not a rasterisation failure — exactly what a
shader owns.

| # | Shader | Result |
|---|--------|--------|
| G0 | Passthrough, LINEAR | Identical to capture (uniform-block score 0.80 = flat areas only). The blurry baseline. |
| G1 | Grid + point sample (NEAREST at cell centre) | **Perfect grid: uniform 3×3-block fraction = 1.0000** (phase-corrected; the screenshot carries a 1px sliver row). Hard retro pixels, avatar included. Aliasing cost: thin strokes randomly drop — body text letters lose strokes, the badge's "+" nearly vanishes. |
| G2 | Grid + mip-average sample (`textureLod`, ≈log2(3)) | **Also a perfect 1.0000 grid, and the best quality overall**: every cell flat, but its colour is the cell average — text fully legible ("+3 plots" intact), avatar cleanly pixelated. This is R1's averaging quality at GPU cost per frame — no 120ms serialisation, live on every paint. |
| G3 | G2 + naive palette posterise (6 levels/channel) | Grid perfect, **palette broken**: measured paper (244,236,216) → (255,255,204); per-channel rounding pushes channels across thresholds independently, shifting hues and leaving chromatic fringes on text edges. The mechanism is right, the palette strategy is wrong — a real version needs a curated palette with nearest-colour mapping (perceptual distance), optionally Bayer-dithered, not uniform quantisation. |

**Verdict:** Cindy's architecture is the one that works end-to-end for
full-UI pixelation: DOM → drawElementImage texture → WebGL shader grid.
Point sampling (G1) gives the authentic hard look with aliasing losses;
mip-averaging (G2) gives the legible look — and the choice is a uniform,
switchable per surface or even per frame. Remaining blockers are the
round-2 ones: the `CanvasDrawElement` flag, no hit-testing on canvas
children (app maps coordinates itself — Forest already does), and no
readback. A fallback path exists today: swap the texture source from
drawElement-canvas to an html-to-image canvas (R1) and the same shaders
apply — slower texture updates, identical display math.

---

# Round 4 — curated palette + dithering (2026-10-16)

Fixing G3. Harness: `palette.html` + `shoot4.mjs`; shots `pal-g*.png`.
Palette: 28 colours in one JS array feeding both the shader uniform and
the on-page swatch strip — 11 pinned exact UI design colours, 7 garden
mids, 10 photo/avatar tones (median-cut extracted from the avatar photo).
Mapping: redmean distance to nearest palette colour, applied to the G2
mip-averaged cell colour.

| # | Variant | Result |
|---|---------|--------|
| G4 | Palette, no dither | **Palette fixed.** Flat paper cell measures (244,236,216) — the exact design colour (G3: (255,255,204)). Button green and badge gold likewise exact, text legible in palette tones, avatar a clean 19-colour mosaic in the sampled zone (vs 183 colours unquantised). Cost: visible banding in the avatar's gradients. |
| G5 | + Bayer dither 0.15, ungated | **Speckle everywhere.** The dither offsets *every* cell, including ones already exactly on-palette: the same flat paper cell measures (255,253,244) — perturbed off its own colour. Text softens. Ungated dithering taxes the flats to pay the gradients. |
| G6 | + Bayer dither 0.30, ungated | Worse in the same direction (fixed-window paper-exactness 0.28 vs G4's 0.75). |
| G7 | + Bayer dither 0.30, **distance-gated** | **The keeper.** Dither amplitude × smoothstep(distance from averaged colour to nearest palette entry): on-palette flats have distance ≈ 0 → zero dither, paper cell back to exact (244,236,216), window exactness matches G4 (0.75 / button 0.51); only genuine gradient/photo cells receive dither, and the avatar's tone steps dissolve (21 tones, smoother distribution). Text stays G4-crisp. |

Rule extracted: **dither only colours that fall between palette entries;
never dither a colour the palette already owns.** With that, the full
display stack is settled: DOM → drawElementImage (or html-to-image
fallback) texture → mip-averaged grid sample → curated-palette mapping →
distance-gated Bayer dither. Every parameter (grid size = pixel unit,
palette, dither dose) is a uniform — i.e. configurable at runtime, which
is what the gardening app's pixel-scale requirement needs.

---

# Round 5 — point sampling, but legible (2026-10-16)

Cindy's constraints: **no dithering** (round 4's G5–G7 are retired);
point sampling (G1) has the best pixelated look but loses font
legibility. Both fixes tested keep pure point sampling — every output
cell is one real source texel. Harness: `text.html` + `shoot5.mjs`;
shots `txt-h*.png`. Same cluster, with a sentence ladder at
24/21/18/15/12px. Legibility = the author's transcription read of each
panel (no OCR available in this environment).

| # | Variant | Read |
|---|---------|------|
| H1 | Plain source, centre point sample | Readable at 24 (with glitches), borderline 21, dead below 18. Button reads "Harvesl" (t lost), badge "+3 plots" mangled. |
| H2 | Plain source, **max-contrast texel** (per cell, output the 3×3 texel farthest from the cell mean) | **Worse than H1 at every size — dead.** In dense glyphs most cells contain an edge, so the rule fires everywhere, picks extremes, fattens strokes irregularly and fills counters. Heading turns to mush; white-on-green button text blobs. Ink-priority sampling works for sparse lines, not text. |
| H3 | **Stroke-dilated source** (`-webkit-text-stroke` 0.8px, same colour, on all text) + centre point | **The fix.** Fully readable at 24/21/18, partial at 15, dead at 12. Button "Harvest" perfect. Costs: dilated text is wider — the 24px line wraps where H1's didn't (dilation changes source layout), and type reads bolder. Badge still loses the "+" (thin geometric glyphs are the last casualty). |
| H4 | Dilated + max-contrast | Worse again, same failure as H2. Max-contrast is dead in both pairings. |
| H5 | Dilated + **grid-locked type** (every line-height/margin a multiple of the 3px cell) + centre point | ≈ H3, slightly cleaner at 15. Consistent phase helps a little; dilation does the heavy lifting. |
| H6 | H5 with sampling phase shifted +1 texel (y) | ≈ H5. Phase luck is a minor factor once strokes are dilated. |

Floor, stated in cells because that's the portable rule: **glyphs need
≥ ~6 cells of height to survive point sampling.** At pixel unit 3 the
floor is 18px source text; 12px (4 cells) is information-theoretically
gone — no sampling rule recovered it. Design rules for point-sampled UI:
(1) dilate text in the source (or equivalently choose heavier weights);
(2) keep vertical metrics on the grid; (3) minimum text ≈ 6 cells;
(4) thin symbols/icons need their own dilation — or grid-native pixel
icons (pixelarticons), which are born on the grid.

---

# Round 6 — grid-native pixel fonts as source (2026-10-16)

Hypothesis: if the font's own design pixel equals the sampling cell,
point sampling reproduces glyphs exactly — no dilation needed. Font
grids **measured from the font files** (glyph x-coordinate GCD):
Silkscreen and Press Start 2P both draw on a design pixel of size/8
(at 24px → 3.00px = exactly the cell; at 16px → 2px). **Cozette's TTF is
the Vector remaster — coordinate GCD 1, no design grid at all** (its
strokes at 24px are ~2px hairlines). Harness: `fonts.html` +
`shoot6.mjs`; shots `fnt-*.png`, sources `fnt-cap-*.png` (all sources
verified clean — every failure below is a sampling failure).
Centre point sampling, no dilation, grid-locked line-heights.

| Font @ size | Read |
|---|---|
| **Silkscreen 24** (design px = cell) | **Perfect.** "WATER THE WILTING PLANTS FIRST." reproduces essentially 1:1 — the crispest point-sampled text in all six rounds, zero dilation. |
| Silkscreen 16 (design px 2 vs cell 3) | **Destroyed — worse than Pixelify at 16.** The 2px font grid and 3px sampling grid beat against each other (moiré); strokes land irregularly and letters disintegrate. Button and badge text at 16 die with it. |
| Silkscreen 12 (design px 1.5) | Destroyed, same beat. |
| Press Start 2P 24 | Legible and charming, chunkier than Silkscreen; very wide (line wraps). 16 partial (bolder strokes survive the beat better), 12 degraded. |
| Cozette 24/16/12 | Dead at every size — no grid + hairline strokes is the worst combination for point sampling. (Cozette remains fine for *native* rendering, as in glyphdance/Forest; it's out for this pipeline unless dilated.) |
| Pixelify 24/16/12 (control) | As round 5: 24 readable, 16 partial, 12 dead. |

Rules extracted:
1. **Grid fonts are all-or-nothing.** Perfect exactly when design pixel
   == cell (or an integer multiple of it); catastrophic one step off,
   because two incommensurate grids beat. A grid font therefore gives
   you *one* body size per pixel-unit setting (Silkscreen 24 at unit 3),
   plus integer-multiple display sizes (48 for headings).
2. The matched relationship is the invariant: pixel unit must equal
   the body font's design pixel. (At pixel unit 2, Silkscreen 16
   becomes the matched body size.)
3. Everything that can't be a matched grid size still needs round 5's
   dilation recipe. The two techniques partition the UI: grid font at
   matched sizes for primary text; dilated proportional text (≥6 cells)
   for the rest.

## Round-2 conclusion

Everything — text, controls, avatars, round shapes — *can* be pixelated
today, but every full-UI route pays one of three taxes: the raster
pipeline pays ~120 ms and a shadow DOM per capture (R1), the filter pays
text contrast (R2), and the native canvas API pays a feature flag and
hit-testing (R4). The cheap, lossless wins are per-asset: avatars and
images baked to the pixel grid once (R5b). For the gardening app this
suggests: native pixel-geometry DOM (round 1, T5) for interactive
chrome, baked pixel avatars/images, raster pipeline reserved for
bounded, mostly-static display surfaces — and drawElementImage as the
watch item that eventually makes full-UI raster cheap.
