#!/usr/bin/env python3
"""Генерация видео creative assets для App Store: product page header (21:9) и search results (3:2).

Запуск из корня репозитория (нужен ffmpeg: brew install ffmpeg; Python — системный, как
в make_creative_asset.py):
    /usr/bin/python3 AppStoreAssets/make_creative_video.py

Результат в AppStoreAssets/out/ для каждого формата:
    <name>.mp4          — ролик для загрузки (H.264, без звука, бесшовный цикл);
    <name>_poster.png   — первый кадр (постер) с безопасной зоной, в четверть размера;
    <name>_frames.png   — четыре кадра цикла для быстрой проверки движения.

Без ffmpeg создаются только постер и кадры.
"""

from __future__ import annotations

import math
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageChops

from make_creative_asset import (
    OUT, RAW, SHADOW, UNIVERSAL, WHITE, Layout, device, devices_origin, glyph_sprite,
    overlay_preview, radial_background, scaled_layout, shadow_mask, slogan_mask,
)

DURATION = 12.0  # Секунды; все движения периодичны по DURATION — цикл без шва.
FPS = 30
FADE = 0.8  # Длительность перехода между экранами, секунды.

# Безопасные зоны — из шаблонов Apple «Product Page Header» и «Search Results» (слой «Art Safe Area»).
HEADER = scaled_layout((3840, 1646), (1097, 493, 2743, 1154), ("Learn SwiftUI your way",))
# Search results рендерим в 2880×1920 (3:2 внутри допустимого диапазона): 3840×2560 требует
# H.264 level 6, который поддерживают не все декодеры. Зона шаблона 3840×2560 масштабирована на 0.75.
SEARCH = scaled_layout((2880, 1920), (627, 574, 2253, 1346), UNIVERSAL.slogan)

FORMATS = {"header_3840x1646": HEADER, "search_2880x1920": SEARCH}

# Экраны по порядку показа; отсутствующие файлы пропускаются.
IPHONE_SHOTS = [RAW / "iphone.webp", RAW / "iphone_2.png", RAW / "iphone_3.png"]
IPAD_SHOTS = [RAW / "ipad.webp", RAW / "ipad_2.png"]


@dataclass
class DeviceTrack:
    """Устройство в ролике: кадры экранов одного размера, тень, маска для блика и параметры движения."""

    frames: list[Image.Image]
    shadow: Image.Image
    shadow_pad: int
    glare_band: Image.Image
    origin: tuple[int, int]
    amplitude: float
    phase: float
    glare_window: tuple[float, float]  # Доли цикла, в которые по устройству проходит блик.


def load_frames(paths: list[Path], screen_height: int) -> list[Image.Image]:
    """Загружает существующие скриншоты и рисует из них устройства одного размера.

    Размер берётся по первому кадру, остальные подгоняются под него — иначе переход между ними невозможен.

    - Parameters:
      - paths: пути к скриншотам по порядку показа.
      - screen_height: высота экрана в пикселях холста.
    - Returns: RGBA-изображения устройства.
    """
    shots = [Image.open(p) for p in paths if p.exists()]
    first = device(shots[0], screen_height)
    screen_width = round(shots[0].width * screen_height / shots[0].height)
    return [first] + [device(s, screen_height, screen_width) for s in shots[1:]]


