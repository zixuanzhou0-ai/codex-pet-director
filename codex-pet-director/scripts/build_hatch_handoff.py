#!/usr/bin/env python3
"""Build a validated hatch-pet handoff manifest from a Codex Pet Director brief."""

from __future__ import annotations

import argparse
import json
import shlex
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from pet_brief import ACTION_FRAMES
from pet_brief import get_path
from pet_brief import load
from pet_brief import validation_errors_for_stage


OFFICIAL_FORMAT = {
    "columns": 8,
    "rows": 9,
    "cell_width": 192,
    "cell_height": 208,
    "atlas_width": 1536,
    "atlas_height": 1872,
}


def as_list(value: Any) -> list[str]:
    if value is None or value == "":
        return []
    if isinstance(value, list):
        return [str(item) for item in value if str(item).strip()]
    return [str(value)]


def compact_join(values: list[str], fallback: str = "") -> str:
    cleaned = [value.strip() for value in values if value and value.strip()]
    return "; ".join(cleaned) if cleaned else fallback


def resolve_path(raw_path: str, brief_path: Path) -> Path:
    path = Path(raw_path).expanduser()
    if not path.is_absolute():
        path = brief_path.parent / path
    return path.resolve()


def brief_description(brief: dict[str, Any]) -> str:
    pieces = [
        str(get_path(brief, "identity.concept") or ""),
        str(get_path(brief, "form.type") or ""),
        compact_join(as_list(get_path(brief, "style.selected"))),
        compact_join(as_list(get_path(brief, "personality.traits"))),
    ]
    text = compact_join(pieces, "A custom Codex desktop pet")
    if text[-1:] not in ".!?。！？":
        text += "."
    return text


def pet_notes(brief: dict[str, Any]) -> str:
    return compact_join(
        [
            f"Concept: {get_path(brief, 'identity.concept') or ''}",
            f"Form: {get_path(brief, 'form.type') or ''}",
            f"Must preserve: {compact_join(as_list(get_path(brief, 'likeness.must_preserve') or get_path(brief, 'appearance.must_have')))}",
            f"Visual locks: {compact_join(as_list(get_path(brief, 'appearance.visual_locks')))}",
            f"Avoid drift: {compact_join(as_list(get_path(brief, 'likeness.must_avoid_drift')))}",
        ]
    )


def style_notes(brief: dict[str, Any]) -> str:
    return compact_join(
        [
            "Maximum likeness within official Codex pet limits: preserve the strongest user-requested identity cues while simplifying details that fail at 192x208.",
            "Use the production_base image as the only canonical production reference; formal_character_image and concept images are auxiliary only.",
            f"Selected style: {compact_join(as_list(get_path(brief, 'style.selected')))}",
            f"Style notes: {get_path(brief, 'style.notes') or ''}",
            f"May simplify: {compact_join(as_list(get_path(brief, 'likeness.may_simplify')))}",
            f"Avoid: {compact_join(as_list(get_path(brief, 'appearance.avoid')) + as_list(get_path(brief, 'style.avoid_styles')))}",
        ]
    )


def action_manifest(brief: dict[str, Any]) -> dict[str, dict[str, Any]]:
    actions: dict[str, dict[str, Any]] = {}
    for action, frames in ACTION_FRAMES.items():
        actions[action] = {
            "frames": frames,
            "user_answer": get_path(brief, f"actions.{action}.user_answer") or "",
            "summary": get_path(brief, f"actions.{action}.summary") or "",
            "prompt_notes": get_path(brief, f"actions.{action}.prompt_notes") or "",
        }
    return actions


def shell_join(parts: list[str]) -> str:
    return " ".join(shlex.quote(part) for part in parts)


def build_handoff(brief_path: Path, output_dir: Path) -> dict[str, Any]:
    brief = load(brief_path)
    missing, invalid = validation_errors_for_stage(brief, "final", brief_path)
    if missing or invalid:
        lines = []
        if missing:
            lines.append("Missing fields:")
            lines.extend(f"- {item}" for item in missing)
        if invalid:
            lines.append("Invalid fields:")
            lines.extend(f"- {item}" for item in invalid)
        raise SystemExit("Brief is not ready for hatch-pet handoff.\n" + "\n".join(lines))

    production_base = resolve_path(str(get_path(brief, "confirmations.production_base")), brief_path)
    pet_name = str(get_path(brief, "identity.name") or "").strip() or "Custom Pet"
    description = brief_description(brief)
    notes = pet_notes(brief)
    styles = style_notes(brief)

    prepare_command = [
        "python",
        "${CODEX_HOME:-$HOME/.codex}/skills/hatch-pet/scripts/prepare_pet_run.py",
        "--pet-name",
        pet_name,
        "--description",
        description,
        "--reference",
        str(production_base),
        "--output-dir",
        str(output_dir.resolve()),
        "--pet-notes",
        notes,
        "--style-notes",
        styles,
        "--force",
    ]

    return {
        "schema_version": 1,
        "created_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        "source_brief": str(brief_path.resolve()),
        "target": "hatch-pet",
        "official_format": OFFICIAL_FORMAT,
        "pet_name": pet_name,
        "description": description,
        "production_base": str(production_base),
        "production_base_fit": get_path(brief, "confirmations.production_base_fit"),
        "concept_confirmation": get_path(brief, "confirmations.concept_confirmation") or "",
        "formal_character_image": get_path(brief, "confirmations.formal_character_image") or "",
        "likeness_contract": get_path(brief, "likeness"),
        "identity_lock": {
            "must_preserve": as_list(get_path(brief, "likeness.must_preserve")) or as_list(get_path(brief, "appearance.must_have")),
            "visual_locks": as_list(get_path(brief, "appearance.visual_locks")),
            "may_simplify": as_list(get_path(brief, "likeness.may_simplify")),
            "must_avoid_drift": as_list(get_path(brief, "likeness.must_avoid_drift")),
            "avoid": as_list(get_path(brief, "appearance.avoid")) + as_list(get_path(brief, "style.avoid_styles")),
        },
        "actions": action_manifest(brief),
        "hatch_pet_inputs": {
            "pet_name": pet_name,
            "description": description,
            "reference": str(production_base),
            "output_dir": str(output_dir.resolve()),
            "pet_notes": notes,
            "style_notes": styles,
        },
        "prepare_pet_run_command": prepare_command,
        "prepare_pet_run_command_text": shell_join(prepare_command),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--brief", required=True, help="Path to pet_brief.json.")
    parser.add_argument("--output-dir", required=True, help="Target hatch-pet run directory.")
    parser.add_argument(
        "--handoff-name",
        default="hatch_pet_handoff.json",
        help="Manifest filename written inside --output-dir.",
    )
    args = parser.parse_args()

    brief_path = Path(args.brief).expanduser()
    output_dir = Path(args.output_dir).expanduser()
    output_dir.mkdir(parents=True, exist_ok=True)
    handoff = build_handoff(brief_path, output_dir)

    handoff_path = output_dir / args.handoff_name
    handoff_path.write_text(json.dumps(handoff, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"ok": True, "handoff": str(handoff_path), "command": handoff["prepare_pet_run_command_text"]}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
