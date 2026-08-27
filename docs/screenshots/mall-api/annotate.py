"""Annotate phone screenshots with MALL API 2026-05 change points.

Draws red rectangles + Chinese labels (via Noto Sans CJK) around the
visible UI elements driven by the new API fields.
"""
from __future__ import annotations

import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))


def _load_font(size: int) -> ImageFont.ImageFont:
    # Prefer a font that ships CJK glyphs on Windows.
    candidates = [
        r"C:\Windows\Fonts\msjh.ttc",      # 微軟正黑體
        r"C:\Windows\Fonts\msyh.ttc",      # 微軟雅黑
        r"C:\Windows\Fonts\msjh.ttf",
        r"C:\Windows\Fonts\arial.ttf",
    ]
    for p in candidates:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except OSError:
                continue
    return ImageFont.load_default()


def annotate(
    src: str,
    out: str,
    boxes: list[tuple[tuple[int, int, int, int], str, str]],
    *,
    title: str | None = None,
) -> None:
    """Draw rectangles + tagged labels on src image.

    boxes: list of (rect_xyxy, label_text, anchor_side)
        anchor_side is 'right' or 'left' indicating where to place the label.
    """
    img = Image.open(src).convert("RGBA")
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    label_font = _load_font(34)
    title_font = _load_font(48)

    for (x1, y1, x2, y2), label, side in boxes:
        # Red translucent fill + solid border so the box stays readable
        draw.rectangle((x1, y1, x2, y2), outline=(229, 30, 70, 255), width=6)
        draw.rectangle((x1, y1, x2, y2), fill=(229, 30, 70, 50))

        # Label tag: positioned to the side of the box so it doesn't
        # cover the change-point.
        tb = draw.textbbox((0, 0), label, font=label_font)
        tw, th = tb[2] - tb[0], tb[3] - tb[1]
        pad = 12
        bw, bh = tw + pad * 2, th + pad * 2
        if side == "right":
            lx = min(x2 + 24, img.width - bw - 16)
            ly = max(y1, 24)
            # If the right side has no room, push to the left of the box.
            if lx + bw > img.width - 16:
                lx = max(16, x1 - bw - 24)
        else:
            lx = max(16, x1 - bw - 24)
            ly = max(y1, 24)
        # Tag background + border + text
        draw.rectangle(
            (lx, ly, lx + bw, ly + bh),
            fill=(229, 30, 70, 235),
            outline=(255, 255, 255, 255),
            width=2,
        )
        draw.text(
            (lx + pad, ly + pad - tb[1]),
            label,
            font=label_font,
            fill=(255, 255, 255, 255),
        )

    if title:
        # Title banner across the top
        tb = draw.textbbox((0, 0), title, font=title_font)
        tw, th = tb[2] - tb[0], tb[3] - tb[1]
        pad = 18
        draw.rectangle(
            (0, 0, img.width, th + pad * 2),
            fill=(20, 20, 20, 220),
        )
        draw.text(
            ((img.width - tw) // 2, pad - tb[1]),
            title,
            font=title_font,
            fill=(255, 215, 0, 255),
        )

    composite = Image.alpha_composite(img, overlay).convert("RGB")
    composite.save(out, "PNG", optimize=True)
    print(f"[annotated] {out}")


def main() -> None:
    # 02_tap_shop.png  — Shop screen on 1080×2340 phone.
    # Coordinates measured from cropped inspection (see _card_below.png).
    # Source crop window (40,1500)-(700,1900) → in-crop offsets:
    #   • Title  "經典白色T恤（直播卡）"  y≈40-90  ⇒ source y=1540-1590
    #   • Price  "$1290 $1500"          y≈110-180 ⇒ source y=1610-1680
    #   • 已售   "已售 121"               y≈200-250 ⇒ source y=1700-1750
    annotate(
        os.path.join(HERE, "02_tap_shop.png"),
        os.path.join(HERE, "02_tap_shop_annotated.png"),
        boxes=[
            (
                # Tight box around "已售 121"
                (75, 1690, 220, 1755),
                "1  sold_amount → 已售 121",
                "right",
            ),
            (
                # Box around the price row ($1290 $1500) — original-price
                # strike-through driven by the same is_orderable / variant
                # data path.
                (75, 1600, 350, 1690),
                "2  ProductCard variant → 價格",
                "right",
            ),
        ],
        title="MALL API 2026-05  •  ProductCardResource 新欄位",
    )


if __name__ == "__main__":
    main()
