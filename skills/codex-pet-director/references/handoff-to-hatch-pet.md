# Handoff To Hatch Pet

Use this guide after the user confirms the pet card and key action direction.

## Preconditions

Confirm:

- Environment check is ready or warnings have been handled.
- `pet_brief.json` validates for the final stage.
- Formal character image is confirmed.
- Canonical base image path is recorded.
- The 9 official actions have user-approved descriptions.
- The user understands this is the official Codex pet format.

## Load Hatch Pet

Before production, load:

```text
${CODEX_HOME:-$HOME/.codex}/skills/hatch-pet/SKILL.md
```

Follow `hatch-pet` exactly for base generation, row generation, subagent row work, finalization, QA, and packaging.

## Convert Brief To Hatch Pet Inputs

Use:

- `identity.name` as the pet display name when present.
- `identity.concept` + `form.type` + `style.selected` + `personality.traits` as the description basis.
- `appearance.visual_locks` as identity lock notes.
- `appearance.must_have` as required traits.
- `appearance.avoid` and `style.avoid_styles` as avoid notes.
- `confirmations.canonical_base` as the key reference image.
- `actions.*.summary` and `actions.*.prompt_notes` as row-specific notes.

If no display name exists, ask for one or propose 3 short names.

## Handoff Summary Template

Before starting `hatch-pet`, summarize:

```text
我准备开始制作正式 Codex 宠物包。
我会保留：
- ...

9 个动作会这样做：
- idle: ...
- running: ...
- waiting: ...
- failed: ...
- review: ...
- jumping: ...
- waving: ...
- running-right: ...
- running-left: ...
```

## QA Expectations

After `hatch-pet` finalizes, review:

- `qa/contact-sheet.png`
- `qa/review.json`
- `final/validation.json`
- preview videos when available
- installed `pet.json`
- installed `spritesheet.webp`

Block completion if the character identity drifts, background is not clean, unused cells are not transparent, or official action rows do not match the expected frame counts.
