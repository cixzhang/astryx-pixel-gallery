import { createRequire } from 'node:module';
const require = createRequire('/home/hatch/workspace/wasm-flame/package.json');
const { chromium } = require('playwright-core');
const EXE = '/home/hatch/.cache/ms-playwright/chromium_headless_shell-1243/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT = new URL('.', import.meta.url).pathname;
const b = await chromium.launch({ executablePath: EXE, args: ['--no-sandbox', '--enable-features=CanvasDrawElement', '--use-angle=swiftshader'] });
const p = await b.newPage({ viewport: { width: 1800, height: 1600 }, deviceScaleFactor: 1 });
p.on('console', m => console.log('console:', m.text()));
p.on('pageerror', e => console.log('pageerror:', e.message));
await p.goto('http://127.0.0.1:8330/experiments/fonts.html', { waitUntil: 'networkidle' });
await p.waitForTimeout(3000);
console.log('status:', await p.locator('#status').innerText());
for (const id of ['silk', 'ps2p', 'coz', 'pix']) {
  await p.locator('#cap-' + id).screenshot({ path: OUT + `fnt-cap-${id}.png` });
  await p.locator('#gl-' + id).screenshot({ path: OUT + `fnt-${id}.png` });
  console.log('shot', id);
}
await b.close();
