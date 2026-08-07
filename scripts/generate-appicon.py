#!/usr/bin/env python3
"""
PackWise — AppIcon generator (pure Python stdlib, no PIL).

Draws the 1024×1024 app icon used by Assets.xcassets/AppIcon.appiconset:
an espresso-leather rounded square with a cream isometric-flat suitcase,
amber strap and subtle depth. Every pixel is computed — the icon is code.

Usage:
    python3 scripts/generate-appicon.py
    # writes ios/PackWise/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
"""
import math
import os
import struct
import sys
import zlib

SIZE = 1024
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(
    ROOT,
    "ios/PackWise/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png",
)

# --------------------------------------------------------------------------
# tiny PNG writer (RGBA8, no filters)
# --------------------------------------------------------------------------
def write_png(path, w, h, rgba):
    def chunk(tag, data):
        c = tag + data
        return (
            struct.pack(">I", len(data))
            + c
            + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
        )

    raw = bytearray()
    stride = w * 4
    for y in range(h):
        raw.append(0)  # filter: none
        raw.extend(rgba[y * stride : (y + 1) * stride])
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


# --------------------------------------------------------------------------
# math helpers (SDFs for anti-aliased shapes)
# --------------------------------------------------------------------------
def sd_round_rect(x, y, cx, cy, hw, hh, r):
    dx = abs(x - cx) - (hw - r)
    dy = abs(y - cy) - (hh - r)
    ax, ay = max(dx, 0.0), max(dy, 0.0)
    return math.hypot(ax, ay) + min(max(dx, dy), 0.0) - r


def sd_circle(x, y, cx, cy, r):
    return math.hypot(x - cx, y - cy) - r


def cov(d, aa=1.4):
    """Smooth coverage from an SDF distance."""
    return min(1.0, max(0.0, 0.5 - d / aa))


def lerp(a, b, t):
    return a + (b - a) * t


# --------------------------------------------------------------------------
# canvas
# --------------------------------------------------------------------------
buf = [0.0, 0.0, 0.0, 0.0] * (SIZE * SIZE)


def blend(x, y, r, g, b, a):
    """Source-over composite, premultiplied math, a in 0..1."""
    if a <= 0 or not (0 <= x < SIZE and 0 <= y < SIZE):
        return
    i = (int(y) * SIZE + int(x)) * 4
    da = buf[i + 3]
    out_a = a + da * (1.0 - a)
    if out_a <= 0:
        return
    buf[i] = (r * a + buf[i] * da * (1.0 - a)) / out_a
    buf[i + 1] = (g * a + buf[i + 1] * da * (1.0 - a)) / out_a
    buf[i + 2] = (b * a + buf[i + 2] * da * (1.0 - a)) / out_a
    buf[i + 3] = out_a


# --------------------------------------------------------------------------
# 1) background: espresso rounded square, vertical gradient + top-left glow
# --------------------------------------------------------------------------
for y in range(SIZE):
    t = y / (SIZE - 1)
    # #3a2a1b -> #1a110b
    bg_r, bg_g, bg_b = lerp(0x3A, 0x1A, t), lerp(0x2A, 0x11, t), lerp(0x1B, 0x0B, t)
    for x in range(SIZE):
        d = sd_round_rect(x + 0.5, y + 0.5, 512, 512, 500, 500, 190)
        a = cov(d)
        if a > 0:
            # warm radial glow, top-left
            gd = sd_circle(x + 0.5, y + 0.5, 330, 300, 700)
            glow = max(0.0, 1.0 - max(0.0, gd) / 700.0)
            blend(x, y, bg_r + 30 * glow, bg_g + 22 * glow, bg_b + 12 * glow, a)


# 2) suitcase shadow
for y in range(SIZE):
    for x in range(SIZE):
        d = sd_circle(x + 0.5, y + 0.5, 512, 806, 330)
        d = max(d, abs((x + 0.5) - 512) - 300)
        d = max(d, abs((y + 0.5) - 806) * 3.2 - 58)
        a = cov(d, 4.0) * 0.34
        if a > 0:
            blend(x, y, 0, 0, 0, a)


