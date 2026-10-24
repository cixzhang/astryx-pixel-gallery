/**
 * SPIKE generator: the pixel theme -> a Swift `AstryxTheme` for swift-ios-1.
 *
 * Follows the proposed Swift theme generator spec (facebook/astryx PR 8031):
 * values come only from core's `resolveThemeTokens(theme, {mode})`, colours
 * become #RRGGBBAA, lengths become points, font stacks become family lists.
 * Spike extensions, each a gap in the report:
 *   - theme-local tokens are resolved separately (resolveThemeTokens leaves
 *     them out) and kept by full name when they convert (`pixel`);
 *   - the native theme is resolved for iOS and emitted as `native:` (PR 8031
 *     OQ3), including the PROPOSED members.
 * Kept groups whose value cannot convert fail the run, as G6 says.
 *
 * Run: node native/generate-swift.mjs
 */
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createJiti} from 'jiti';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(HERE, 'swift/core/Theme/Generated/PixelTheme.swift');
const REPORT = path.join(HERE, 'generated-report.json');

const jiti = createJiti(import.meta.url, {jsx: true});
const {pixelNativeThemeProposed, pixelNativeTheme, webPartReports} = await jiti.import(
  './theme/pixelNativeTheme.ts',
);
const {resolveNativeThemeProposed} = await jiti.import('./theme/proposedVocabulary.ts');
const {pixelTheme} = await jiti.import('../src/studio/pixel-theme.tsx');
const {resolveThemeTokens} = await import('@astryxdesign/core/theme/tokens');

// PR 8031 G5 groups.
const KEEP =
  /^--(color-|spacing-|radius-|size-element-|border-width$|font-size-|font-weight-|font-family-|text-(heading-\d|body|large|label|supporting)-)/;
// Groups the pixel look uses that G5 leaves out; reported, not emitted.
const ALSO_LOOKED_AT = /^--(shadow-(low|med|high)$|ease-standard$|duration-(fast|medium|slow)$|focus-outline-(width|offset)$)/;
const REM = 16;
const WEIGHT_KEYWORDS = {normal: 400, bold: 700};

