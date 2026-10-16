import { createRequire } from 'node:module';
const require = createRequire('/home/hatch/workspace/wasm-flame/package.json');
const { chromium } = require('playwright-core');
const EXE = '/home/hatch/.cache/ms-playwright/chromium_headless_shell-1243/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT = new URL('.', import.meta.url).pathname;
const b = await chromium.launch({ executablePath: EXE, args: ['--no-sandbox', '--enable-features=CanvasDrawElement', '--use-angle=swiftshader'] });
const p = await b.newPage({ viewport: { width: 1800, height: 1600 }, deviceScaleFactor: 1 });
p.on('console', m => console.log('console:', m.text()));
p.on('pageerror', e => console.log('pageerror:', e.message));
await p.goto('http://127.0.0.1:8330/experiments/text.html', { waitUntil: 'networkidle' });
await p.waitForTimeout(2800);
console.log('status:', await p.locator('#status').innerText());
await p.locator('#capA').screenshot({ path: OUT + 'txt-capA.png' });
for (const id of ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']) {
  await p.locator('#' + id).screenshot({ path: OUT + `txt-${id}.png` });
  console.log('shot', id);
}
await b.close();
