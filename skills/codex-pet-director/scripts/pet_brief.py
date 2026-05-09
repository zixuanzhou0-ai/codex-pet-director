#!/usr/bin/env python3
"""Create, update, inspect, and validate Codex pet brief JSON files."""

from __future__ import annotations

import argparse
import json
from copy import deepcopy
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


SCHEMA_VERSION = 3

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

SUPPORTED_LANGUAGES = {
    "zh-CN": "简体中文",
    "zh-TW": "繁體中文",
    "en": "English",
    "ja": "日本語",
    "ko": "한국어",
    "es": "Español",
    "fr": "Français",
    "de": "Deutsch",
}

LANGUAGE_ALIASES = {
    "zh": "zh-CN",
    "cn": "zh-CN",
    "中文": "zh-CN",
    "简体中文": "zh-CN",
    "chinese": "zh-CN",
    "simplified-chinese": "zh-CN",
    "zh-hans": "zh-CN",
    "tw": "zh-TW",
    "繁体中文": "zh-TW",
    "繁體中文": "zh-TW",
    "traditional-chinese": "zh-TW",
    "zh-hant": "zh-TW",
    "英文": "en",
    "英语": "en",
    "英語": "en",
    "english": "en",
    "jp": "ja",
    "日语": "ja",
    "日語": "ja",
    "日本語": "ja",
    "japanese": "ja",
    "kr": "ko",
    "韩语": "ko",
    "韓語": "ko",
    "한국어": "ko",
    "korean": "ko",
    "西班牙语": "es",
    "西班牙語": "es",
    "español": "es",
    "spanish": "es",
    "法语": "fr",
    "法語": "fr",
    "français": "fr",
    "francais": "fr",
    "french": "fr",
    "德语": "de",
    "德語": "de",
    "deutsch": "de",
    "german": "de",
}


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def normalize_language(language: str) -> str:
    raw = (language or "zh-CN").strip()
    if raw in SUPPORTED_LANGUAGES:
        return raw
    normalized = raw.lower().replace("_", "-").replace(" ", "-")
    if normalized in LANGUAGE_ALIASES:
        return LANGUAGE_ALIASES[normalized]
    for code in SUPPORTED_LANGUAGES:
        if normalized == code.lower():
            return code
    raise SystemExit(
        "Unsupported language. Use one of: "
        + ", ".join(f"{code} ({name})" for code, name in SUPPORTED_LANGUAGES.items())
    )


def default_brief(language: str = "zh-CN") -> dict[str, Any]:
    language = normalize_language(language)
    return {
        "schema_version": SCHEMA_VERSION,
        "meta": {
            "created_at": now_iso(),
            "updated_at": now_iso(),
            "language": language,
            "language_name": SUPPORTED_LANGUAGES[language],
            "fallback_language": "zh-CN",
            "target": "official-codex-pet",
            "user_intro_seen": False,
        },
        "environment": {},
        "identity": {
            "name": "",
            "concept": "",
            "reference_images": [],
            "reference_likeness": "",
        },
        "likeness": {
            "strategy": "maximum-within-official-limits",
            "user_requested_level": "as-close-as-possible-within-official-limits",
            "must_preserve": [],
            "may_simplify": [],
            "must_avoid_drift": [],
            "notes": "",
        },
        "reference_research": {
            "enabled": False,
            "query": "",
            "entity_type": "",
            "chosen_version": "",
            "sources_summary": [],
            "source_links": [],
            "visual_traits": [],
            "desktop_pet_traits": [],
            "must_keep": [],
            "avoid_confusion": [],
            "user_confirmed": False,
        },
        "form": {
            "type": "",
            "notes": "",
        },
        "style": {
            "selected": [],
            "avoid_styles": [],
            "notes": "",
        },
        "personality": {
            "traits": [],
            "role": "",
            "reaction_intensity": "",
        },
        "appearance": {
            "main_colors": [],
            "must_have": [],
            "avoid": [],
            "visual_locks": [],
        },
        "usage": {
            "main_scenario": "",
            "desktop_feeling": "",
        },
        "confirmations": {
            "direction_choice": "",
            "concept_confirmation": "",
            "formal_character_image": "",
            "production_base": "",
            "production_base_preview": "",
            "production_base_report": "",
            "production_base_user_confirmed": False,
            "production_base_fit": {
                "status": "",
                "checked_at": "",
                "tool": "check_pet_asset_fit.py",
                "notes": [],
                "failures": [],
                "warnings": [],
            },
            "canonical_base": "",
            "key_action_preview": "",
            "final_card_confirmed": False,
        },
        "handoff": {
            "manifest": "",
            "run_dir": "",
        },
        "qa": {
            "output_check": "",
        },
        "actions": {
            action: {
                "frames": frames,
                "special_request": "",
                "recommended": "",
                "options": [],
                "user_choice": "",
                "final_direction": "",
                "beat_sheet": [],
                "preview_required": False,
                "preview_confirmed": False,
                "source": "",
                "user_answer": "",
                "summary": "",
                "prompt_notes": "",
            }
            for action, frames in ACTION_FRAMES.items()
        },
        "notes": [],
    }


