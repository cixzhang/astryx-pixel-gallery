import { createRequire } from 'node:module';
const require = createRequire('/home/hatch/workspace/wasm-flame/package.json');
const { chromium } = require('playwright-core');
const EXE = '/home/hatch/.cache/ms-playwright/chromium_headless_shell-1243/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT = new URL('.', import.meta.url).pathname;
const b = await chromium.launch({ executablePath: EXE, args: ['--no-sandbox', '--force-color-profile=srgb'] });
const p = await b.newPage({ viewport: { width: 1800, height: 1400 }, deviceScaleFactor: 1 });
p.on('console', m => console.log('console:', m.text()));
p.on('pageerror', e => console.log('pageerror:', e.message));
await p.goto('http://127.0.0.1:8330/experiments/round2.html', { waitUntil: 'networkidle' });
await p.waitForTimeout(2500);
console.log('R1 stats:', await p.locator('#r1stats').innerText());
// interact with the SOURCE: click Harvest twice and change the input, let captures fire
await p.click('#r1btn'); await p.waitForTimeout(700);
await p.click('#r1btn'); await p.waitForTimeout(700);
await p.fill('#r1inp', 'water the tree');
await p.waitForTimeout(900);
console.log('R1 stats after interaction:', await p.locator('#r1stats').innerText());
console.log('R1 counter in source DOM:', await p.locator('#r1n').innerText());
const cells = p.locator('.grid .cell');
for (let i = 0; i < await cells.count(); i++) {
  await cells.nth(i).screenshot({ path: OUT + `r2-cell-${i}.png` });
  console.log('shot', i, await cells.nth(i).locator('h2').innerText());
}
await b.close();
