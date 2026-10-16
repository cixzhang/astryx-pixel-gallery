import { createRequire } from 'node:module';
const require = createRequire('/home/hatch/workspace/wasm-flame/package.json');
const { chromium } = require('playwright-core');
const EXE = '/home/hatch/.cache/ms-playwright/chromium_headless_shell-1243/chrome-headless-shell-linux64/chrome-headless-shell';
const OUT = new URL('.', import.meta.url).pathname;
const b = await chromium.launch({ executablePath: EXE, args: ['--no-sandbox'] });
const p = await b.newPage({ viewport: { width: 1280, height: 1100 }, deviceScaleFactor: 1 });
p.on('console', m => { if (m.type() === 'error') console.log('console-error:', m.text().slice(0, 200)); });
p.on('pageerror', e => console.log('pageerror:', e.message.slice(0, 200)));
await p.goto('http://127.0.0.1:8332/', { waitUntil: 'networkidle' });
await p.waitForTimeout(1500);
await p.screenshot({ path: OUT + 'gallery-p3.png', fullPage: true });
console.log('shot P=3');
// switch to P=2
await p.getByRole('button', { name: 'P = 2' }).click();
await p.waitForTimeout(800);
await p.screenshot({ path: OUT + 'gallery-p2.png', fullPage: true });
console.log('shot P=2');
// interactivity: harvest button
await p.getByRole('button', { name: 'Harvest ready plots' }).click();
await p.waitForTimeout(400);
const badge = await p.locator('text=Harvested 3').count();
console.log('harvest badge after click:', badge);
await b.close();
