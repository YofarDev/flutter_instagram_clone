#!/usr/bin/env python3
"""Generate brand + dummy assets for the Instagram clone POC.

Usage: uv run --with pillow --with numpy scripts/seed/gen_assets.py
Writes into scripts/seed/assets/.

Brand icons/wordmarks are PIL-generated. Dummy media (avatars/posts/stories/
reels) is downloaded from pravatar.cc / picsum.photos with deterministic,
cache-stable filenames — re-runs skip files that already exist. If a download
fails (offline etc.), the slot falls back to the legacy PIL generator so the
script never hard-fails.
"""

from __future__ import annotations

import subprocess
import urllib.request
import zlib
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent / "assets"
FONT = Path(__file__).resolve().parents[2] / "assets/fonts/GrandHotel/GrandHotel-Regular.ttf"

# Instagram-ish gradient stops (top-left -> bottom-right)
STOPS = [
    (0x40, 0x5DE6, 0xEE),  # not used; replaced below
]
STOPS = [
    (0x51, 0x5B, 0xD4),  # blue
    (0x81, 0x34, 0xAF),  # purple
    (0xDD, 0x2A, 0x7B),  # pink
    (0xF5, 0x85, 0x29),  # orange
    (0xFE, 0xDA, 0x77),  # yellow
]


def gradient(size: int, stops: list[tuple[int, int, int]] = STOPS) -> Image.Image:
    """Diagonal multi-stop gradient."""
    t = np.linspace(0, 1, size)
    xx, yy = np.meshgrid(t, t)
    pos = (xx + yy) / 2  # 0..1 diagonal
    n = len(stops) - 1
    seg = np.clip(pos * n, 0, n - 1)
    i0 = seg.astype(int)
    i1 = np.minimum(i0 + 1, n)
    f = (seg - i0)[..., None]
    arr = np.array(stops, dtype=float)
    rgb = arr[i0] * (1 - f) + arr[i1] * f
    return Image.fromarray(rgb.astype(np.uint8), "RGB").resize((size, size), Image.BILINEAR)


