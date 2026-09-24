#!/usr/bin/env python3
# packs example/build/visuals (from tool/render.dart) into doc/ as webp + the fold anim
import json
import sys
from pathlib import Path

from PIL import Image

root = Path(__file__).resolve().parent.parent
src = Path(sys.argv[1]) if len(sys.argv) > 1 else root / 'example/build/visuals'
doc = root / 'doc'
doc.mkdir(exist_ok=True)

for name in ['iphone-duo', 'everywhere']:
    Image.open(src / f'{name}.png').save(doc / f'{name}.webp', quality=90, method=6)

Image.open(src / 'social.png').convert('RGB').save(doc / 'social.png', optimize=True)

frames = json.loads((src / 'fold.json').read_text())
imgs = [Image.open(src / f['file']).convert('RGB') for f in frames]
imgs[0].save(
    doc / 'fold.webp',
    save_all=True,
    append_images=imgs[1:],
    duration=[f['ms'] for f in frames],
    loop=0,
    quality=82,
    method=6,
)

for f in sorted(doc.iterdir()):
    print(f'{f.name:18} {f.stat().st_size / 1024:8.0f} KB')
