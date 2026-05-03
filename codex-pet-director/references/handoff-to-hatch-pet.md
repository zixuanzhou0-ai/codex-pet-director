# Handoff To Hatch Pet

Use this guide after the user confirms the pet card and key action direction.

## Preconditions

Confirm:

- Environment check is ready or warnings have been handled.
- `pet_brief.json` validates for the final stage.
- Formal character image is confirmed.
- `confirmations.production_base` is recorded.
- `confirmations.production_base_fit.status` is `pass`.
- The 9 official actions have user-approved descriptions.
- The user understands this is the official Codex pet format.

Never use a high-resolution confirmation image, selfie, anime screenshot, concept image, or polished illustration as the main `hatch-pet` reference. Those images can explain intent, but only `production_base` may be the production reference.

## Load Hatch Pet

Before production, load:

```text
${CODEX_HOME:-$HOME/.codex}/skills/hatch-pet/SKILL.md
```

Follow `hatch-pet` exactly for base generation, row generation, subagent row work, finalization, QA, and packaging.

Build the explicit handoff first:

```bash
python "${CODEX_HOME:-$HOME/.codex}/skills/codex-pet-director/scripts/build_hatch_handoff.py" \
  --brief /absolute/path/to/pet_brief.json \
  --output-dir /absolute/path/to/run
```

## Convert Brief To Hatch Pet Inputs

Use:

- `identity.name` as the pet display name when present.
- `identity.concept` + `form.type` + `style.selected` + `personality.traits` as the description basis.
- `likeness.user_requested_level`, `likeness.must_preserve`, `likeness.may_simplify`, and `likeness.must_avoid_drift` as the likeness contract.
- `appearance.visual_locks` as identity lock notes.
- `appearance.must_have` as required traits.
- `appearance.avoid` and `style.avoid_styles` as avoid notes.
- `confirmations.production_base` as the only key production reference image.
- `confirmations.formal_character_image` as auxiliary intent only, not the production base.
- `actions.*.summary` and `actions.*.prompt_notes` as row-specific notes.

If no display name exists, ask for one or propose 3 short names.

## Handoff Summary Template

Before starting `hatch-pet`, summarize:

```text
我准备开始制作正式 Codex 宠物包。
我会使用已经通过 192x208 检查的生产基准图，不会直接用高清确认图做动画。
我会保留：
- ...
为了桌宠清晰度会简化：
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

Also block completion if the run used anything other than `confirmations.production_base` as the main `--reference` for `prepare_pet_run.py`.
