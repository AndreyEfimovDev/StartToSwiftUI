#!/usr/bin/env python3
"""Генерация universal creative asset (16:9, 5244×2950) для App Store:
product page header + search results.

Запуск из корня репозитория (системный Python — Pillow установлен для него,
а `python3` из Homebrew его не видит):
    /usr/bin/python3 AppStoreAssets/make_creative_asset.py

Результат в AppStoreAssets/out/:
    universal_5244x2950.png — файл для загрузки в App Store Connect (RGB, без альфы);
    preview_overlay.png     — уменьшенная копия с безопасной зоной и обрезками 21:9 / 3:2.

Общие функции (фон, фактура, устройства, слоган) использует и make_creative_video.py.
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent
RAW = ROOT / "raw"
OUT = ROOT / "out"
APP_ICON = ROOT.parent / "StartToSwiftUI/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

# Фирменные цвета: фон иконки #3366FF, к краям — темнее.
BRAND = (0x33, 0x66, 0xFF)
BRAND_DARK = (0x1E, 0x3F, 0xB8)
WHITE = (255, 255, 255)
SHADOW = (8, 20, 70)

FONT_PATH = "/System/Library/Fonts/SFNS.ttf"

IPHONE_SHOT = RAW / "iphone.webp"
# Ландшафтный iPad-кадр используется, если файл есть; иначе — портретный.
IPAD_LANDSCAPE_SHOT = RAW / "ipad_landscape.png"
IPAD_PORTRAIT_SHOT = RAW / "ipad.webp"

# Доля ширины iPhone, заходящая на портретный iPad.
IPHONE_OVERLAP = 0.45


@dataclass(frozen=True)
class Layout:
    """Геометрия одного формата ассета: холст, безопасная зона, слоган, устройства, фактура."""

    size: tuple[int, int]
    safe: tuple[int, int, int, int]
    slogan: tuple[str, ...]
    slogan_max_size: int
    ipad_screen_height: int
    iphone_screen_height: int
    iphone_drop: int
    devices_gap: int
    glyphs: tuple[tuple[int, int, int, float], ...]  # (высота, левый край, верх, непрозрачность)
    scale: float = 1.0  # Масштаб относительно universal — для теней и амплитуд движения.

    @property
    def center_x(self) -> int:
        """Горизонтальный центр холста."""
        return self.size[0] // 2


# Безопасная зона — из шаблона Apple «Universal Asset Template» (слой «Art Safe Area»).
UNIVERSAL = Layout(
    size=(5244, 2950),
    safe=(1921, 660, 3323, 1622),
    slogan=("Learn SwiftUI", "your way"),
    slogan_max_size=240,
    ipad_screen_height=2100,
    iphone_screen_height=1900,
    iphone_drop=180,
    devices_gap=90,
    glyphs=((2600, -700, 900, 0.10), (2200, 3900, -350, 0.08)),
)


def scaled_layout(size: tuple[int, int], safe: tuple[int, int, int, int], slogan: tuple[str, ...]) -> Layout:
    """Строит раскладку другого формата, масштабируя universal по высоте холста.

    Глифы левой половины привязываются к левому краю, правой — к правому,
    чтобы фактура оставалась у краёв при любом соотношении сторон.

    - Parameters:
      - size: размер холста.
      - safe: безопасная зона из шаблона Apple для этого формата.
      - slogan: строки слогана.
    - Returns: раскладка для нового формата.
    """
    s = size[1] / UNIVERSAL.size[1]
    base_w = UNIVERSAL.size[0]
    glyphs = tuple(
        (
            round(height * s),
            round(left * s) if left < base_w / 2 else size[0] - round((base_w - left) * s),
            round(top * s),
            alpha,
        )
        for height, left, top, alpha in UNIVERSAL.glyphs
    )
    return Layout(
        size=size,
        safe=safe,
        slogan=slogan,
        slogan_max_size=round(UNIVERSAL.slogan_max_size * s),
        ipad_screen_height=round(UNIVERSAL.ipad_screen_height * s),
        iphone_screen_height=round(UNIVERSAL.iphone_screen_height * s),
        iphone_drop=round(UNIVERSAL.iphone_drop * s),
        devices_gap=round(UNIVERSAL.devices_gap * s),
        glyphs=glyphs,
        scale=s,
    )


def radial_background(size: tuple[int, int]) -> Image.Image:
    """Создаёт фон с радиальным градиентом от фирменного синего в центре к тёмному по краям.

    - Parameter size: размер холста.
    - Returns: RGB-изображение размером холста.
    """
    # Градиент считаем в малом разрешении и растягиваем — это быстро и даёт плавный переход.
    sw, sh = size[0] // 10, size[1] // 10
    small = Image.new("RGB", (sw, sh))
    cx, cy = sw / 2, sh * 0.42
    max_d = ((sw / 2) ** 2 + (sh * 0.6) ** 2) ** 0.5
    px = small.load()
    for y in range(sh):
        for x in range(sw):
            t = min(1.0, (((x - cx) ** 2 + (y - cy) ** 2) ** 0.5) / max_d)
            t = t * t
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(BRAND, BRAND_DARK))
    return small.resize(size, Image.LANCZOS)


@lru_cache(maxsize=1)
def icon_glyph_mask() -> Image.Image:
    """Вырезает из иконки приложения белый символ «A» (без подписи) как маску.

    - Returns: L-маска символа, обрезанная по его границам.
    """
    icon = Image.open(APP_ICON).convert("RGB")
    # Подпись «StartToSwiftUI» начинается ниже ~800 px — её отрезаем, оставляя только «A».
    glyph = icon.crop((0, 0, icon.width, 800))
    mask = glyph.convert("L").point(lambda v: 255 if v > 200 else 0)
    return mask.crop(mask.getbbox())


def glyph_sprite(height: int, alpha: float) -> Image.Image:
    """Готовит маску «A» нужной высоты с заданной непрозрачностью.

    - Parameters:
      - height: высота глифа в пикселях холста.
      - alpha: непрозрачность 0…1.
    - Returns: L-маска для заливки белым.
    """
    mask = icon_glyph_mask()
    scaled = mask.resize((round(mask.width * height / mask.height), height), Image.LANCZOS)
    return scaled.point(lambda v: round(v * alpha))


def add_glyph_texture(canvas: Image.Image, layout: Layout) -> None:
    """Накладывает крупные полупрозрачные «A» по краям холста как фирменную фактуру.

    Глифы стоят вне безопасной зоны: их обрезка на узких кадрах не страшна.

    - Parameters:
      - canvas: RGB-холст, изменяется на месте.
      - layout: раскладка формата.
    """
    for height, left, top, alpha in layout.glyphs:
        canvas.paste(WHITE, (left, top), glyph_sprite(height, alpha))


def device(shot: Image.Image, screen_height: int, screen_width: int | None = None) -> Image.Image:
    """Рисует устройство: скриншот в скруглённой тёмной рамке.

    - Parameters:
      - shot: скриншот экрана.
      - screen_height: итоговая высота экрана в пикселях холста.
      - screen_width: итоговая ширина экрана; по умолчанию — по пропорциям скриншота.
        Нужна, чтобы кадры одного устройства получались одного размера для перехода между ними.
    - Returns: RGBA-изображение устройства с прозрачными углами.
    """
    sw = screen_width or round(shot.width * screen_height / shot.height)
    screen = shot.convert("RGB").resize((sw, screen_height), Image.LANCZOS)
    bezel = round(min(sw, screen_height) * 0.035)
    radius = round(min(sw, screen_height) * 0.11)
    dw, dh = sw + 2 * bezel, screen_height + 2 * bezel

    body = Image.new("RGBA", (dw, dh), (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle((0, 0, dw - 1, dh - 1), radius + bezel, fill=(22, 22, 26, 255))
    screen_mask = Image.new("L", (sw, screen_height), 0)
    ImageDraw.Draw(screen_mask).rounded_rectangle((0, 0, sw - 1, screen_height - 1), radius, fill=255)
    body.paste(screen, (bezel, bezel), screen_mask)
    return body


def shadow_mask(item: Image.Image, scale: float) -> tuple[Image.Image, int]:
    """Строит размытую маску тени под RGBA-элементом.

    - Parameters:
      - item: RGBA-элемент (устройство).
      - scale: масштаб формата относительно universal.
    - Returns: L-маска тени и отступ, на который она шире элемента с каждой стороны.
    """
    pad = round(160 * scale)
    mask = Image.new("L", (item.width + 2 * pad, item.height + 2 * pad), 0)
    mask.paste(item.getchannel("A").point(lambda v: v * 0.45), (pad, pad + round(50 * scale)))
    return mask.filter(ImageFilter.GaussianBlur(70 * scale)), pad


def paste_with_shadow(canvas: Image.Image, item: Image.Image, pos: tuple[int, int], scale: float = 1.0) -> None:
    """Вставляет RGBA-элемент на холст с мягкой тенью под ним.

    - Parameters:
      - canvas: RGB-холст, изменяется на месте.
      - item: RGBA-элемент (устройство).
      - pos: левый верхний угол элемента на холсте.
      - scale: масштаб формата относительно universal.
    """
    mask, pad = shadow_mask(item, scale)
    canvas.paste(SHADOW, (pos[0] - pad, pos[1] - pad), mask)
    canvas.paste(item, pos, item)


def fitting_font(lines: tuple[str, ...], max_width: int, start_size: int) -> ImageFont.FreeTypeFont:
    """Подбирает самый крупный жирный шрифт, при котором каждая строка помещается в ширину.

    - Parameters:
      - lines: строки слогана.
      - max_width: допустимая ширина строки.
      - start_size: начальный (максимальный) кегль.
    - Returns: шрифт SF Pro Bold подходящего кегля.
    """
    size = start_size
    while True:
        font = ImageFont.truetype(FONT_PATH, size)
        font.set_variation_by_name("Bold")
        if all(font.getlength(line) <= max_width for line in lines) or size <= 40:
            return font
        size -= 4


def slogan_mask(layout: Layout) -> tuple[Image.Image, int]:
    """Рисует слоган по центру в верхней части безопасной зоны как маску размером холста.

    - Parameter layout: раскладка формата.
    - Returns: L-маска текста и координата Y его нижней границы.
    """
    safe = layout.safe
    font = fitting_font(layout.slogan, max_width=safe[2] - safe[0] - round(120 * layout.scale),
                        start_size=layout.slogan_max_size)
    mask = Image.new("L", layout.size, 0)
    draw = ImageDraw.Draw(mask)
    line_height = round(font.size * 1.08)
    y = safe[1] + round(40 * layout.scale)
    for line in layout.slogan:
        draw.text((layout.center_x, y), line, font=font, fill=255, anchor="mt")
        y += line_height
    return mask, y


def draw_slogan(canvas: Image.Image, layout: Layout) -> int:
    """Рисует слоган на холсте.

    - Parameters:
      - canvas: RGB-холст, изменяется на месте.
      - layout: раскладка формата.
    - Returns: координата Y нижней границы текста.
    """
    mask, bottom = slogan_mask(layout)
    canvas.paste(WHITE, (0, 0), mask)
    return bottom


def devices_origin(layout: Layout, ipad_width: int, iphone_width: int, top: int) -> tuple[tuple[int, int], tuple[int, int]]:
    """Считает позиции iPad (сзади) и iPhone (спереди), центрируя группу по горизонтали.

    - Parameters:
      - layout: раскладка формата.
      - ipad_width: ширина iPad с рамкой.
      - iphone_width: ширина iPhone с рамкой.
      - top: Y верхнего края iPad.
    - Returns: левые верхние углы iPad и iPhone.
    """
    group_width = ipad_width + round(iphone_width * (1 - IPHONE_OVERLAP))
    ipad_x = layout.center_x - group_width // 2
    iphone_x = ipad_x + ipad_width - round(iphone_width * IPHONE_OVERLAP)
    return (ipad_x, top), (iphone_x, top + layout.iphone_drop)


def compose_devices(canvas: Image.Image, layout: Layout, top: int) -> None:
    """Размещает iPad (сзади) и iPhone (спереди) группой по центру, начиная с заданного Y.

    Верхние части экранов попадают в безопасную зону, низ уходит за её пределы —
    как фигуры в примере из шаблона Apple.

    - Parameters:
      - canvas: RGB-холст, изменяется на месте.
      - layout: раскладка формата.
      - top: Y верхнего края iPad.
    """
    iphone = device(Image.open(IPHONE_SHOT), screen_height=layout.iphone_screen_height)
    if IPAD_LANDSCAPE_SHOT.exists():
        ipad = device(Image.open(IPAD_LANDSCAPE_SHOT), screen_height=round(1500 * layout.scale))
        ipad_pos = (layout.center_x - (ipad.width + round(iphone.width * 0.7)) // 2, top)
        iphone_pos = (ipad_pos[0] + ipad.width - round(iphone.width * 0.30), top + layout.iphone_drop)
    else:
        ipad = device(Image.open(IPAD_PORTRAIT_SHOT), screen_height=layout.ipad_screen_height)
        ipad_pos, iphone_pos = devices_origin(layout, ipad.width, iphone.width, top)
    paste_with_shadow(canvas, ipad, ipad_pos, layout.scale)
    paste_with_shadow(canvas, iphone, iphone_pos, layout.scale)


def overlay_preview(asset: Image.Image, layout: Layout, with_crops: bool) -> Image.Image:
    """Делает уменьшенную копию с безопасной зоной (зелёная) и, для universal, обрезками 21:9 (красная) и 3:2 (жёлтая).

    - Parameters:
      - asset: готовый кадр.
      - layout: раскладка формата.
      - with_crops: рисовать ли рамки обрезок 21:9 и 3:2.
    - Returns: превью в четверть размера для проверки композиции.
    """
    w, h = layout.size
    line = max(4, round(14 * layout.scale))
    preview = asset.copy()
    draw = ImageDraw.Draw(preview)
    draw.rectangle(layout.safe, outline=(0, 255, 0), width=line)
    if with_crops:
        h21 = round(w * 9 / 21)
        draw.rectangle((0, (h - h21) // 2, w - 1, (h + h21) // 2), outline=(255, 40, 40), width=line)
        w32 = round(h * 3 / 2)
        draw.rectangle(((w - w32) // 2, 0, (w + w32) // 2, h - 1), outline=(255, 230, 0), width=line)
    return preview.resize((w // 4, h // 4), Image.LANCZOS)


def main() -> None:
    """Собирает ассет и превью и сохраняет их в AppStoreAssets/out/."""
    OUT.mkdir(exist_ok=True)
    canvas = radial_background(UNIVERSAL.size)
    add_glyph_texture(canvas, UNIVERSAL)
    text_bottom = draw_slogan(canvas, UNIVERSAL)
    compose_devices(canvas, UNIVERSAL, top=text_bottom + UNIVERSAL.devices_gap)

    # App Store не принимает альфа-канал — сохраняем строго RGB.
    canvas.convert("RGB").save(OUT / "universal_5244x2950.png", optimize=True)
    overlay_preview(canvas, UNIVERSAL, with_crops=True).save(OUT / "preview_overlay.png")
    print("Готово:", OUT)


if __name__ == "__main__":
    main()
