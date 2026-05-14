#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math
import random


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "branding" / "wallpapers" / "Bytefall" / "contents" / "images" / "3840x2160.png"
BOOT = ROOT / "branding" / "boot" / "splash.png"


def lerp(a, b, t):
    return int(a + (b - a) * t)


def gradient(width, height):
    img = Image.new("RGB", (width, height), "#061016")
    px = img.load()
    for y in range(height):
        fy = y / max(1, height - 1)
        for x in range(width):
            fx = x / max(1, width - 1)
            d1 = math.hypot(fx - 0.72, fy - 0.26)
            d2 = math.hypot(fx - 0.18, fy - 0.72)
            ice = max(0, 1 - d1 * 1.55)
            deep = max(0, 1 - d2 * 1.25)
            r = lerp(5, 18, fy) + int(35 * ice) + int(8 * deep)
            g = lerp(15, 32, fy) + int(95 * ice) + int(30 * deep)
            b = lerp(22, 42, fy) + int(120 * ice) + int(55 * deep)
            px[x, y] = (min(r, 125), min(g, 190), min(b, 225))
    return img


def hex_points(cx, cy, radius):
    return [
        (
            cx + math.cos(math.radians(60 * i - 90)) * radius,
            cy + math.sin(math.radians(60 * i - 90)) * radius,
        )
        for i in range(6)
    ]


def draw_logo(draw, cx, cy, radius):
    outer = hex_points(cx, cy, radius)
    center = (cx, cy)
    fills = ["#e9fbff", "#b6f2ff", "#7ee2fb", "#38bde6", "#1b739f", "#0e4167"]
    for i in range(6):
        draw.polygon([center, outer[i], outer[(i + 1) % 6]], fill=fills[i])
    draw.line(outer + [outer[0]], fill="#f4fdff", width=max(2, radius // 32), joint="curve")


def make_wallpaper(width=3840, height=2160):
    img = gradient(width, height).convert("RGBA")
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    random.seed(42)

    # Large angular ice planes, kept low contrast so desktop icons remain readable.
    planes = [
        [(0, height * 0.18), (width * 0.42, 0), (width * 0.16, height), (0, height)],
        [(width, 0), (width * 0.58, 0), (width, height * 0.45)],
        [(width * 0.55, height), (width, height * 0.62), (width, height)],
    ]
    for poly in planes:
        d.polygon(poly, fill=(150, 235, 255, 18))

    for _ in range(48):
        x1 = random.randint(-200, width + 200)
        y1 = random.randint(-200, height + 200)
        length = random.randint(220, 860)
        angle = random.choice([24, 30, 150, 156])
        x2 = x1 + math.cos(math.radians(angle)) * length
        y2 = y1 + math.sin(math.radians(angle)) * length
        color = random.choice([(168, 240, 255, 34), (76, 198, 232, 26), (229, 250, 255, 22)])
        d.line((x1, y1, x2, y2), fill=color, width=random.randint(1, 3))

    # Soft horizon glow.
    glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((width * 0.56, height * 0.04, width * 1.10, height * 0.92), fill=(118, 226, 255, 46))
    glow = glow.filter(ImageFilter.GaussianBlur(130))
    img = Image.alpha_composite(img, glow)
    img = Image.alpha_composite(img, overlay)

    mark = Image.new("RGBA", img.size, (0, 0, 0, 0))
    md = ImageDraw.Draw(mark)
    draw_logo(md, int(width * 0.78), int(height * 0.52), int(height * 0.145))
    mark = mark.filter(ImageFilter.GaussianBlur(0.15))
    img = Image.alpha_composite(img, mark)
    return img.convert("RGB")


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    BOOT.parent.mkdir(parents=True, exist_ok=True)
    wallpaper = make_wallpaper()
    wallpaper.save(OUT, optimize=True, quality=96)
    wallpaper.resize((1920, 1080), Image.Resampling.LANCZOS).save(BOOT, optimize=True, quality=95)
    print(f"Wrote {OUT}")
    print(f"Wrote {BOOT}")


if __name__ == "__main__":
    main()
