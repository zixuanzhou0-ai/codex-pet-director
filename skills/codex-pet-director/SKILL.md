---
name: codex-pet-director
description: Create a custom official Codex desktop pet from /create-pet, text, reference images, or named characters. Guides environment checks, beginner interviews, web reference research, confirmation images, 9 action designs, and hatch-pet handoff.
metadata:
  short-description: Create custom Codex desktop pets
---

# Codex Pet Director

## Overview

Create an official Codex desktop pet through a beginner-friendly high-customization flow. This skill owns environment checks, multilingual user interviews, style and form choices, staged image confirmations, pet brief management, and the final handoff to `$hatch-pet`.

Keep the user-facing conversation in plain Chinese by default, or in the user's selected language. Avoid technical terms unless they are necessary.

## Start Command

Treat `/create-pet` as the formal start signal for this skill. If the user's message is `/create-pet`, `create-pet`, or "开始创建宠物", start the full creation flow immediately from the environment check. Do not ask the user to repeat the command or explain skill names.

If Codex receives `/create-pet` as plain text rather than a native slash command, handle it exactly the same way.

## Hard Boundaries

- Target only the official Codex custom pet format.
- Do not present alternative product choices or external desktop-pet capabilities unless the user asks.
- Treat the Codex pet format as fixed: 8 columns x 9 rows, 192x208 cells, 1536x1872 atlas, 9 named states.
- Do not claim the user can add extra official actions, extra rows, extra frames, random behaviors, or custom controls through `pet.json`.
- Do not rewrite the lower-level spritesheet pipeline. Use `$hatch-pet` for final official pet generation and packaging.
- Keep reference-image discussion focused on likeness level. If the user provides a reference, ask how close they want the pet to feel to that reference.

## Language Handling

Use `references/language-guide.md` when the user chooses, changes, or asks about language support. The supported language codes are `zh-CN`, `zh-TW`, `en`, `ja`, `ko`, `es`, `fr`, and `de`.

At the start, infer the language from the user's message when obvious. If unclear, ask one simple language question. If the user switches language mid-flow, update `pet_brief.json` with `meta.language=<code>` and continue from the current block without restarting.

Keep official action names, file names, and tool names unchanged across languages.

## User Explanation

Use `references/user-introduction.md` when the user is new, asks what this skill does, wants a customer-facing explanation, or needs a plain-language sales/usage explanation before starting.

Use `references/architecture.md` when explaining the bottom architecture, why the workflow is designed this way, what `pet_brief.json` does, or why final production is delegated to `$hatch-pet`.

## Reference Research

Use `references/reference-research.md` when the user names a known person or character, such as a celebrity, public figure, anime character, game character, film character, mascot, brand character, or internet figure.

If the user provides only a name and no clear reference image, browse the web before generating visual confirmation images. Do not rely on memory for the appearance. Search enough to identify the correct person, character, and version, then summarize the key visual traits in plain language and ask the user to confirm.

If the name is ambiguous or has multiple versions, ask the user to choose the intended version before image generation.

## Required Flow

### 0. Check The Environment

Start every full pet creation request by checking whether the local Codex environment can host a custom pet:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/check_pet_environment.py"
```

If the pets directory is missing and the rest of the environment is plausible, create only the safe local folders:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/check_pet_environment.py" --fix
```

Never modify the installed Codex app. If the script cannot find a supported Codex desktop app or `hatch-pet`, explain the missing piece and stop before final pet production. You may still help the user design a brief and concept images if they explicitly want that.

### 1. Set Language And Interview In Small Blocks

Use the seven-block interview from `references/question-flow.md`. Ask one block at a time, not the whole questionnaire at once.

Record the chosen language when creating the brief:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" init --path /absolute/path/to/pet_brief.json --language zh-CN
```

Default blocks:

1. 它是谁
1.5. 参考角色识别, only when the user names a known person or character
2. 它是什么形态
3. 它是什么风格
4. 它是什么性格
5. 它长什么样
6. 它怎么动
7. 最终确认

After each block, summarize what was decided in simple Chinese. For important visual blocks, generate 2-4 user-facing confirmation images and ask which direction they prefer. A user may answer by mixing choices, for example: `要 A 的脸 + B 的颜色 + C 的气质`.

When reference research is triggered, complete it before generating character direction images. Record the research result in `pet_brief.json` under `reference_research`.

### 2. Maintain A Pet Brief

Create or update a `pet_brief.json` in the working folder while interviewing:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" init --path /absolute/path/to/pet_brief.json
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" languages
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" update --path /absolute/path/to/pet_brief.json --set identity.concept="蓝色屏幕脸机器人猫"
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/pet_brief.py" validate --path /absolute/path/to/pet_brief.json --stage final
```

Use the brief as the source of truth for all prompts, confirmation summaries, and final handoff. Once the user confirms the formal character image, lock the identity: keep the same face, colors, body type, props, and core silhouette for all actions.

### 3. Generate Confirmation Images

For visual confirmation images, use `$imagegen`. Load the image generation skill before generating images:

```text
${CODEX_HOME:-$HOME/.codex}/skills/.system/imagegen/SKILL.md
```

Confirmation images are decision aids, not the final spritesheet. Follow `references/image-confirmation-flow.md` to keep this clear:

- early images help users choose identity, form, style, and expression
- production images later create the base reference and 9 official action rows

Do not use local scripts, SVG, canvas, or handmade image editing as a substitute for generated visual confirmation images.

### 4. Design The 9 Official Actions

Use `references/action-guide.md` for state names, frame counts, and beginner-friendly questions.

Official states:

- `idle`
- `running-right`
- `running-left`
- `waving`
- `jumping`
- `failed`
- `waiting`
- `running`
- `review`

Adapt movement to the pet form. A half-body pet, screen face, floating object, or object mascot does not need literal legs; translate movement into drifting, bouncing, tilting, sliding, jetting, screen flicker, or prop motion.

### 5. Hand Off To Hatch Pet

When the user has confirmed:

- environment is usable
- character direction
- formal character image
- key actions
- final pet card

load `$hatch-pet` and follow its workflow. Use `references/handoff-to-hatch-pet.md` to convert the pet brief into `hatch-pet` inputs. The `hatch-pet` skill owns base generation, row generation, atlas assembly, QA, preview videos, `pet.json`, and `spritesheet.webp`.

## Reference Files

- `references/question-flow.md`: user interview blocks and simple wording.
- `references/reference-research.md`: web research workflow for named people and characters.
- `references/language-guide.md`: supported languages and switching rules.
- `references/user-introduction.md`: detailed customer-facing explanation.
- `references/architecture.md`: bottom architecture, component roles, and design rationale.
- `references/style-menu.md`: style choices and internal visual translations.
- `references/action-guide.md`: official action slots, frame counts, and form adaptation.
- `references/image-confirmation-flow.md`: staged confirmation image policy.
- `references/handoff-to-hatch-pet.md`: final production handoff.

## Acceptance Criteria

- The flow starts with an environment check.
- The user's language is inferred or confirmed, recorded in `pet_brief.json`, and can be switched without restarting.
- The user is asked simple questions one block at a time.
- Named people or characters are researched online before visual generation unless the user provides a sufficient reference image.
- A `pet_brief.json` exists before final production.
- The official Codex fixed format is respected.
- The formal character image is locked before action generation.
- Final production is delegated to `$hatch-pet`.
- The final installed pet contains `pet.json` and `spritesheet.webp` under `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/`.
