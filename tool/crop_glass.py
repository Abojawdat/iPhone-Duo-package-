#!/usr/bin/env python3
# crops the two tool/glass_demo.dart screenshots (iPad Pro 13-inch simulator,
# 2x) to the full Duo screens the glass gallery shows:
#   python3 tool/crop_glass.py rail.png bar.png
import sys
from pathlib import Path

from PIL import Image

root = Path(__file__).resolve().parent.parent
# the demo centres each screen on the 1032 pt wide iPad, 24 pt from the top
for name, shot, (w, h) in [
    ('rail', sys.argv[1], (951, 669)),
    ('bar', sys.argv[2], (669, 951)),
]:
    x = (1032 - w) / 2
    box = [round(v * 2) for v in (x, 24, x + w, 24 + h)]
    Image.open(shot).convert('RGB').crop(box).save(
        root / 'example/tool/glass' / f'{name}.webp', lossless=True, method=6)
    print(name, box)
