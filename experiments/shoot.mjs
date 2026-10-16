// Screenshot harness for the pixel CSS experiments.
// playwright-core is borrowed from an existing project's node_modules;
// Chromium is the cached headless shell build.
import { createRequire } from 'node:module';
import fs from 'node:fs';

const require = createRequire('/home/hatch/workspace/wasm-flame/package.json');
const { chromium } = require('playwright-core');

const EXE = '/home/hatch/.cache/ms-playwright/chromium_headless_shell-1243/chrome-headless-shell-linux64/chrome-headless-shell';
const BASE = 'http://127.0.0.1:8327/index.html';
const OUT = new URL('.', import.meta.url).pathname;

const browser = await chromium.launch({ executablePath: EXE, args: ['--no-sandbox', '--force-color-profile=srgb'] });
const page = await browser.newPage({ viewport: { width: 1720, height: 1200 }, deviceScaleFactor: 1 });
await page.goto(BASE, { waitUntil: 'networkidle' });
await page.waitForTimeout(600);

// 1) Capture the SOURCE cluster at exactly 1x -> raster-1x.png (T3's bitmap)
const source = page.locator('#source');
await source.screenshot({ path: OUT + 'raster-1x.png' });
console.log('raster-1x.png written');

// 2) Reload so T3 picks the raster up, then shoot every treatment cell
await page.reload({ waitUntil: 'networkidle' });
await page.waitForTimeout(600);

const cells = page.locator('.grid .cell');
const count = await cells.count();
console.log('treatment cells:', count);
for (let i = 0; i < count; i++) {
  const cell = cells.nth(i);
  const label = await cell.locator('h2').innerText();
  await cell.screenshot({ path: OUT + `cell-${i}.png` });
  console.log(i, label);
}

// 3) Full page for the record
await page.screenshot({ path: OUT + 'full.png', fullPage: true });
await browser.close();
console.log('done');
