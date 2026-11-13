#!/usr/bin/env python3
"""Build the iOS icon set from the Play icon. Does not edit the source PNG."""
import pathlib
import sys

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parents[2]
SRC = ROOT / "play" / "graphics" / "icon-512.png"
ICON_DIR = ROOT / "ios" / "Strikeout" / "Assets.xcassets" / "AppIcon.appiconset"
LAUNCH_DIR = ROOT / "ios" / "Strikeout" / "Assets.xcassets" / "LaunchMark.imageset"
STORE = ROOT / "appstore" / "icon-1024.png"

# Play art is 512 RGBA. Corners are opaque #2A1D0A (the app ink), not #2A1D0C.
BROWN = (0x2A, 0x1D, 0x0A)

SIZES = {
    "icon-20@2x.png": 40,
    "icon-20@3x.png": 60,
    "icon-29@2x.png": 58,
    "icon-29@3x.png": 87,
    "icon-40@2x.png": 80,
    "icon-40@3x.png": 120,
    "icon-60@2x.png": 120,
    "icon-60@3x.png": 180,
    "icon-1024.png": 1024,
}


def flatten(im: Image.Image) -> Image.Image:
    base = Image.new("RGB", im.size, BROWN)
    if im.mode == "RGBA":
        base.paste(im, mask=im.getchannel("A"))
    else:
        base.paste(im.convert("RGB"))
    return base


def rounded(im: Image.Image, radius_ratio: float = 0.2237) -> Image.Image:
    """Launch mark only. The App Store icon stays square; iOS masks that one."""
    im = im.convert("RGBA")
    w, h = im.size
    r = int(round(min(w, h) * radius_ratio))
    mask = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, w - 1, h - 1), radius=r, fill=255)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.paste(im, mask=mask)
    return out


def main() -> None:
    if not SRC.is_file():
        sys.exit(f"missing {SRC}")
    src = Image.open(SRC)
    flat = flatten(src)
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    LAUNCH_DIR.mkdir(parents=True, exist_ok=True)
    for name, px in SIZES.items():
        icon = flat.resize((px, px), Image.Resampling.LANCZOS)
        if icon.mode != "RGB":
            sys.exit(f"{name} still has alpha")
        icon.save(ICON_DIR / name, format="PNG", optimize=True)
        if name == "icon-1024.png":
            STORE.parent.mkdir(parents=True, exist_ok=True)
            icon.save(STORE, format="PNG", optimize=True)
    # 180pt tile. Transparent corners so the cream launch color shows through.
    for filename, px in (("launch-mark.png", 180), ("launch-mark@2x.png", 360), ("launch-mark@3x.png", 540)):
        tile = flat.resize((px, px), Image.Resampling.LANCZOS)
        rounded(tile).save(LAUNCH_DIR / filename, format="PNG", optimize=True)
    print(f"icons: {ICON_DIR}")
    print(f"store: {STORE}")


if __name__ == "__main__":
    main()
