"""Render a marketing-style cover image for the Phase 1 deck."""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

W, H = 1280, 720
OUT = Path(__file__).parent / "images" / "phase1-deck-cover.png"

INDIGO = (65, 86, 200)
INDIGO_DARK = (40, 53, 130)
INK = (20, 24, 48)
SUBTLE = (90, 100, 140)
ACCENT = (255, 196, 87)
PAPER = (255, 255, 255)

def font(size, bold=False):
    name = "calibrib.ttf" if bold else "calibri.ttf"
    for p in (rf"C:\Windows\Fonts\{name}", rf"C:\Windows\Fonts\segoeui{'b' if bold else ''}.ttf"):
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            continue
    return ImageFont.load_default()

img = Image.new("RGB", (W, H), PAPER)
d = ImageDraw.Draw(img)

# Left indigo panel
PANEL_W = 540
for y in range(H):
    t = y / H
    r = int(INDIGO[0] * (1 - t * 0.35) + INDIGO_DARK[0] * (t * 0.35))
    g = int(INDIGO[1] * (1 - t * 0.35) + INDIGO_DARK[1] * (t * 0.35))
    b = int(INDIGO[2] * (1 - t * 0.35) + INDIGO_DARK[2] * (t * 0.35))
    d.line([(0, y), (PANEL_W, y)], fill=(r, g, b))

# Decorative circles
d.ellipse([-120, -120, 200, 200], outline=(255, 255, 255, 60), width=3)
d.ellipse([PANEL_W - 180, H - 180, PANEL_W + 140, H + 140], outline=(255, 255, 255, 60), width=3)

# Left panel content
d.text((48, 70), "ROS 2", font=font(48, True), fill=ACCENT)
d.text((48, 130), "FUNDAMENTALS", font=font(36, True), fill=PAPER)
d.text((48, 180), "Internalization Deck", font=font(26), fill=(220, 225, 255))

# Big "1" badge
badge_x, badge_y, badge_r = 270, 360, 130
d.ellipse([badge_x - badge_r, badge_y - badge_r, badge_x + badge_r, badge_y + badge_r],
          fill=ACCENT)
d.text((badge_x, badge_y), "1", font=font(180, True), fill=INDIGO_DARK, anchor="mm")
d.text((badge_x, badge_y + badge_r + 30), "PHASE", font=font(20, True), fill=PAPER, anchor="mm")

# Bottom tag
d.text((48, H - 60), "18 slides · 15–20 min", font=font(20), fill=(200, 210, 255))

# Right side content
RX = PANEL_W + 50
d.text((RX, 80), "What you'll lock in", font=font(36, True), fill=INK)
d.line([(RX, 135), (RX + 200, 135)], fill=ACCENT, width=4)

bullets = [
    ("🕸️", "The ROS 2 graph", "nodes + topics, end-to-end"),
    ("🔁", "3 patterns", "topics vs services vs actions"),
    ("💻", "Pub/sub pattern", "the Python skeleton you'll reuse"),
    ("🗂️", "Workspace anatomy", "what colcon actually does"),
    ("🧾", "CLI cheat-sheet", "every ros2 verb on one page"),
    ("🧠", "Recall test", "8 questions + 5 mental models"),
]

y = 175
for emoji, title, sub in bullets:
    # bullet dot
    d.ellipse([RX, y + 10, RX + 14, y + 24], fill=INDIGO)
    d.text((RX + 30, y + 4), title, font=font(22, True), fill=INK)
    d.text((RX + 30, y + 34), sub, font=font(18), fill=SUBTLE)
    y += 72

# Footer band
d.rectangle([PANEL_W, H - 60, W, H], fill=(245, 247, 255))
d.text((RX, H - 42), "Concept-first · Code-light · Mobile-friendly",
       font=font(18, True), fill=INDIGO_DARK)
d.text((W - 50, H - 42), "📊", font=font(28), fill=INDIGO, anchor="ra")

OUT.parent.mkdir(exist_ok=True)
img.save(OUT, "PNG", optimize=True)
print(f"Wrote {OUT} ({OUT.stat().st_size // 1024} KB)")