# 3) suitcase body (cream, subtle vertical gradient)
BODY_CY, BODY_HW, BODY_HH, BODY_R = 566, 332, 244, 46
for y in range(SIZE):
    for x in range(SIZE):
        d = sd_round_rect(x + 0.5, y + 0.5, 512, BODY_CY, BODY_HW, BODY_HH, BODY_R)
        a = cov(d)
        if a <= 0:
            continue
        t = (y - (BODY_CY - BODY_HH)) / (2 * BODY_HH)
        cr = lerp(0xF7, 0xE2, t)
        cg = lerp(0xEC, 0xCB, t)
        cb = lerp(0xD7, 0xAD, t)
        # top-left sheen
        sheen = max(0.0, 1.0 - sd_circle(x + 0.5, y + 0.5, 330, 400, 460) / 460.0)
        cr += 14 * sheen
        cg += 12 * sheen
        cb += 10 * sheen
        blend(x, y, cr, cg, cb, a)


# 4) zipper line (darker seam across the body)
for y in range(SIZE):
    for x in range(SIZE):
        d = abs((y + 0.5) - 656) - 2.0
        d = max(d, sd_round_rect(x + 0.5, y + 0.5, 512, BODY_CY, BODY_HW - 18, BODY_HH - 10, 40))
        d = -d if d < 0 else d  # keep inside body
        a = cov(d, 1.2) * 0.5
        if a > 0:
            blend(x, y, 0x8A, 0x6A, 0x45, a)


# 5) amber strap (vertical) + buckle
for y in range(SIZE):
    for x in range(SIZE):
        d = max(abs((x + 0.5) - 512) - 58, abs((y + 0.5) - 566) - 236)
        a = cov(d)
        if a > 0:
            blend(x, y, 0xD9, 0x77, 0x06, a)
        # darker strap edges
        e = max(abs((x + 0.5) - 512) - 60, abs((y + 0.5) - 566) - 236)
        e = abs(e) if e < 0 else 999
        ea = cov(e - 4.5, 1.2) * 0.35
        if ea > 0:
            blend(x, y, 0x92, 0x4E, 0x05, ea)
        # buckle: dark leather square with cream slot
        bd = sd_round_rect(x + 0.5, y + 0.5, 512, 566, 84, 74, 16)
        ba = cov(bd) * 0.92
        if ba > 0:
            blend(x, y, 0x7C, 0x2D, 0x12, ba)
        hole = sd_round_rect(x + 0.5, y + 0.5, 512, 566, 40, 32, 8)
        ha = cov(hole)
        if ha > 0:
            blend(x, y, 0xF3, 0xE6, 0xCF, ha)


# 6) handle above body
for y in range(SIZE):
    for x in range(SIZE):
        d = sd_round_rect(x + 0.5, y + 0.5, 512, 320, 96, 34, 26)
        a = cov(d)
        if a > 0:
            t = (y - 286) / 68
            blend(x, y, lerp(0xF7, 0xE6, t), lerp(0xEC, 0xD3, t), lerp(0xD7, 0xB5, t), a)
        # inner gap of the handle (transparent -> shows background)
        g = sd_round_rect(x + 0.5, y + 0.5, 512, 320, 62, 16, 12)
        ga = cov(g)
        if ga > 0:
            # punch through: recompute background gradient
            t = y / (SIZE - 1)
            blend(x, y, lerp(0x3A, 0x1A, t), lerp(0x2A, 0x11, t), lerp(0x1B, 0x0B, t), ga)


# 7) vignette for depth (subtle dark edge)
for y in range(SIZE):
    for x in range(SIZE):
        d = sd_round_rect(x + 0.5, y + 0.5, 512, 512, 470, 470, 170)
        a = cov(d, 6.0) * 0.16
        if a > 0:
            blend(x, y, 0x0B, 0x07, 0x04, a)


# --------------------------------------------------------------------------
rgba = bytearray()
for i in range(0, len(buf), 4):
    rgba.append(min(255, max(0, round(buf[i]))))
    rgba.append(min(255, max(0, round(buf[i + 1]))))
    rgba.append(min(255, max(0, round(buf[i + 2]))))
    rgba.append(min(255, max(0, round(buf[i + 3] * 255))))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
write_png(OUT, SIZE, SIZE, rgba)
print(f"✓ wrote {OUT} ({os.path.getsize(OUT)} bytes, {SIZE}x{SIZE})")