def make_glare_band(size: tuple[int, int]) -> Image.Image:
    """Готовит наклонную полосу блика шириной в три устройства для скольжения по экрану.

    - Parameter size: размер устройства.
    - Returns: L-маска полосы; окно размером устройства вырезается со сдвигом по кадрам.
    """
    w, h = size
    band_w = max(1, w // 4)
    row = Image.new("L", (3 * w, 1), 0)
    for x in range(band_w):
        # Мягкий профиль полосы: максимум в середине, плавные края.
        row.putpixel((w + x, 0), round(60 * math.sin(math.pi * x / band_w)))
    band = row.resize((3 * w, h))
    # Наклон полосы: сдвиг по X пропорционально Y.
    return band.transform(band.size, Image.AFFINE, (1, 0.35, 0, 0, 1, 0), Image.BILINEAR)


def make_track(paths: list[Path], screen_height: int, origin: tuple[int, int], layout: Layout,
               amplitude: float, phase: float, glare_window: tuple[float, float]) -> DeviceTrack:
    """Собирает дорожку устройства: кадры, тень и блик.

    - Parameters:
      - paths: скриншоты по порядку показа.
      - screen_height: высота экрана.
      - origin: левый верхний угол устройства в покое.
      - layout: раскладка формата.
      - amplitude: амплитуда «плавания» по вертикали, px.
      - phase: фаза «плавания», радианы.
      - glare_window: доли цикла, в которые проходит блик.
    - Returns: готовая дорожка.
    """
    frames = load_frames(paths, screen_height)
    shadow, pad = shadow_mask(frames[0], layout.scale)
    return DeviceTrack(frames, shadow, pad, make_glare_band(frames[0].size), origin,
                       amplitude, phase, glare_window)


def smoothstep(k: float) -> float:
    """Сглаживает линейный прогресс 0…1, чтобы переходы начинались и заканчивались мягко."""
    return k * k * (3 - 2 * k)


def screen_mix(t: float, count: int) -> tuple[int, int, float]:
    """Определяет, какие экраны смешивать в момент t.

    Последний экран к концу цикла переходит в первый — поэтому стык цикла незаметен.

    - Parameters:
      - t: время от начала цикла, секунды.
      - count: количество экранов.
    - Returns: индекс текущего экрана, индекс следующего и доля следующего 0…1.
    """
    if count == 1:
        return 0, 0, 0.0
    segment = DURATION / count
    i = min(int(t // segment), count - 1)
    fade_start = segment - FADE
    into = t - i * segment
    if into < fade_start:
        return i, i, 0.0
    return i, (i + 1) % count, smoothstep((into - fade_start) / FADE)


def draw_track(canvas: Image.Image, track: DeviceTrack, t: float) -> None:
    """Рисует устройство в момент t: тень, экран (с переходом) и блик.

    - Parameters:
      - canvas: RGB-кадр, изменяется на месте.
      - track: дорожка устройства.
      - t: время от начала цикла, секунды.
    """
    dy = round(track.amplitude * math.sin(2 * math.pi * t / DURATION + track.phase))
    x, y = track.origin[0], track.origin[1] + dy
    canvas.paste(SHADOW, (x - track.shadow_pad, y - track.shadow_pad), track.shadow)

    i, j, k = screen_mix(t, len(track.frames))
    item = track.frames[i] if k == 0 else Image.blend(track.frames[i], track.frames[j], k)
    canvas.paste(item, (x, y), item)

    start, end = track.glare_window
    progress = (t / DURATION - start) / (end - start)
    if 0 < progress < 1:
        w, h = item.size
        # Окно едет от «полоса правее экрана» до «полоса левее экрана» с учётом наклона —
        # в начале и в конце прохода блика не видно, поэтому он появляется и исчезает без скачка.
        offset = round(2 * w - progress * (2 * w + 0.4 * h))
        window = track.glare_band.crop((offset, 0, offset + w, h))
        canvas.paste(WHITE, (x, y), ImageChops.multiply(window, item.getchannel("A")))


def render_frame(layout: Layout, base: Image.Image, glyphs: list[tuple[Image.Image, int, int]],
                 slogan: Image.Image, tracks: list[DeviceTrack], t: float) -> Image.Image:
    """Собирает один кадр ролика.

    - Parameters:
      - layout: раскладка формата.
      - base: фон с градиентом.
      - glyphs: маски «A» с исходными позициями.
      - slogan: маска слогана размером холста.
      - tracks: дорожки устройств в порядке отрисовки (сзади вперёд).
      - t: время от начала цикла, секунды.
    - Returns: RGB-кадр.
    """
    frame = base.copy()
    angle = 2 * math.pi * t / DURATION
    for n, (mask, left, top) in enumerate(glyphs):
        # Глифы дрейфуют в противофазе — фон «дышит», а не сдвигается целиком.
        dx = round(60 * layout.scale * math.sin(angle + n * math.pi))
        dy = round(30 * layout.scale * math.cos(angle + n * math.pi))
        frame.paste(WHITE, (left + dx, top + dy), mask)
    frame.paste(WHITE, (0, 0), slogan)
    for track in tracks:
        draw_track(frame, track, t)
    return frame


def contact_sheet(frames: list[Image.Image]) -> Image.Image:
    """Складывает четыре кадра в сетку 2×2 в четверть размера.

    - Parameter frames: четыре RGB-кадра одного размера.
    - Returns: изображение-сетка.
    """
    w, h = frames[0].width // 4, frames[0].height // 4
    sheet = Image.new("RGB", (2 * w + 20, 2 * h + 20), (255, 255, 255))
    for n, f in enumerate(frames):
        sheet.paste(f.resize((w, h), Image.LANCZOS), ((n % 2) * (w + 20), (n // 2) * (h + 20)))
    return sheet


def encode(name: str, layout: Layout, frame_at) -> None:
    """Кодирует ролик через ffmpeg, передавая кадры в stdin.

    - Parameters:
      - name: имя файла без расширения.
      - layout: раскладка формата.
      - frame_at: функция времени t → RGB-кадр.
    """
    w, h = layout.size
    cmd = [
        "ffmpeg", "-y", "-loglevel", "error",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{w}x{h}", "-r", str(FPS), "-i", "-",
        # Без аудиодорожки: App Store всё равно стартует без звука.
        "-an", "-c:v", "libx264", "-profile:v", "high", "-level", "5.1", "-pix_fmt", "yuv420p",
        "-crf", "16", "-preset", "slow", "-movflags", "+faststart",
        str(OUT / f"{name}.mp4"),
    ]
    process = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    total = round(DURATION * FPS)
    for n in range(total):
        process.stdin.write(frame_at(n / FPS).tobytes())
        if n % FPS == 0:
            print(f"  {name}: {n // FPS}/{round(DURATION)} c", flush=True)
    process.stdin.close()
    if process.wait() != 0:
        raise RuntimeError(f"ffmpeg завершился с ошибкой для {name}")


def build(name: str, layout: Layout, has_ffmpeg: bool) -> None:
    """Готовит слои формата, сохраняет постер и кадры и при наличии ffmpeg кодирует ролик.

    - Parameters:
      - name: имя файла без расширения.
      - layout: раскладка формата.
      - has_ffmpeg: установлен ли ffmpeg.
    """
    base = radial_background(layout.size)
    glyphs = [(glyph_sprite(height, alpha), left, top) for height, left, top, alpha in layout.glyphs]
    slogan, text_bottom = slogan_mask(layout)

    top = text_bottom + layout.devices_gap
    ipad_probe = load_frames(IPAD_SHOTS[:1], layout.ipad_screen_height)[0]
    iphone_probe = load_frames(IPHONE_SHOTS[:1], layout.iphone_screen_height)[0]
    ipad_pos, iphone_pos = devices_origin(layout, ipad_probe.width, iphone_probe.width, top)
    tracks = [
        make_track(IPAD_SHOTS, layout.ipad_screen_height, ipad_pos, layout,
                   amplitude=30 * layout.scale, phase=0, glare_window=(0.30, 0.50)),
        make_track(IPHONE_SHOTS, layout.iphone_screen_height, iphone_pos, layout,
                   amplitude=40 * layout.scale, phase=math.pi / 2, glare_window=(0.40, 0.60)),
    ]

    def frame_at(t: float) -> Image.Image:
        return render_frame(layout, base, glyphs, slogan, tracks, t)

    poster = frame_at(0)
    overlay_preview(poster, layout, with_crops=False).save(OUT / f"{name}_poster.png")
    contact_sheet([frame_at(DURATION * q) for q in (0.15, 0.40, 0.55, 0.85)]).save(OUT / f"{name}_frames.png")
    if has_ffmpeg:
        encode(name, layout, frame_at)


def main() -> None:
    """Собирает оба формата и сохраняет результат в AppStoreAssets/out/."""
    OUT.mkdir(exist_ok=True)
    has_ffmpeg = shutil.which("ffmpeg") is not None
    if not has_ffmpeg:
        print("ffmpeg не найден (brew install ffmpeg) — сохраняю только постеры и кадры.")
    for name, layout in FORMATS.items():
        build(name, layout, has_ffmpeg)
    print("Готово:", OUT)


if __name__ == "__main__":
    main()