def merge_missing(target: dict[str, Any], defaults: dict[str, Any]) -> dict[str, Any]:
    for key, value in defaults.items():
        if key not in target:
            target[key] = deepcopy(value)
        elif isinstance(target[key], dict) and isinstance(value, dict):
            merge_missing(target[key], value)
    return target


def upgrade_brief(brief: dict[str, Any]) -> dict[str, Any]:
    language = brief.get("meta", {}).get("language", "zh-CN")
    upgraded = merge_missing(brief, default_brief(language))
    upgraded["schema_version"] = SCHEMA_VERSION
    return upgraded


def load(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"Brief does not exist: {path}")
    return upgrade_brief(json.loads(path.read_text(encoding="utf-8")))


def save(path: Path, brief: dict[str, Any]) -> None:
    brief = upgrade_brief(brief)
    brief.setdefault("meta", {})["updated_at"] = now_iso()
    language = brief.setdefault("meta", {}).get("language", "zh-CN")
    normalized = normalize_language(language)
    brief["meta"]["language"] = normalized
    brief["meta"]["language_name"] = SUPPORTED_LANGUAGES[normalized]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(brief, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def parse_value(raw: str) -> Any:
    value = raw.strip()
    if value == "":
        return ""
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        return raw


def split_assignment(raw: str) -> tuple[str, Any]:
    if "=" not in raw:
        raise SystemExit(f"Expected key=value assignment, got: {raw}")
    key, value = raw.split("=", 1)
    key = key.strip()
    if not key:
        raise SystemExit(f"Empty key in assignment: {raw}")
    return key, parse_value(value)


def set_path(data: dict[str, Any], dotted_key: str, value: Any) -> None:
    parts = dotted_key.split(".")
    current: Any = data
    for part in parts[:-1]:
        if not isinstance(current, dict):
            raise SystemExit(f"Cannot set {dotted_key}: {part} is not an object")
        current = current.setdefault(part, {})
    if not isinstance(current, dict):
        raise SystemExit(f"Cannot set {dotted_key}: parent is not an object")
    current[parts[-1]] = value


def get_path(data: dict[str, Any], dotted_key: str) -> Any:
    current: Any = data
    for part in dotted_key.split("."):
        if not isinstance(current, dict) or part not in current:
            return None
        current = current[part]
    return current


def append_path(data: dict[str, Any], dotted_key: str, value: Any) -> None:
    existing = get_path(data, dotted_key)
    if existing is None:
        set_path(data, dotted_key, [value])
    elif isinstance(existing, list):
        existing.append(value)
    else:
        raise SystemExit(f"Cannot append to {dotted_key}: value is not a list")


def is_blank(value: Any) -> bool:
    return value is None or value == "" or value == [] or value == {}


def action_frame_errors(brief: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    actions = brief.get("actions", {})
    if not isinstance(actions, dict):
        return ["actions must be an object"]
    for action, expected_frames in ACTION_FRAMES.items():
        actual_frames = get_path(brief, f"actions.{action}.frames")
        if actual_frames != expected_frames:
            errors.append(
                f"actions.{action}.frames must be official value {expected_frames}, got {actual_frames!r}"
            )
    return errors


def production_base_errors(brief: dict[str, Any], brief_path: Path | None = None) -> list[str]:
    errors: list[str] = []
    production_base = get_path(brief, "confirmations.production_base")
    if is_blank(production_base):
        errors.append("confirmations.production_base is required for final production")
    else:
        base_path = Path(str(production_base)).expanduser()
        if brief_path is not None and not base_path.is_absolute():
            base_path = brief_path.parent / base_path
        if not base_path.is_file():
            errors.append(f"confirmations.production_base file does not exist: {base_path}")

    fit_status = str(get_path(brief, "confirmations.production_base_fit.status") or "").lower()
    if fit_status != "pass":
        errors.append("confirmations.production_base_fit.status must be 'pass'")
    return errors


def validation_errors_for_stage(
    brief: dict[str, Any], stage: str, brief_path: Path | None = None
) -> tuple[list[str], list[str]]:
    required = [
        "identity.concept",
        "form.type",
        "style.selected",
        "personality.traits",
        "appearance.must_have",
        "appearance.avoid",
    ]
    if stage in {"locked", "final"}:
        required.extend(
            [
                "confirmations.formal_character_image",
                "appearance.visual_locks",
            ]
        )
    if stage == "final":
        required.extend(
            [
                "confirmations.production_base",
                "confirmations.production_base_fit.status",
                "confirmations.production_base_user_confirmed",
                "confirmations.final_card_confirmed",
            ]
        )
        for action in ACTION_FRAMES:
            required.append(f"actions.{action}.final_direction")

    reference_research = brief.get("reference_research", {})
    if isinstance(reference_research, dict) and reference_research.get("enabled"):
        required.extend(
            [
                "reference_research.query",
                "reference_research.entity_type",
                "reference_research.visual_traits",
                "reference_research.desktop_pet_traits",
            ]
        )
        if stage in {"locked", "final"}:
            required.append("reference_research.user_confirmed")

    missing: list[str] = []
    for key in required:
        value = get_path(brief, key)
        if is_blank(value) or value is False:
            missing.append(key)

    invalid: list[str] = []
    invalid.extend(action_frame_errors(brief))
    if stage == "final":
        invalid.extend(production_base_errors(brief, brief_path))
    return missing, invalid


def missing_for_stage(brief: dict[str, Any], stage: str) -> list[str]:
    missing, _invalid = validation_errors_for_stage(brief, stage)
    return missing


def command_init(args: argparse.Namespace) -> int:
    path = Path(args.path).expanduser()
    if path.exists() and not args.force:
        raise SystemExit(f"Brief already exists: {path}. Use --force to replace it.")
    brief = default_brief(args.language)
    if args.pet_name:
        brief["identity"]["name"] = args.pet_name
    if args.concept:
        brief["identity"]["concept"] = args.concept
    save(path, brief)
    print(f"Created brief: {path}")
    return 0


def command_update(args: argparse.Namespace) -> int:
    path = Path(args.path).expanduser()
    brief = load(path)
    for raw in args.set or []:
        key, value = split_assignment(raw)
        set_path(brief, key, value)
    for raw in args.append or []:
        key, value = split_assignment(raw)
        append_path(brief, key, value)
    save(path, brief)
    print(f"Updated brief: {path}")
    return 0


def command_show(args: argparse.Namespace) -> int:
    brief = load(Path(args.path).expanduser())
    print(json.dumps(brief, ensure_ascii=False, indent=2))
    return 0


def command_validate(args: argparse.Namespace) -> int:
    path = Path(args.path).expanduser()
    brief = load(path)
    missing, invalid = validation_errors_for_stage(brief, args.stage, path)
    if missing or invalid:
        print(f"Brief is missing {len(missing)} required fields for stage '{args.stage}':")
        for key in missing:
            print(f"- {key}")
        if invalid:
            print(f"Brief has {len(invalid)} invalid fields for stage '{args.stage}':")
            for error in invalid:
                print(f"- {error}")
        return 1
    print(f"Brief is valid for stage '{args.stage}': {path}")
    return 0


def command_template(args: argparse.Namespace) -> int:
    brief = default_brief(args.language)
    if args.compact:
        brief = {
            "meta": deepcopy(brief["meta"]),
            "identity": deepcopy(brief["identity"]),
            "likeness": deepcopy(brief["likeness"]),
            "reference_research": deepcopy(brief["reference_research"]),
            "form": deepcopy(brief["form"]),
            "style": deepcopy(brief["style"]),
            "personality": deepcopy(brief["personality"]),
            "appearance": deepcopy(brief["appearance"]),
            "confirmations": deepcopy(brief["confirmations"]),
            "actions": deepcopy(brief["actions"]),
        }
    print(json.dumps(brief, ensure_ascii=False, indent=2))
    return 0


def command_languages(args: argparse.Namespace) -> int:
    for code, name in SUPPORTED_LANGUAGES.items():
        print(f"{code}\t{name}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    init = sub.add_parser("init", help="Create a new pet brief.")
    init.add_argument("--path", required=True)
    init.add_argument("--pet-name")
    init.add_argument("--concept")
    init.add_argument("--language", default="zh-CN", help="Conversation language code, such as zh-CN or en.")
    init.add_argument("--force", action="store_true")
    init.set_defaults(func=command_init)

    update = sub.add_parser("update", help="Update fields in an existing brief.")
    update.add_argument("--path", required=True)
    update.add_argument("--set", action="append", default=[])
    update.add_argument("--append", action="append", default=[])
    update.set_defaults(func=command_update)

    show = sub.add_parser("show", help="Print a brief.")
    show.add_argument("--path", required=True)
    show.set_defaults(func=command_show)

    validate = sub.add_parser("validate", help="Validate required brief fields.")
    validate.add_argument("--path", required=True)
    validate.add_argument("--stage", choices=["draft", "locked", "final"], default="draft")
    validate.set_defaults(func=command_validate)

    template = sub.add_parser("template", help="Print an empty brief template.")
    template.add_argument("--compact", action="store_true")
    template.add_argument("--language", default="zh-CN", help="Conversation language code, such as zh-CN or en.")
    template.set_defaults(func=command_template)

    languages = sub.add_parser("languages", help="List supported language codes.")
    languages.set_defaults(func=command_languages)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