const hex2 = n => Math.round(n).toString(16).padStart(2, '0').toUpperCase();
const NAMED = {black: '#000000FF', white: '#FFFFFFFF', transparent: '#00000000'};
function toHexColor(value) {
  const v = value.trim();
  let m = /^#([0-9a-f]{3,8})$/i.exec(v);
  if (m) {
    let h = m[1];
    if (h.length === 3 || h.length === 4) h = [...h].map(c => c + c).join('');
    if (h.length === 6) h += 'FF';
    return h.length === 8 ? `#${h.toUpperCase()}` : null;
  }
  m = /^rgba?\(\s*([\d.]+)[,\s]+([\d.]+)[,\s]+([\d.]+)(?:[,\s/]+([\d.]+%?))?\s*\)$/i.exec(v);
  if (m) {
    const a = m[4] === undefined ? 1 : m[4].endsWith('%') ? parseFloat(m[4]) / 100 : parseFloat(m[4]);
    return `#${hex2(+m[1])}${hex2(+m[2])}${hex2(+m[3])}${hex2(a * 255)}`;
  }
  return NAMED[v.toLowerCase()] ?? null;
}
function toPoints(value) {
  const m = /^(-?[\d.]+)(rem|px)?$/.exec(value.trim());
  if (!m) return null;
  return m[2] === 'rem' ? parseFloat(m[1]) * REM : parseFloat(m[1]);
}
const toFamilies = value => value.split(',').map(f => f.trim().replace(/^['"]|['"]$/g, '')).filter(Boolean);

const report = {webPartReports, notEmitted: {}, localTokens: {}};

function resolveMode(mode) {
  const colors = {};
  const sizes = {};
  const fonts = {};
  for (const [name, value] of Object.entries(resolveThemeTokens(pixelTheme, {mode}))) {
    if (typeof value !== 'string') continue;
    if (ALSO_LOOKED_AT.test(name)) {
      (report.notEmitted[name] ??= {})[mode] = value;
      continue;
    }
    if (!KEEP.test(name)) continue;
    const key = name.slice(2);
    if (key.startsWith('font-family-')) {
      fonts[key] = toFamilies(value);
    } else if (key.startsWith('color-')) {
      const c = toHexColor(value);
      if (c === null) throw new Error(`${mode}: ${name} is not a color Swift can read: ${value}`);
      colors[key] = c;
    } else {
      let p = toPoints(value);
      // SPIKE: CSS weight keywords. PR 8031 G6 lists none, so the pixel
      // theme's `weight: 'bold'` would fail the run.
      if (p === null && key.endsWith('-weight') && value in WEIGHT_KEYWORDS) {
        p = WEIGHT_KEYWORDS[value];
        (report.weightKeywords ??= {})[name] = value;
      }
      if (p === null) throw new Error(`${mode}: ${name} is not a size Swift can read: ${value}`);
      sizes[key] = p;
    }
  }
  // SPIKE: theme-local tokens. resolveThemeTokens does not return them, and
  // PR 8031 G5 keeps only `astryx-theme-<theme>-<group>` names, so the
  // pixel theme's `--pixel` would be dropped. Kept here by full name.
  for (const [name, raw] of Object.entries(pixelTheme.localTokens ?? {})) {
    const value = Array.isArray(raw) ? raw[mode === 'dark' ? 1 : 0] : raw;
    const p = toPoints(String(value));
    const c = p === null ? toHexColor(String(value)) : null;
    report.localTokens[name] = value;
    if (p !== null) sizes[name.slice(2)] = p;
    else if (c !== null) colors[name.slice(2)] = c;
  }
  return {colors, sizes, fonts};
}

const light = resolveMode('light');
const dark = resolveMode('dark');
const nativeToday = resolveNativeThemeProposed(pixelNativeTheme, {platform: 'ios', osVersion: '18.0'});
const native = resolveNativeThemeProposed(pixelNativeThemeProposed, {platform: 'ios', osVersion: '18.0'});
report.nativeToday = nativeToday;
report.nativeProposed = native;

const q = s => JSON.stringify(s);
const dict = (entries, fmt, indent) => {
  const keys = Object.keys(entries).sort();
  if (keys.length === 0) return '[:]';
  return `[\n${keys.map(k => `${indent}  ${q(k)}: ${fmt(entries[k])},`).join('\n')}\n${indent}]`;
};
const tokens = (t, indent) => `AstryxTokens(
${indent}  colors: ${dict(t.colors, q, indent + '  ')},
${indent}  sizes: ${dict(t.sizes, v => String(v), indent + '  ')},
${indent}  fonts: ${dict(t.fonts, v => `[${v.map(q).join(', ')}]`, indent + '  ')}
${indent})`;
const iconRef = ref =>
  'assetName' in ref ? `.asset(${q(ref.assetName)})` : 'systemName' in ref ? `.system(${q(ref.systemName)})` : `.system("questionmark")`;
const nativeIntent = (n, indent) => `AstryxNativeIntent(
${indent}  material: ${n.material ? '.' + n.material : 'nil'},
${indent}  corners: .${n.corners ?? 'smooth'},
${indent}  imageScaling: .${n.imageScaling ?? 'smooth'},
${indent}  textGrid: ${n.textGrid ?? 0},
${indent}  components: ${dict(n.components ?? {}, c => dict(Object.fromEntries(Object.entries(c).map(([k, v]) => [k, String(v)])), q, indent + '    '), indent + '  ')},
${indent}  icons: ${dict(n.icons ?? {}, iconRef, indent + '  ')}
${indent})`;

const swift = `// Generated by native/generate-swift.mjs (SPIKE) from core's resolveThemeTokens
// over the pixel theme (P=3, garden) and its native theme. Do not edit.
// Run \`node native/generate-swift.mjs\` after a theme change.

extension AstryxTheme {
  /// Pixel theme with the PROPOSED native vocabulary (stepped corners,
  /// pixelated images, text grid, asset icons).
  public static let pixel = AstryxTheme(
    light: ${tokens(light, '    ')},
    dark: ${tokens(dark, '    ')},
    native: ${nativeIntent(native, '    ')}
  )

  /// Pixel theme with only what defineNativeTheme on main can say today.
  public static let pixelToday = AstryxTheme(
    light: AstryxTheme.pixel.light,
    dark: AstryxTheme.pixel.dark,
    native: ${nativeIntent(nativeToday, '    ')}
  )
}
`;
fs.writeFileSync(OUT, swift);
fs.writeFileSync(REPORT, JSON.stringify(report, null, 2) + '\n');
console.log(`wrote ${path.relative(process.cwd(), OUT)} (${light.colors ? Object.keys(light.colors).length : 0} colors, ${Object.keys(light.sizes).length} sizes, ${Object.keys(light.fonts).length} fonts)`);
