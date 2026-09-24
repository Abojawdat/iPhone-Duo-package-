#!/usr/bin/env python3
# packs example/build/visuals (from example/tool/render.dart) into doc/:
# stills as webp, every <name>.json frame list as an animated webp
import json
import sys
from pathlib import Path

from PIL import Image

root = Path(__file__).resolve().parent.parent
src = Path(sys.argv[1]) if len(sys.argv) > 1 else root / 'example/build/visuals'
doc = root / 'doc'
(doc / 'anim').mkdir(parents=True, exist_ok=True)

for name in ['iphone-duo', 'everywhere']:
    Image.open(src / f'{name}.png').save(doc / f'{name}.webp', quality=90, method=6)

Image.open(src / 'social.png').convert('RGB').save(doc / 'social.png', optimize=True)

# fold.webp is a pub.dev screenshot so it stays in doc/, the rest go to doc/anim/
for manifest in sorted(src.glob('*.json')):
    name = manifest.stem
    frames = json.loads(manifest.read_text())
    imgs = [Image.open(src / f['file']).convert('RGB') for f in frames]
    target = doc / 'fold.webp' if name == 'fold' else doc / 'anim' / f'{name}.webp'
    imgs[0].save(
        target,
        save_all=True,
        append_images=imgs[1:],
        duration=[f['ms'] for f in frames],
        loop=0,
        quality=80,
        method=6,
    )

for f in sorted(doc.rglob('*.*')):
    if f.suffix in {'.webp', '.png', '.svg'}:
        print(f'{str(f.relative_to(doc)):22} {f.stat().st_size / 1024:8.0f} KB')
