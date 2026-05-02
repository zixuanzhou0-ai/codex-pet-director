# Language Guide

Use this file when the user wants another language, when the user's language is unclear, or when they ask whether the pet director supports multiple languages.

## Supported Languages

Default to Simplified Chinese unless the user writes in another language or explicitly chooses one.

| Code | Name | User-facing choice |
| --- | --- | --- |
| `zh-CN` | 简体中文 | 中文 |
| `zh-TW` | 繁體中文 | 繁體中文 |
| `en` | English | English |
| `ja` | 日本語 | 日本語 |
| `ko` | 한국어 | 한국어 |
| `es` | Español | Español |
| `fr` | Français | Français |
| `de` | Deutsch | Deutsch |

## First Language Question

Ask this once near the start, after or alongside the environment check:

```text
你想用哪种语言完成这个宠物定制？
可以选：中文 / English / 日本語 / 한국어 / Español / Français / Deutsch。
你后面也可以随时说“切换到英文”。
```

If the user already writes in a supported language, continue in that language and say briefly that they can switch later.

## Switching Rule

When the user asks to switch language:

1. Confirm the new language in that language.
2. Update `pet_brief.json` with `meta.language=<code>`.
3. Continue from the current block. Do not restart the interview.
4. Keep already confirmed character choices unchanged.

Example:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" update --path /absolute/path/to/pet_brief.json --set meta.language=en
```

## Translation Rules

- Translate all user-facing questions, summaries, pet cards, and confirmations.
- Keep official action keys in English: `idle`, `running-right`, `running-left`, `waving`, `jumping`, `failed`, `waiting`, `running`, `review`.
- Keep file names and paths unchanged.
- Use simple words in every language. The target user may be new to Codex, GitHub, image generation, and pet files.
- Do not translate `Codex`, `hatch-pet`, `pet.json`, `spritesheet.webp`, or `pet_brief.json`.
- If a phrase has no good local equivalent, explain it in plain language instead of using jargon.

## Language-Specific Tone

- `zh-CN`: 清楚、直接、像一个定制向导。
- `zh-TW`: 保持繁體，避免大陆简体词混入。
- `en`: Clear product-assistant tone; avoid technical terms unless needed.
- `ja`: 丁寧で短く、専門語を使う時は説明を添える。
- `ko`: 친절하고 간결하게, 기술 용어는 간단히 풀어쓴다.
- `es`: Claro, cercano, sin tecnicismos innecesarios.
- `fr`: Clair, sobre, avec des explications courtes.
- `de`: Direkt, strukturiert, mit kurzen Erklärungen.

## Image Prompt Language

User-facing explanations should use the selected language. Internal image prompts may use English when that improves image generation consistency, but preserve the user's names, reference details, colors, and confirmed visual locks.
