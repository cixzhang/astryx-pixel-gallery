#!/usr/bin/env python3
"""Magnified pixel-level crops of each treatment cell.

Finds the paper-colored cluster bbox, crops (a) its top-left corner and
(b) the green button region, upscales with NEAREST so the actual device
pixels are visible, and writes per-treatment crops + two comparison strips.
"""
from PIL import Image, ImageDraw
import glob, os

HERE = os.path.dirname(os.path.abspath(__file__))
PAPER = (244, 236, 216)
GREEN = (62, 137, 72)
NAMES = ['T0 native-3x', 'T1 transform', 'T1b transform+pixelated', 'T2 zoom',
         'T3 raster-upscale', 'T4 svg-filter', 'T5 stepped-clip', 'T6 will-change']

def find_bbox(img, color, tol=12, min_count=200):
    px = img.convert('RGB')
    w, h = px.size
    data = px.load()
    xs, ys = [], []
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            r, g, b = data[x, y]
            if abs(r-color[0]) <= tol and abs(g-color[1]) <= tol and abs(b-color[2]) <= tol:
                xs.append(x); ys.append(y)
    if len(xs) < min_count:
        return None
    return min(xs), min(ys), max(xs), max(ys)

def crop_save(img, box, out, scale=5):
    c = img.crop(box)
    c = c.resize((c.width*scale, c.height*scale), Image.NEAREST)
    c.save(out)
    return c

corners, buttons = [], []
for i in range(8):
    path = os.path.join(HERE, f'cell-{i}.png')
    img = Image.open(path).convert('RGB')
    bb = find_bbox(img, PAPER)
    if not bb:
        print(i, 'no paper bbox'); continue
    x0, y0, x1, y1 = bb
    corner = crop_save(img, (max(0, x0-3), max(0, y0-3), x0+57, y0+37),
                       os.path.join(HERE, f'crop-{i}-corner.png'))
    corners.append((i, corner))
    gb = find_bbox(img.crop((x0, y0, x1, y1)), GREEN, min_count=50)
    if gb:
        gx0, gy0 = x0+gb[0], y0+gb[1]
        btn = crop_save(img, (max(0, gx0-12), max(0, gy0-12), gx0+108, gy0+48),
                        os.path.join(HERE, f'crop-{i}-button.png'))
        buttons.append((i, btn))
    print(i, NAMES[i], 'paper bbox', bb)

def strip(items, out, label_h=22):
    if not items: return
    w = max(im.width for _, im in items)
    h = sum(im.height + label_h for _, im in items)
    canvas = Image.new('RGB', (w, h), (24, 24, 24))
    d = ImageDraw.Draw(canvas)
    y = 0
    for i, im in items:
        d.text((6, y+5), f'{NAMES[i]}  (5x nearest)', fill=(230, 230, 210))
        canvas.paste(im, (0, y+label_h))
        y += im.height + label_h
    canvas.save(out)
    print('wrote', out, canvas.size)

strip(corners, os.path.join(HERE, 'strip-corners.png'))
strip(buttons, os.path.join(HERE, 'strip-buttons.png'))
