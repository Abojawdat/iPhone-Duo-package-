#!/usr/bin/env python3
# crops a tool/glass_demo.dart screenshot (iPad Pro 13-inch simulator, 2x)
# into the two halves the glass gallery shows:
#   python3 tool/crop_glass.py <screenshot.png>
import sys
from pathlib import Path

from PIL import Image

root = Path(__file__).resolve().parent.parent
im = Image.open(sys.argv[1]).convert('RGB')
# two 951 x 669 Duo screens, centred on the 1032 pt screen and stacked at the
# bottom with a 7 pt gap. the half starts at the fold, 40.5 + 475.5 pt in
for name, top in [('dark', 24), ('light', 700)]:
    box = [round(v * 2) for v in (516, top, 991.5, top + 669)]
    im.crop(box).save(root / 'example/tool/glass' / f'{name}.webp', lossless=True, method=6)
    print(name, box)
