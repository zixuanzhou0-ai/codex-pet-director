#!/usr/bin/env python3
"""Check whether an image is fit to become a Codex 192x208 pet base asset."""

from __future__ import annotations

import argparse
import json
import math
import warnings
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from PIL import Image

warnings.filterwarnings("ignore", category=DeprecationWarning)


CELL_WIDTH = 192
CELL_HEIGHT = 208
SAFE_MARGIN_X = 18
SAFE_MARGIN_Y = 16
MIN_COVERAGE = 0.08
MAX_COVERAGE = 0.72
MAX_BACKGROUND_VARIANCE = 0.08
MAX_EDGE_DENSITY = 1.15
MAX_PALETTE_ESTIMATE = 110


def color_distance(left: tuple[int, int, int], right: tuple[int, int, int]) -> float:
    return math.sqrt(sum((left[index] - right[index]) ** 2 for index in range(3)))


def quantized_color(rgb: tuple[int, int, int], step: int = 16) -> tuple[int, int, int]:
    return tuple(channel // step for channel in rgb)


def border_pixels(image: Image.Image) -> list[tuple[int, int, int, int]]:
    width, height = image.size
    pixels = image.load()
    samples: list[tuple[int, int, int, int]] = []
    stride = max(1, min(width, height) // 256)
    for x in range(0, width, stride):
        samples.append(pixels[x, 0])
        samples.append(pixels[x, height - 1])
    for y in range(0, height, stride):
        samples.append(pixels[0, y])
        samples.append(pixels[width - 1, y])
    return samples


def dominant_border_color(samples: list[tuple[int, int, int, int]]) -> tuple[int, int, int]:
    opaque = [sample[:3] for sample in samples if sample[3] > 240]
    if not opaque:
        return (0, 0, 0)
    bucket = Counter(quantized_color(pixel) for pixel in opaque).most_common(1)[0][0]
    bucket_pixels = [pixel for pixel in opaque if quantized_color(pixel) == bucket]
    return tuple(round(sum(pixel[index] for pixel in bucket_pixels) / len(bucket_pixels)) for index in range(3))


def make_mask(image: Image.Image, background: tuple[int, int, int]) -> tuple[Image.Image, dict[str, Any]]:
    pixels = list(image.getdata())
    alphas = [pixel[3] for pixel in pixels]
    has_transparency = min(alphas) < 240
    transparent_border = sum(1 for pixel in border_pixels(image) if pixel[3] < 32)
    border_count = max(1, len(border_pixels(image)))

    mask = Image.new("L", image.size, 0)
    mask_pixels = []
    if has_transparency and transparent_border / border_count >= 0.5:
        for pixel in pixels:
            mask_pixels.append(255 if pixel[3] > 32 else 0)
        kind = "transparent"
    else:
        for pixel in pixels:
            distance = color_distance(pixel[:3], background)
            mask_pixels.append(255 if pixel[3] > 32 and distance > 28 else 0)
        kind = "flat-color"
    mask.putdata(mask_pixels)
    return mask, {"kind": kind, "has_transparency": has_transparency}


def resize_into_cell(image: Image.Image, resample: int) -> Image.Image:
    scale = min(CELL_WIDTH / image.width, CELL_HEIGHT / image.height)
    width = max(1, round(image.width * scale))
    height = max(1, round(image.height * scale))
    resized = image.resize((width, height), resample)
    canvas = Image.new(image.mode, (CELL_WIDTH, CELL_HEIGHT), 0)
    canvas.paste(resized, ((CELL_WIDTH - width) // 2, (CELL_HEIGHT - height) // 2))
    return canvas


def count_mask_pixels(mask: Image.Image) -> int:
    return sum(1 for pixel in mask.getdata() if pixel > 0)


def palette_estimate(image: Image.Image, mask: Image.Image) -> int:
    colors: set[tuple[int, int, int]] = set()
    for pixel, alpha in zip(image.convert("RGBA").getdata(), mask.getdata()):
        if alpha > 0:
            colors.add(quantized_color(pixel[:3], 32))
    return len(colors)


def edge_density(image: Image.Image, mask: Image.Image) -> float:
    gray = image.convert("L")
    width, height = gray.size
    pixels = gray.load()
    mask_pixels = mask.load()
    edges = 0
    foreground = 0
    for y in range(height - 1):
        for x in range(width - 1):
            if mask_pixels[x, y] <= 0:
                continue
            foreground += 1
            value = pixels[x, y]
            if abs(value - pixels[x + 1, y]) > 28:
                edges += 1
            if abs(value - pixels[x, y + 1]) > 28:
                edges += 1
    if foreground == 0:
        return 0.0
    return edges / foreground


def background_report(image: Image.Image, background: tuple[int, int, int]) -> dict[str, Any]:
    samples = border_pixels(image)
    opaque_samples = [sample for sample in samples if sample[3] > 240]
    if not opaque_samples:
        return {"color": None, "variance": 0.0, "near_white_or_black": False}
    varied = sum(1 for pixel in opaque_samples if color_distance(pixel[:3], background) > 24)
    variance = varied / max(1, len(opaque_samples))
    near_white = all(channel >= 245 for channel in background)
    near_black = all(channel <= 10 for channel in background)
    return {
        "color": f"#{background[0]:02X}{background[1]:02X}{background[2]:02X}",
        "variance": round(variance, 4),
        "near_white_or_black": near_white or near_black,
    }


def check_image(path: Path) -> dict[str, Any]:
    failures: list[str] = []
    warnings: list[str] = []
    recommendations: list[str] = []

    with Image.open(path) as opened:
        image = opened.convert("RGBA")

    background = dominant_border_color(border_pixels(image))
    mask, mask_meta = make_mask(image, background)
    foreground_bbox = mask.getbbox()
    bg_report = background_report(image, background)

    if bg_report["variance"] > MAX_BACKGROUND_VARIANCE:
        failures.append("background border is not flat enough for clean extraction")
    if bg_report["near_white_or_black"] and mask_meta["kind"] != "transparent":
        failures.append("background is near white or black; use transparency or a clean chroma color instead")

    if foreground_bbox is None:
        failures.append("no readable foreground sprite found")
        foreground_bbox = (0, 0, 0, 0)

    cell_image = resize_into_cell(image, Image.Resampling.LANCZOS)
    cell_mask = resize_into_cell(mask, Image.Resampling.NEAREST)
    cell_bbox = cell_mask.getbbox()
    if cell_bbox is None:
        cell_bbox = (0, 0, 0, 0)

    left, top, right, bottom = cell_bbox
    width = max(0, right - left)
    height = max(0, bottom - top)
    foreground_pixels = count_mask_pixels(cell_mask)
    coverage = foreground_pixels / (CELL_WIDTH * CELL_HEIGHT)
    detail_edges = edge_density(cell_image, cell_mask)
    palette = palette_estimate(cell_image, cell_mask)

    if left < SAFE_MARGIN_X or right > CELL_WIDTH - SAFE_MARGIN_X:
        failures.append("sprite is too wide or too close to the 192x208 cell edge")
    if top < SAFE_MARGIN_Y or bottom > CELL_HEIGHT - SAFE_MARGIN_Y:
        failures.append("sprite is too tall or too close to the 192x208 cell edge")
    if coverage < MIN_COVERAGE:
        failures.append("sprite will be too small after fitting into 192x208")
    if coverage > MAX_COVERAGE:
        failures.append("sprite fills too much of the 192x208 cell and leaves little animation padding")
    if detail_edges > MAX_EDGE_DENSITY:
        failures.append("detail density is too high for a stable 192x208 animated pet")
    if palette > MAX_PALETTE_ESTIMATE:
        failures.append("palette and shading are too complex for a small desktop pet sprite")

    if image.width > 768 or image.height > 768:
        warnings.append("source image is large; this is acceptable only if the sprite is already simplified")
    if width < 72 or height < 72:
        warnings.append("sprite may be hard to read at desktop-pet size")

    if failures:
        recommendations.extend(
            [
                "Regenerate a production_base image instead of using the high-detail confirmation image.",
                "Keep the strongest identity cues, but simplify hair strands, textures, shadows, fingers, and small accessories.",
                "Use a transparent background or one flat chroma color that does not appear inside the sprite.",
                "Center the complete sprite inside one 192x208 cell with safe padding.",
            ]
        )

    status = "fail" if failures else "pass"
    return {
        "status": status,
        "checked_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        "tool": "check_pet_asset_fit.py",
        "image": {
            "path": str(path),
            "width": image.width,
            "height": image.height,
            "mode": image.mode,
        },
        "target": {
            "cell_width": CELL_WIDTH,
            "cell_height": CELL_HEIGHT,
            "safe_margin_x": SAFE_MARGIN_X,
            "safe_margin_y": SAFE_MARGIN_Y,
        },
        "background": {
            **mask_meta,
            **bg_report,
        },
        "sprite": {
            "source_bbox": list(foreground_bbox),
            "cell_bbox": list(cell_bbox),
            "cell_bbox_width": width,
            "cell_bbox_height": height,
            "cell_coverage": round(coverage, 4),
        },
        "detail": {
            "edge_density": round(detail_edges, 4),
            "palette_estimate": palette,
        },
        "failures": failures,
        "warnings": warnings,
        "recommendations": recommendations,
    }


def print_human(report: dict[str, Any]) -> None:
    print(f"Asset fit: {report['status'].upper()}")
    print(f"Image: {report['image']['path']}")
    print(f"Size: {report['image']['width']}x{report['image']['height']}")
    print(f"Cell bbox: {report['sprite']['cell_bbox']}")
    print(f"Coverage: {report['sprite']['cell_coverage']}")
    print(f"Edge density: {report['detail']['edge_density']}")
    print(f"Palette estimate: {report['detail']['palette_estimate']}")
    for label in ["failures", "warnings", "recommendations"]:
        values = report[label]
        if values:
            print(f"{label.title()}:")
            for value in values:
                print(f"- {value}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image", required=True, help="Candidate production_base image.")
    parser.add_argument("--json", action="store_true", help="Print machine-readable JSON.")
    args = parser.parse_args()

    image_path = Path(args.image).expanduser()
    if not image_path.is_file():
        report = {
            "status": "fail",
            "checked_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
            "tool": "check_pet_asset_fit.py",
            "image": {"path": str(image_path)},
            "failures": [f"image file does not exist: {image_path}"],
            "warnings": [],
            "recommendations": [],
        }
    else:
        report = check_image(image_path)

    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_human(report)
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
