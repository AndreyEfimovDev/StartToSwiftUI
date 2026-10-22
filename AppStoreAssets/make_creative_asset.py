#!/usr/bin/env python3
"""Генерация universal creative asset (16:9, 5244×2950) для App Store:
product page header + search results.

Запуск из корня репозитория:
    python3 AppStoreAssets/make_creative_asset.py

Результат в AppStoreAssets/out/:
    universal_5244x2950.png — файл для загрузки в App Store Connect (RGB, без альфы);
    preview_overlay.png     — уменьшенная копия с безопасной зоной и обрезками 21:9 / 3:2.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent
RAW = ROOT / "raw"
OUT = ROOT / "out"
APP_ICON = ROOT.parent / "StartToSwiftUI/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

# Холст и безопасная зона — из шаблона Apple «Universal Asset Template» (слой «Art Safe Area»).
W, H = 5244, 2950
SAFE = (1921, 660, 3323, 1622)
CENTER_X = W // 2

# Фирменные цвета: фон иконки #3366FF, к краям — темнее.
BRAND = (0x33, 0x66, 0xFF)
BRAND_DARK = (0x1E, 0x3F, 0xB8)
WHITE = (255, 255, 255)

SLOGAN = ["Learn SwiftUI", "your way"]
FONT_PATH = "/System/Library/Fonts/SFNS.ttf"

IPHONE_SHOT = RAW / "iphone.webp"
# Ландшафтный iPad-кадр используется, если файл есть; иначе — портретный.
IPAD_LANDSCAPE_SHOT = RAW / "ipad_landscape.png"
IPAD_PORTRAIT_SHOT = RAW / "ipad.webp"


def radial_background() -> Image.Image:
    """Создаёт фон с радиальным градиентом от фирменного синего в центре к тёмному по краям.

    - Returns: RGB-изображение размером холста.
    """
    # Градиент считаем в малом разрешении и растягиваем — это быстро и даёт плавный переход.
    sw, sh = 524, 295
    small = Image.new("RGB", (sw, sh))
    cx, cy = sw / 2, sh * 0.42
    max_d = ((sw / 2) ** 2 + (sh * 0.6) ** 2) ** 0.5
    px = small.load()
    for y in range(sh):
        for x in range(sw):
            t = min(1.0, (((x - cx) ** 2 + (y - cy) ** 2) ** 0.5) / max_d)
            t = t * t
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(BRAND, BRAND_DARK))
    return small.resize((W, H), Image.LANCZOS)


def icon_glyph_mask() -> Image.Image:
    """Вырезает из иконки приложения белый символ «A» (без подписи) как маску.

    - Returns: L-маска символа, обрезанная по его границам.
    """
    icon = Image.open(APP_ICON).convert("RGB")
    # Подпись «StartToSwiftUI» начинается ниже ~800 px — её отрезаем, оставляя только «A».
    glyph = icon.crop((0, 0, icon.width, 800))
    mask = glyph.convert("L").point(lambda v: 255 if v > 200 else 0)
    return mask.crop(mask.getbbox())


def add_glyph_texture(canvas: Image.Image) -> None:
    """Накладывает крупные полупрозрачные «A» по краям холста как фирменную фактуру.

    Глифы стоят вне безопасной зоны: их обрезка на узких кадрах не страшна.

    - Parameter canvas: RGB-холст, изменяется на месте.
    """
    mask = icon_glyph_mask()
    placements = [  # (высота глифа, левый край, верх, непрозрачность)
        (2600, -700, 900, 0.10),
        (2200, 3900, -350, 0.08),
    ]
    for height, left, top, alpha in placements:
        scaled = mask.resize((round(mask.width * height / mask.height), height), Image.LANCZOS)
        scaled = scaled.point(lambda v: round(v * alpha))
        canvas.paste(WHITE, (left, top), scaled)


def device(shot: Image.Image, screen_height: int) -> Image.Image:
    """Рисует устройство: скриншот в скруглённой тёмной рамке.

    - Parameters:
      - shot: скриншот экрана.
      - screen_height: итоговая высота экрана в пикселях холста.
    - Returns: RGBA-изображение устройства с прозрачными углами.
    """
    sw = round(shot.width * screen_height / shot.height)
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


def paste_with_shadow(canvas: Image.Image, item: Image.Image, pos: tuple[int, int]) -> None:
    """Вставляет RGBA-элемент на холст с мягкой тенью под ним.

    - Parameters:
      - canvas: RGB-холст, изменяется на месте.
      - item: RGBA-элемент (устройство).
      - pos: левый верхний угол элемента на холсте.
    """
    pad = 160
    shadow = Image.new("L", (item.width + 2 * pad, item.height + 2 * pad), 0)
    shadow.paste(item.getchannel("A").point(lambda v: v * 0.45), (pad, pad + 50))
    shadow = shadow.filter(ImageFilter.GaussianBlur(70))
    canvas.paste((8, 20, 70), (pos[0] - pad, pos[1] - pad), shadow)
    canvas.paste(item, pos, item)


def fitting_font(lines: list[str], max_width: int, start_size: int) -> ImageFont.FreeTypeFont:
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


def draw_slogan(canvas: Image.Image) -> int:
    """Рисует слоган по центру в верхней части безопасной зоны.

    - Parameter canvas: RGB-холст, изменяется на месте.
    - Returns: координата Y нижней границы текста.
    """
    font = fitting_font(SLOGAN, max_width=SAFE[2] - SAFE[0] - 120, start_size=240)
    draw = ImageDraw.Draw(canvas)
    line_height = round(font.size * 1.08)
    y = SAFE[1] + 40
    for line in SLOGAN:
        draw.text((CENTER_X, y), line, font=font, fill=WHITE, anchor="mt")
        y += line_height
    return y


def compose_devices(canvas: Image.Image, top: int) -> None:
    """Размещает iPad (сзади) и iPhone (спереди) группой по центру, начиная с заданного Y.

    Верхние части экранов попадают в безопасную зону, низ уходит за её пределы —
    как фигуры в примере из шаблона Apple.

    - Parameters:
      - canvas: RGB-холст, изменяется на месте.
      - top: Y верхнего края iPad.
    """
    iphone = device(Image.open(IPHONE_SHOT), screen_height=1900)
    if IPAD_LANDSCAPE_SHOT.exists():
        ipad = device(Image.open(IPAD_LANDSCAPE_SHOT), screen_height=1500)
        iphone_overlap = 0.30  # Доля ширины iPhone, заходящая на iPad.
    else:
        ipad = device(Image.open(IPAD_PORTRAIT_SHOT), screen_height=2100)
        iphone_overlap = 0.45

    group_width = ipad.width + round(iphone.width * (1 - iphone_overlap))
    ipad_x = CENTER_X - group_width // 2
    iphone_x = ipad_x + ipad.width - round(iphone.width * iphone_overlap)
    paste_with_shadow(canvas, ipad, (ipad_x, top))
    paste_with_shadow(canvas, iphone, (iphone_x, top + 180))


def overlay_preview(asset: Image.Image) -> Image.Image:
    """Делает уменьшенную копию с безопасной зоной (зелёная) и обрезками 21:9 (красная) и 3:2 (жёлтая).

    - Parameter asset: готовый ассет.
    - Returns: превью 1311×738 для проверки композиции.
    """
    preview = asset.copy()
    draw = ImageDraw.Draw(preview)
    draw.rectangle(SAFE, outline=(0, 255, 0), width=14)
    h21 = round(W * 9 / 21)
    draw.rectangle((0, (H - h21) // 2, W - 1, (H + h21) // 2), outline=(255, 40, 40), width=14)
    w32 = round(H * 3 / 2)
    draw.rectangle(((W - w32) // 2, 0, (W + w32) // 2, H - 1), outline=(255, 230, 0), width=14)
    return preview.resize((W // 4, H // 4), Image.LANCZOS)


def main() -> None:
    """Собирает ассет и превью и сохраняет их в AppStoreAssets/out/."""
    OUT.mkdir(exist_ok=True)
    canvas = radial_background()
    add_glyph_texture(canvas)
    text_bottom = draw_slogan(canvas)
    compose_devices(canvas, top=text_bottom + 90)

    # App Store не принимает альфа-канал — сохраняем строго RGB.
    canvas.convert("RGB").save(OUT / "universal_5244x2950.png", optimize=True)
    overlay_preview(canvas).save(OUT / "preview_overlay.png")
    print("Готово:", OUT)


if __name__ == "__main__":
    main()