def camera_glyph(size: int, stroke: int) -> Image.Image:
    """White Instagram-style camera outline on transparent square."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    inset = int(size * 0.14)
    # body
    d.rounded_rectangle(
        [inset, int(size * 0.26), size - inset, size - inset],
        radius=int(size * 0.22),
        outline=(255, 255, 255, 255),
        width=stroke,
    )
    # lens
    r = int(size * 0.17)
    cx = cy = size // 2
    d.ellipse(
        [cx - r, cy - r, cx + r, cy + r],
        outline=(255, 255, 255, 255),
        width=stroke,
    )
    # flash dot
    fr = int(size * 0.045)
    fx = int(size * 0.735)
    fy = int(size * 0.365)
    d.ellipse([fx - fr, fy - fr, fx + fr, fy + fr], fill=(255, 255, 255, 255))
    return img


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, *img.size], radius=radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def gen_icons() -> None:
    full = gradient(1024)
    glyph = camera_glyph(1024, 72)
    full_rgba = full.convert("RGBA")
    full_rgba.alpha_composite(glyph)
    rounded(full_rgba, 190).save(ROOT / "icon_full.png")

    gradient(1024).save(ROOT / "icon_bg.png")

    fg = camera_glyph(1024, 90)
    fg_small = fg.resize((int(1024 * 0.62),) * 2, Image.LANCZOS)
    canvas = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    off = (1024 - fg_small.width) // 2
    canvas.alpha_composite(fg_small, (off, off))
    canvas.save(ROOT / "icon_fg.png")


def gen_wordmarks() -> None:
    font = ImageFont.truetype(str(FONT), 300)
    for name, color in (("wordmark_dark.png", (38, 38, 38, 255)), ("wordmark_light.png", (255, 255, 255, 255))):
        tmp = Image.new("RGBA", (10, 10))
        box = ImageDraw.Draw(tmp).textbbox((0, 0), "Instagram", font=font)
        w, h = box[2] - box[0] + 80, box[3] - box[1] + 80
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        ImageDraw.Draw(img).text((40 - box[0], 40 - box[1]), "Instagram", font=font, fill=color)
        img.save(ROOT / name)


# ---------------------------------------------------------------------------
# Dummy media: downloads (deterministic slugs, cached) + PIL fallbacks.
# ---------------------------------------------------------------------------

USERS = [
    "alice", "bob", "chloe", "dave", "eve", "frank",
    "grace", "henry", "iris", "jack", "kate", "leo",
]

# 12 distinct pravatar ids (verified to resolve; pravatar has ~70).
PRAVATAR_IDS = [1, 3, 5, 7, 8, 9, 10, 11, 12, 13, 15, 16]

# 4:5 / 1:1 / 16:9 mix, cycled per post index.
POST_HEIGHTS = [1350, 1080, 810]

POSTS_PER_USER = 5
STORY_WORDS = ("sunset", "vibes", "code", "coffee", "travel", "mood") * 2
REEL_COUNT = 6
REEL_FRAMES = 5

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36"

fallbacks_used: list[str] = []


def fetch(url: str, dest: Path) -> bool:
    """Download url -> dest. One retry. Returns success."""
    for attempt in (1, 2):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = resp.read()
            if not data:
                raise ValueError("empty body")
            dest.write_bytes(data)
            return True
        except Exception as e:  # noqa: BLE001 — never hard-fail
            if attempt == 2:
                print(f"  download failed ({e}), using PIL fallback: {url}")
                return False
    return False


# --- legacy PIL generators (kept as offline fallbacks) ----------------------

LEGACY_GRADS = [
    ("alice", "A", (0xDD, 0x2A, 0x7B), (0xFD, 0x8A, 0x3C)),
    ("bob", "B", (0x51, 0x5B, 0xD4), (0x81, 0x34, 0xAF)),
    ("chloe", "C", (0xF5, 0x85, 0x29), (0xFE, 0xDA, 0x77)),
    ("dave", "D", (0x0F, 0x8B, 0x99), (0x51, 0x5B, 0xD4)),
    ("eve", "E", (0x8A, 0x2B, 0xE2), (0xDD, 0x2A, 0x7B)),
    ("frank", "F", (0xFE, 0xDA, 0x77), (0xF5, 0x85, 0x29)),
]

PALETTES = [
    ((0x51, 0x5B, 0xD4), (0xDD, 0x2A, 0x7B)),
    ((0xF5, 0x85, 0x29), (0xFE, 0xDA, 0x77)),
    ((0x0F, 0x8B, 0x99), (0x51, 0x5B, 0xD4)),
    ((0xDD, 0x2A, 0x7B), (0xFE, 0xDA, 0x77)),
    ((0x8A, 0x2B, 0xE2), (0xF5, 0x85, 0x29)),
    ((0x13, 0x52, 0x2B), (0x8F, 0xBC, 0x8F)),
]


def two_stop(size: int, a: tuple[int, int, int], b: tuple[int, int, int]) -> Image.Image:
    arr = np.zeros((size, size, 3), dtype=float)
    t = np.linspace(0, 1, size)[..., None]
    for c in range(3):
        arr[..., c] = a[c] * (1 - t) + b[c] * t
    return Image.fromarray(arr.astype(np.uint8), "RGB")


def art_image(seed: int, size: int) -> Image.Image:
    rng = np.random.default_rng(seed)
    a, b = PALETTES[seed % len(PALETTES)]
    base = two_stop(size, a, b)
    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    variant = seed % 3
    if variant == 0:  # translucent circles
        for _ in range(6):
            r = int(size * rng.uniform(0.08, 0.28))
            x, y = int(rng.uniform(0, size)), int(rng.uniform(0, size))
            alpha = int(rng.uniform(40, 110))
            d.ellipse([x - r, y - r, x + r, y + r], fill=(255, 255, 255, alpha))
    elif variant == 1:  # ring stack
        cx = cy = size // 2
        for i in range(5):
            r = int(size * (0.42 - i * 0.07))
            d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(255, 255, 255, 120), width=int(size * 0.02))
    else:  # diagonal bands
        for i in range(-2, 8):
            x = int(size * i / 5)
            d.polygon([(x, 0), (x + size // 4, 0), (x - size // 8, size), (x - size // 2, size)], fill=(255, 255, 255, int(rng.uniform(25, 70))))
    overlay = overlay.filter(ImageFilter.GaussianBlur(size * 0.004))
    out = base.convert("RGBA")
    out.alpha_composite(overlay)
    return out.convert("RGB")


def fallback_avatar(name: str, dest: Path) -> None:
    k = USERS.index(name)
    legacy = LEGACY_GRADS[k % len(LEGACY_GRADS)]
    _, initial, a, b = legacy
    font = ImageFont.truetype(str(FONT), 260)
    img = two_stop(512, a, b).convert("RGB")
    d = ImageDraw.Draw(img)
    box = d.textbbox((0, 0), initial, font=font)
    d.text(((512 - box[2] + box[0]) / 2 - box[0], (512 - box[3] + box[1]) / 2 - box[1] - 20), initial, font=font, fill=(255, 255, 255))
    img.save(dest, quality=85)
    fallbacks_used.append(str(dest))


def fallback_post(slug: str, dest: Path) -> None:
    seed = zlib.crc32(slug.encode()) % 10_000
    art_image(seed, 1080).save(dest, quality=85)
    fallbacks_used.append(str(dest))


def fallback_story(name: str, dest: Path) -> None:
    i = USERS.index(name) + 1
    a, b = PALETTES[(i + 2) % len(PALETTES)]
    base = two_stop(1280, a, b).resize((1080, 1920))
    overlay = Image.new("RGBA", (1080, 1920), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    for k in range(3):
        r = 300 - k * 90
        cx, cy = 540 + k * 45, 780 - k * 60
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(255, 255, 255, 140), width=40)
    font = ImageFont.truetype(str(FONT), 160)
    d.text((540, 1350), STORY_WORDS[i - 1], font=font, fill=(255, 255, 255, 230), anchor="mm")
    out = base.convert("RGBA")
    out.alpha_composite(overlay)
    out.convert("RGB").save(dest, quality=85)
    fallbacks_used.append(str(dest))


def fallback_frame(n: int, f: int, dest: Path) -> None:
    a, b = PALETTES[(n + f) % len(PALETTES)]
    two_stop(720, a, b).resize((720, 1280)).save(dest, quality=85)
    fallbacks_used.append(str(dest))


# --- download-or-fallback per media kind ------------------------------------


def cached(dest: Path) -> bool:
    return dest.exists() and dest.stat().st_size > 0


def gen_avatars() -> None:
    for name, img_id in zip(USERS, PRAVATAR_IDS, strict=True):
        dest = ROOT / "avatars" / f"{name}.jpg"
        if cached(dest):
            continue
        if not fetch(f"https://i.pravatar.cc/300?img={img_id}", dest):
            fallback_avatar(name, dest)


def gen_posts() -> None:
    for name in USERS:
        for i in range(1, POSTS_PER_USER + 1):
            slug = f"insta-{name}-{i}"
            dest = ROOT / "posts" / f"{slug}.jpg"
            if cached(dest):
                continue
            h = POST_HEIGHTS[(i - 1) % len(POST_HEIGHTS)]
            if not fetch(f"https://picsum.photos/seed/{slug}/1080/{h}", dest):
                fallback_post(slug, dest)


def gen_stories() -> None:
    for name in USERS:
        dest = ROOT / "stories" / f"story-{name}-1.jpg"
        if cached(dest):
            continue
        if not fetch(f"https://picsum.photos/seed/story-{name}-1/1080/1920", dest):
            fallback_story(name, dest)


def gen_reels() -> None:
    frames_dir = ROOT / "reels" / "frames"
    frames_dir.mkdir(parents=True, exist_ok=True)
    for n in range(1, REEL_COUNT + 1):
        out = ROOT / "reels" / f"r{n}.mp4"
        if cached(out):
            continue
        for f in range(1, REEL_FRAMES + 1):
            dest = frames_dir / f"r{n}_f{f}.jpg"
            if cached(dest):
                continue
            if not fetch(f"https://picsum.photos/seed/reel-{n}-{f}/720/1280", dest):
                fallback_frame(n, f, dest)
        # 5 frames @ 5/6 fps = ~6s clip, 30fps output, H.264 yuv420p (was lavfi
        # gradients before; same invocation style — subprocess + check=True).
        subprocess.run(
            [
                "ffmpeg", "-y",
                "-framerate", "5/6", "-i", str(frames_dir / f"r{n}_f%d.jpg"),
                "-vf", "scale=720:1280:flags=bicubic,format=yuv420p",
                "-r", "30", "-c:v", "libx264", "-an",
                str(out),
            ],
            check=True,
            capture_output=True,
        )


def main() -> None:
    for d in ("avatars", "posts", "stories", "reels"):
        (ROOT / d).mkdir(parents=True, exist_ok=True)
    gen_icons()
    gen_wordmarks()
    gen_avatars()
    gen_posts()
    gen_stories()
    gen_reels()
    files = sorted(p.relative_to(ROOT) for p in ROOT.rglob("*") if p.is_file())
    print(f"generated {len(files)} files")
    for f in files:
        print(f"  {f}")
    if fallbacks_used:
        print(f"PIL fallback used for {len(fallbacks_used)} file(s)")


if __name__ == "__main__":
    main()
