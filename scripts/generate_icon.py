#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math
import subprocess
import shutil


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
ICONSET = ASSETS / "ScreenAnnotator.iconset"
ICNS = ASSETS / "ScreenAnnotator.icns"
SOURCE = ASSETS / "ScreenAnnotator-1024.png"


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def gradient(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    pixels = img.load()
    for y in range(size):
        for x in range(size):
            nx = x / (size - 1)
            ny = y / (size - 1)
            glow = max(0, 1 - math.hypot(nx - 0.28, ny - 0.18) * 1.55)
            r = int(24 + 22 * glow + 12 * (1 - ny))
            g = int(35 + 30 * glow + 10 * nx)
            b = int(54 + 48 * glow + 22 * (1 - ny))
            pixels[x, y] = (r, g, b, 255)
    return img


def draw_line_with_glow(draw: ImageDraw.ImageDraw, points: list[tuple[int, int]], color: tuple[int, int, int, int], width: int) -> None:
    draw.line(points, fill=(color[0], color[1], color[2], 72), width=width + 20, joint="curve")
    draw.line(points, fill=color, width=width, joint="curve")


def draw_arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: tuple[int, int, int, int]) -> None:
    draw.line([start, end], fill=(color[0], color[1], color[2], 76), width=42)
    draw.line([start, end], fill=color, width=22)

    angle = math.atan2(end[1] - start[1], end[0] - start[0])
    length = 76
    spread = math.pi / 6.5
    left = (
        int(end[0] - length * math.cos(angle - spread)),
        int(end[1] - length * math.sin(angle - spread)),
    )
    right = (
        int(end[0] - length * math.cos(angle + spread)),
        int(end[1] - length * math.sin(angle + spread)),
    )
    draw.line([end, left], fill=(color[0], color[1], color[2], 76), width=42)
    draw.line([end, right], fill=(color[0], color[1], color[2], 76), width=42)
    draw.line([end, left], fill=color, width=22)
    draw.line([end, right], fill=color, width=22)


def make_source_icon() -> Image.Image:
    size = 1024
    base = gradient(size)

    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((74, 84, 950, 970), radius=218, fill=(0, 0, 0, 132))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))

    icon = Image.new("RGBA", (size, size), (16, 24, 38, 255))
    icon.alpha_composite(shadow)

    mask = rounded_mask(size, 228)
    icon.alpha_composite(base)
    icon.putalpha(mask)
    background = Image.new("RGBA", (size, size), (16, 24, 38, 255))
    background.alpha_composite(icon)
    icon = background

    draw = ImageDraw.Draw(icon)
    draw.rounded_rectangle((74, 74, 950, 950), radius=206, outline=(255, 255, 255, 42), width=5)

    panel = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    panel_draw = ImageDraw.Draw(panel)
    panel_draw.rounded_rectangle((176, 222, 848, 748), radius=64, fill=(244, 249, 255, 48), outline=(255, 255, 255, 88), width=5)
    panel_draw.rounded_rectangle((218, 268, 806, 704), radius=42, fill=(12, 18, 31, 82), outline=(255, 255, 255, 42), width=3)
    icon.alpha_composite(panel)

    draw = ImageDraw.Draw(icon)
    red = (255, 76, 84, 255)
    yellow = (255, 206, 84, 255)
    blue = (88, 181, 255, 255)

    draw.rounded_rectangle((282, 326, 672, 562), radius=28, fill=(255, 76, 84, 32), outline=(255, 76, 84, 255), width=24)
    draw.rounded_rectangle((270, 314, 684, 574), radius=34, outline=(255, 76, 84, 72), width=22)

    draw_arrow(draw, (332, 706), (698, 500), yellow)

    brush_points = [(302, 650), (378, 620), (448, 646), (522, 616), (608, 660), (704, 626)]
    draw_line_with_glow(draw, brush_points, blue, 22)

    step_center = (724, 318)
    draw.ellipse((step_center[0] - 58, step_center[1] - 58, step_center[0] + 58, step_center[1] + 58), fill=(255, 76, 84, 245), outline=(255, 255, 255, 230), width=9)
    # Minimal numeric mark, drawn as strokes to avoid font availability differences.
    draw.line([(710, 292), (730, 282), (730, 354)], fill=(255, 255, 255, 255), width=16)

    highlight = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    highlight_draw = ImageDraw.Draw(highlight)
    highlight_draw.ellipse((-220, -300, 760, 470), fill=(255, 255, 255, 36))
    highlight = highlight.filter(ImageFilter.GaussianBlur(12))
    icon.alpha_composite(highlight)

    return icon


def save_iconset(source: Image.Image) -> None:
    ASSETS.mkdir(exist_ok=True)
    if ICONSET.exists():
        shutil.rmtree(ICONSET)
    ICONSET.mkdir(exist_ok=True)
    source.convert("RGB").save(SOURCE)

    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]
    for pixels, name in sizes:
        subprocess.run(
            ["sips", "-z", str(pixels), str(pixels), str(SOURCE), "--out", str(ICONSET / name)],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    try:
        subprocess.run(["iconutil", "-c", "icns", str(ICONSET), "-o", str(ICNS)], check=True)
    except subprocess.CalledProcessError:
        if ICNS.exists():
            print(f"Reusing existing {ICNS}; iconutil could not regenerate it in this environment.")
        else:
            raise


def main() -> None:
    save_iconset(make_source_icon())
    print(f"Generated {ICNS}")


if __name__ == "__main__":
    main()
