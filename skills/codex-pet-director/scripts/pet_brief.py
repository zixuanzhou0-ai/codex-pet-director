#!/usr/bin/env python3
"""Create, update, inspect, and validate Codex pet brief JSON files."""

from __future__ import annotations

import argparse
import json
from copy import deepcopy
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


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
        "schema_version": 1,
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
            "formal_character_image": "",
            "canonical_base": "",
            "key_action_preview": "",
            "final_card_confirmed": False,
        },
        "actions": {
            action: {
                "frames": frames,
                "user_answer": "",
                "summary": "",
                "prompt_notes": "",
            }
            for action, frames in ACTION_FRAMES.items()
        },
        "notes": [],
    }


def load(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"Brief does not exist: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def save(path: Path, brief: dict[str, Any]) -> None:
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


def missing_for_stage(brief: dict[str, Any], stage: str) -> list[str]:
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
                "confirmations.canonical_base",
                "appearance.visual_locks",
            ]
        )
    if stage == "final":
        required.append("confirmations.final_card_confirmed")
        for action in ACTION_FRAMES:
            required.append(f"actions.{action}.user_answer")

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
    missing = missing_for_stage(brief, args.stage)
    if missing:
        print(f"Brief is missing {len(missing)} required fields for stage '{args.stage}':")
        for key in missing:
            print(f"- {key}")
        return 1
    print(f"Brief is valid for stage '{args.stage}': {path}")
    return 0


def command_template(args: argparse.Namespace) -> int:
    brief = default_brief(args.language)
    if args.compact:
        brief = {
            "meta": deepcopy(brief["meta"]),
            "identity": deepcopy(brief["identity"]),
            "reference_research": deepcopy(brief["reference_research"]),
            "form": deepcopy(brief["form"]),
            "style": deepcopy(brief["style"]),
            "personality": deepcopy(brief["personality"]),
            "appearance": deepcopy(brief["appearance"]),
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
