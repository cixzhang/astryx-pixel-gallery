"""SPIKE: turn the theme's 12x12 pixel-icon matrices (src/studio/pixel-icons.tsx)
into an iOS asset catalog: one template image per icon, named pixel.<name>,
12x12 px, drawn with nearest-neighbour scaling by the app (`.interpolation(.none)`).
Run: python3 native/tools/pixel_icons_to_assets.py
"""
import json, os, re, struct, zlib

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = os.path.join(ROOT, 'src/studio/pixel-icons.tsx')
OUT = os.path.join(ROOT, 'native/App/Resources/Assets.xcassets')

def png(rows):
    h, w = len(rows), len(rows[0])
    raw = b''.join(b'\x00' + b''.join(b'\x00\x00\x00\xff' if c == '#' else b'\x00\x00\x00\x00' for c in row) for row in rows)
    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))

src = open(SRC).read()
block = src[src.index('const M = {'):]
block = block[:block.index('\n};')]
icons = {m.group(1): re.findall(r"'([.#]+)'", m.group(2))
         for m in re.finditer(r"\n  (\w+): \[((?:\s*'[.#]+',?)+)\s*\]", block)}
os.makedirs(OUT, exist_ok=True)
json.dump({'info': {'author': 'xcode', 'version': 1}}, open(os.path.join(OUT, 'Contents.json'), 'w'))
for name, rows in icons.items():
    assert len(rows) == 12 and all(len(r) == 12 for r in rows), name
    d = os.path.join(OUT, f'pixel.{name}.imageset')
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, f'{name}.png'), 'wb').write(png(rows))
    json.dump({'images': [{'filename': f'{name}.png', 'idiom': 'universal'}],
               'info': {'author': 'xcode', 'version': 1},
               'properties': {'template-rendering-intent': 'template', 'preserves-vector-representation': False}},
              open(os.path.join(d, 'Contents.json'), 'w'), indent=2)
print(len(icons), 'icons:', ' '.join(sorted(icons)))
