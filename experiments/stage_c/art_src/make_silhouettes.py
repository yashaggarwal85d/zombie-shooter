"""EXPERIMENT (Stage C, C2/C3). Draws the placeholder silhouettes as PNGs.

Original shapes made for this project (no third-party art). Pure black on
transparent: light, rim and fog come from shaders in the engine, which is
the D4 art approach. Run: python3 make_silhouettes.py <out_dir>
"""
import math
import random
import sys
from PIL import Image, ImageDraw

SS = 4  # supersampling factor


def canvas(w, h):
    img = Image.new("L", (w * SS, h * SS), 0)
    return img, ImageDraw.Draw(img)


def s(p):
    return (p[0] * SS, p[1] * SS)


def limb(d, pts, w0, w1=None):
    """Tapered limb through points, width w0 at the start to w1 at the end."""
    w1 = w0 if w1 is None else w1
    n = len(pts) - 1
    for i in range(n):
        a, b = pts[i], pts[i + 1]
        ra = (w0 + (w1 - w0) * i / n) / 2
        rb = (w0 + (w1 - w0) * (i + 1) / n) / 2
        dx, dy = b[0] - a[0], b[1] - a[1]
        ln = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / ln, dx / ln
        poly(d, [(a[0] + nx * ra, a[1] + ny * ra), (b[0] + nx * rb, b[1] + ny * rb),
                 (b[0] - nx * rb, b[1] - ny * rb), (a[0] - nx * ra, a[1] - ny * ra)])
        ellipse(d, a, ra, ra)
        ellipse(d, b, rb, rb)


def poly(d, pts):
    d.polygon([s(p) for p in pts], fill=255)


def ellipse(d, c, rx, ry):
    d.ellipse([s((c[0] - rx, c[1] - ry)), s((c[0] + rx, c[1] + ry))], fill=255)


def rags(d, x0, x1, y, length, rng, count=7, lean=0.0):
    for i in range(count):
        x = x0 + (x1 - x0) * (i + rng.random() * 0.6) / count
        l = length * (0.5 + rng.random())
        w = 3 + rng.random() * 4
        poly(d, [(x - w, y - 2), (x + w, y - 2), (x + lean * l + rng.uniform(-2, 2), y + l)])


def finish(img, path, w, h):
    small = img.resize((w, h), Image.LANCZOS)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.putalpha(small)
    out.save(path)


def shambler(path):
    rng = random.Random(3)
    w, h = 160, 300
    img, d = canvas(w, h)
    limb(d, [(76, 196), (66, 244), (58, 292)], 15, 9)
    limb(d, [(92, 194), (104, 246), (98, 292)], 14, 9)
    ellipse(d, (54, 293), 10, 4)
    ellipse(d, (104, 293), 9, 4)
    poly(d, [(62, 206), (102, 202), (114, 156), (126, 118), (110, 94), (78, 98), (58, 140)])
    limb(d, [(108, 104), (126, 106)], 13, 11)
    ellipse(d, (132, 110), 14, 16)
    limb(d, [(118, 114), (138, 150), (150, 182)], 11, 7)
    for a in (-0.5, 0.0, 0.5):
        limb(d, [(150, 182), (150 + 12 * math.sin(a + 0.3), 182 + 12 * math.cos(a + 0.3))], 3, 1.5)
    limb(d, [(84, 106), (74, 160), (82, 210)], 10, 6)
    for a in (-0.4, 0.2):
        limb(d, [(82, 210), (82 + 10 * math.sin(a), 210 + 11 * math.cos(a))], 3, 1.5)
    rags(d, 60, 104, 204, 16, rng, 8, lean=-0.3)
    rags(d, 70, 86, 150, 30, rng, 2, lean=-0.6)  # torn strip off the back
    finish(img, path, w, h)


def runner(path):
    rng = random.Random(5)
    w, h = 200, 280
    img, d = canvas(w, h)
    limb(d, [(84, 170), (118, 214), (142, 270)], 12, 7)  # front leg
    limb(d, [(80, 172), (54, 216), (20, 236)], 12, 7)  # back leg kicking
    ellipse(d, (146, 272), 9, 3)
    poly(d, [(72, 182), (96, 176), (140, 118), (150, 96), (134, 86), (80, 140)])
    limb(d, [(140, 98), (158, 92)], 10, 9)
    ellipse(d, (164, 92), 12, 13)
    limb(d, [(138, 102), (166, 130), (190, 126)], 8, 5)
    limb(d, [(126, 108), (100, 132), (74, 120)], 8, 5)
    rags(d, 74, 96, 178, 14, rng, 4, lean=-1.2)
    finish(img, path, w, h)


def protagonist(path):
    rng = random.Random(9)
    w, h = 170, 300
    img, d = canvas(w, h)
    limb(d, [(72, 200), (68, 248), (64, 292)], 14, 10)
    limb(d, [(92, 200), (100, 248), (102, 292)], 14, 10)
    ellipse(d, (66, 293), 11, 4)
    ellipse(d, (106, 293), 11, 4)
    # Long coat, slightly flared at the hem.
    poly(d, [(54, 238), (112, 234), (104, 150), (102, 100), (64, 98), (58, 150)])
    rags(d, 54, 112, 234, 10, rng, 6, lean=-0.4)
    # Hooded head: a rounded hood with a peak at the back.
    ellipse(d, (86, 78), 15, 17)
    poly(d, [(72, 70), (60, 92), (76, 98), (84, 62)])
    # Scarf: one thick, wavy tail behind.
    limb(d, [(72, 98), (58, 104), (46, 100), (34, 110)], 10, 4)
    # Rifle at the hip, pointing right: stock, body, barrel.
    poly(d, [(56, 150), (76, 140), (82, 156), (62, 166)])
    poly(d, [(76, 140), (128, 132), (130, 142), (80, 152)])
    limb(d, [(128, 136), (164, 131)], 4, 3)
    poly(d, [(100, 146), (106, 145), (108, 160), (102, 161)])
    limb(d, [(98, 106), (106, 134), (122, 138)], 11, 8)
    limb(d, [(70, 108), (68, 136), (84, 148)], 11, 8)
    finish(img, path, w, h)


if __name__ == "__main__":
    out = sys.argv[1]
    shambler(f"{out}/shambler.png")
    runner(f"{out}/runner.png")
    protagonist(f"{out}/protagonist.png")
