#!/usr/bin/env python3
"""Check a finished Codex pet package and create QA review assets."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from PIL import Image
from PIL import ImageDraw


COLUMNS = 8
ROWS = 9
CELL_WIDTH = 192
CELL_HEIGHT = 208
ATLAS_WIDTH = COLUMNS * CELL_WIDTH
ATLAS_HEIGHT = ROWS * CELL_HEIGHT

ACTION_FRAMES = {
    "idle": 6,
    "running-right": 8,
    "running-left": 8,
    "waving": 4,
    "jumping": 5,
    "failed": 8,
    "waiting": 6,
    "running": 6,
    "review": 6,
}


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def alpha_count(cell: Image.Image) -> int:
    histogram = cell.getchannel("A").histogram()
    return sum(histogram[13:])


def edge_alpha_count(cell: Image.Image) -> int:
    alpha = cell.getchannel("A")
    pixels = alpha.load()
    total = 0
    for x in range(CELL_WIDTH):
        if pixels[x, 0] > 12:
            total += 1
        if pixels[x, CELL_HEIGHT - 1] > 12:
            total += 1
    for y in range(CELL_HEIGHT):
        if pixels[0, y] > 12:
            total += 1
        if pixels[CELL_WIDTH - 1, y] > 12:
            total += 1
    return total


def checkerboard(size: tuple[int, int], cell: int = 8) -> Image.Image:
    image = Image.new("RGBA", size, "#F7FAFC")
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if (x // cell + y // cell) % 2:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill="#E7EEF7")
    return image


def frame_crop(atlas: Image.Image, row: int, column: int) -> Image.Image:
    left = column * CELL_WIDTH
    top = row * CELL_HEIGHT
    return atlas.crop((left, top, left + CELL_WIDTH, top + CELL_HEIGHT)).convert("RGBA")


def composite_for_review(cell: Image.Image) -> Image.Image:
    background = checkerboard((CELL_WIDTH, CELL_HEIGHT))
    background.alpha_composite(cell)
    return background


def write_contact_sheet(atlas: Image.Image, output_path: Path) -> None:
    sheet = checkerboard((ATLAS_WIDTH, ATLAS_HEIGHT))
    sheet.alpha_composite(atlas.convert("RGBA"))
    draw = ImageDraw.Draw(sheet)
    for column in range(COLUMNS + 1):
        x = column * CELL_WIDTH
        draw.line((x, 0, x, ATLAS_HEIGHT), fill="#D8E2F0", width=1)
    for row in range(ROWS + 1):
        y = row * CELL_HEIGHT
        draw.line((0, y, ATLAS_WIDTH, y), fill="#D8E2F0", width=1)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path)


def write_row_gifs(atlas: Image.Image, output_dir: Path) -> list[str]:
    paths: list[str] = []
    for row_index, (_action, frame_count) in enumerate(ACTION_FRAMES.items(), start=1):
        frames = []
        for column in range(frame_count):
            frame = composite_for_review(frame_crop(atlas, row_index - 1, column))
            frames.append(frame.convert("P", palette=Image.Palette.ADAPTIVE))
        output_path = output_dir / f"row-{row_index:02d}.gif"
        if frames:
            frames[0].save(
                output_path,
                save_all=True,
                append_images=frames[1:],
                duration=160,
                loop=0,
                optimize=False,
            )
            paths.append(str(output_path))
    return paths


def inspect_atlas(atlas: Image.Image) -> tuple[list[str], list[str], dict[str, Any]]:
    failures: list[str] = []
    warnings: list[str] = []
    rows: dict[str, Any] = {}

    for row_index, (action, used_columns) in enumerate(ACTION_FRAMES.items()):
        row_report = {
            "used_columns": used_columns,
            "frames": [],
            "unused_cells_nonempty": [],
        }
        for column in range(COLUMNS):
            cell = frame_crop(atlas, row_index, column)
            foreground = alpha_count(cell)
            edge_pixels = edge_alpha_count(cell)
            coverage = foreground / (CELL_WIDTH * CELL_HEIGHT)
            bbox = cell.getchannel("A").getbbox()

            frame_report = {
                "column": column,
                "foreground_pixels": foreground,
                "coverage": round(coverage, 4),
                "bbox": list(bbox) if bbox else None,
                "edge_alpha_pixels": edge_pixels,
            }
            row_report["frames"].append(frame_report)

            if column < used_columns:
                if foreground <= 12:
                    failures.append(f"{action} column {column} is empty")
                if edge_pixels > 16:
                    failures.append(f"{action} column {column} appears clipped at the 192x208 cell edge")
                if coverage > 0.88 and bbox == (0, 0, CELL_WIDTH, CELL_HEIGHT):
                    failures.append(f"{action} column {column} looks like it still has an opaque rectangular background")
                if coverage < 0.015:
                    warnings.append(f"{action} column {column} may be too sparse to read")
            elif foreground > 0:
                row_report["unused_cells_nonempty"].append(column)
                failures.append(f"{action} unused column {column} is not transparent")

        rows[action] = row_report

    return failures, warnings, rows


def check_package(pet_dir: Path, output_dir: Path) -> dict[str, Any]:
    failures: list[str] = []
    warnings: list[str] = []
    artifacts: dict[str, Any] = {}
    rows: dict[str, Any] = {}

    pet_json_path = pet_dir / "pet.json"
    if not pet_json_path.is_file():
        failures.append(f"missing pet.json: {pet_json_path}")
        manifest: dict[str, Any] = {}
    else:
        try:
            manifest = json.loads(pet_json_path.read_text(encoding="utf-8-sig"))
        except json.JSONDecodeError as error:
            failures.append(f"pet.json is not valid JSON: {error}")
            manifest = {}

    spritesheet_name = str(manifest.get("spritesheetPath") or "spritesheet.webp")
    spritesheet_path = pet_dir / spritesheet_name
    if not spritesheet_path.is_file():
        failures.append(f"missing spritesheet: {spritesheet_path}")
        atlas = None
    else:
        with Image.open(spritesheet_path) as opened:
            atlas = opened.convert("RGBA")
        if atlas.size != (ATLAS_WIDTH, ATLAS_HEIGHT):
            failures.append(
                f"spritesheet must be {ATLAS_WIDTH}x{ATLAS_HEIGHT}, got {atlas.width}x{atlas.height}"
            )

    if atlas is not None and atlas.size == (ATLAS_WIDTH, ATLAS_HEIGHT):
        atlas_failures, atlas_warnings, rows = inspect_atlas(atlas)
        failures.extend(atlas_failures)
        warnings.extend(atlas_warnings)
        output_dir.mkdir(parents=True, exist_ok=True)
        contact_sheet = output_dir / "contact-sheet.png"
        write_contact_sheet(atlas, contact_sheet)
        artifacts["contact_sheet"] = str(contact_sheet)
        artifacts["row_gifs"] = write_row_gifs(atlas, output_dir)

    report = {
        "status": "fail" if failures else "pass",
        "checked_at": now_iso(),
        "tool": "check_hatch_output.py",
        "pet_dir": str(pet_dir),
        "official_format": {
            "columns": COLUMNS,
            "rows": ROWS,
            "cell_width": CELL_WIDTH,
            "cell_height": CELL_HEIGHT,
            "atlas_width": ATLAS_WIDTH,
            "atlas_height": ATLAS_HEIGHT,
            "actions": ACTION_FRAMES,
        },
        "manifest": manifest,
        "spritesheet": str(spritesheet_path),
        "rows": rows,
        "failures": failures,
        "warnings": warnings,
        "artifacts": artifacts,
    }

    output_dir.mkdir(parents=True, exist_ok=True)
    report_path = output_dir / "output_check.json"
    report["artifacts"]["output_check"] = str(report_path)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return report


def print_human(report: dict[str, Any]) -> None:
    print(f"Hatch output: {report['status'].upper()}")
    print(f"Pet dir: {report['pet_dir']}")
    print(f"Spritesheet: {report['spritesheet']}")
    for key in ["failures", "warnings"]:
        values = report.get(key) or []
        if values:
            print(f"{key.title()}:")
            for value in values:
                print(f"- {value}")
    artifacts = report.get("artifacts") or {}
    if artifacts:
        print("Artifacts:")
        for key, value in artifacts.items():
            print(f"- {key}: {value}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pet-dir", required=True, help="Directory containing pet.json and spritesheet.webp.")
    parser.add_argument("--output-dir", required=True, help="Directory for output_check.json and QA images.")
    parser.add_argument("--json", action="store_true", help="Print machine-readable JSON.")
    args = parser.parse_args()

    report = check_package(Path(args.pet_dir).expanduser(), Path(args.output_dir).expanduser())
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_human(report)
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
