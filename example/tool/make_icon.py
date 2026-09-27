# App icon for the example: an open Duo, music on one screen, a photo on
# the other, the fold glowing in between. python3 tool/make_icon.py (Pillow)
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

S = 1024 * 2  # drawn at 2x, downscaled for smooth edges
root = Path(__file__).resolve().parent.parent


def lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def gradient(w, h, top, bottom, diagonal=True):
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        for x in range(w):
            t = (x + y) / (w + h) if diagonal else y / h
            px[x, y] = lerp(top, bottom, t)
    return img


def master():
    small = 256  # gradients are smooth, build them small and upscale
    bg = gradient(small, small, (0x3B, 0x2F, 0xC9), (0xE2, 0x4B, 0x9B))
    img = bg.resize((S, S), Image.BICUBIC).convert("RGBA")

    # soft glow behind the device
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        (S * .18, S * .2, S * .82, S * .8), fill=(255, 255, 255, 70))
    img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(S * .06)))

    # open device, two panes around the fold
    w, h = S * .70, S * .50
    x0, y0 = (S - w) / 2, (S - h) / 2
    shadow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x0, y0 + S * .03, x0 + w, y0 + h + S * .03), S * .06,
        fill=(20, 10, 60, 150))
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(S * .03)))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((x0, y0, x0 + w, y0 + h), S * .06,
                        fill=(18, 18, 26))
    bez = S * .022
    fold = x0 + w / 2

    # left screen: vinyl
    ls = (x0 + bez, y0 + bez, fold - S * .006, y0 + h - bez)
    screen = gradient(64, 64, (0x2A, 0x22, 0x55), (0x14, 0x14, 0x22), False)
    lw, lh = int(ls[2] - ls[0]), int(ls[3] - ls[1])
    mask = Image.new("L", (lw, lh), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, lw, lh), S * .045, fill=255)
    img.paste(screen.resize((lw, lh)), (int(ls[0]), int(ls[1])), mask)
    cx, cy, r = (ls[0] + ls[2]) / 2, (ls[1] + ls[3]) / 2, lh * .34
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(8, 8, 12))
    for k in range(5):
        g = r * (.55 + k * .09)
        d.ellipse((cx - g, cy - g, cx + g, cy + g), outline=(45, 45, 60),
                  width=int(S * .003))
    lr = r * .38
    label = gradient(32, 32, (0xFF, 0x6B, 0x6B), (0x6D, 0x5D, 0xFC))
    lm = Image.new("L", (int(lr * 2), int(lr * 2)), 0)
    ImageDraw.Draw(lm).ellipse((0, 0, lr * 2, lr * 2), fill=255)
    img.paste(label.resize(lm.size), (int(cx - lr), int(cy - lr)), lm)
    d.ellipse((cx - r * .05, cy - r * .05, cx + r * .05, cy + r * .05),
              fill=(8, 8, 12))

    # right screen: landscape photo
    rs = (fold + S * .006, y0 + bez, x0 + w - bez, y0 + h - bez)
    rw, rh = int(rs[2] - rs[0]), int(rs[3] - rs[1])
    photo = gradient(64, 64, (0x2B, 0x2D, 0x6E), (0xFF, 0x8A, 0x5B),
                     False).resize((rw, rh)).convert("RGBA")
    pd = ImageDraw.Draw(photo)
    sx, sy, sr = rw * .62, rh * .42, rh * .13
    pd.ellipse((sx - sr, sy - sr, sx + sr, sy + sr), fill=(255, 214, 140))
    for k, col in enumerate([(88, 60, 130), (58, 40, 96), (30, 22, 60)]):
        base = rh * (.6 + k * .13)
        pts = [(0, rh)]
        for i in range(33):
            x = rw * i / 32
            wave = math.sin(x / rw * math.pi * (2 + k) + k * 1.7)
            pts.append((x, base - (wave + 1) * rh * .06))
        pts.append((rw, rh))
        pd.polygon(pts, fill=col)
    pm = Image.new("L", (rw, rh), 0)
    ImageDraw.Draw(pm).rounded_rectangle((0, 0, rw, rh), S * .045, fill=255)
    img.paste(photo, (int(rs[0]), int(rs[1])), pm)

    # the fold, glowing
    crease = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(crease).line((fold, y0 - S * .04, fold, y0 + h + S * .04),
                                fill=(140, 200, 255, 255), width=int(S * .012))
    img.alpha_composite(crease.filter(ImageFilter.GaussianBlur(S * .012)))
    d.line((fold, y0 + bez * .5, fold, y0 + h - bez * .5),
           fill=(220, 240, 255), width=int(S * .004))
    return img.resize((1024, 1024), Image.LANCZOS)


def rounded(img, size):
    out = img.resize((size, size), Image.LANCZOS)
    m = Image.new("L", (size * 4, size * 4), 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, size * 4, size * 4),
                                        size * 4 * .22, fill=255)
    out.putalpha(m.resize((size, size), Image.LANCZOS))
    return out


icon = master()

# ios: opaque squares, the system rounds them
ios = root / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
for entry in json.loads((ios / "Contents.json").read_text())["images"]:
    pts = float(entry["size"].split("x")[0])
    px = round(pts * int(entry["scale"][0]))
    icon.convert("RGB").resize((px, px), Image.LANCZOS).save(ios / entry["filename"])

# android: legacy launcher icons, rounded here
res = root / "android/app/src/main/res"
for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144,
                   "xxxhdpi": 192}.items():
    rounded(icon, px).save(res / f"mipmap-{folder}/ic_launcher.png")

# macos: rounded with a margin, like other mac icons
mac = root / "macos/Runner/Assets.xcassets/AppIcon.appiconset"
for entry in json.loads((mac / "Contents.json").read_text())["images"]:
    px = round(float(entry["size"].split("x")[0]) * int(entry["scale"][0]))
    tile = Image.new("RGBA", (px, px), (0, 0, 0, 0))
    inner = round(px * .8)
    tile.alpha_composite(rounded(icon, inner), ((px - inner) // 2,) * 2)
    tile.save(mac / entry["filename"])

# web: favicon, manifest icons, maskable ones stay square
web = root / "web"
rounded(icon, 32).save(web / "favicon.png")
for px in (192, 512):
    rounded(icon, px).save(web / f"icons/Icon-{px}.png")
    icon.convert("RGB").resize((px, px), Image.LANCZOS).save(
        web / f"icons/Icon-maskable-{px}.png")
print("icons written")
