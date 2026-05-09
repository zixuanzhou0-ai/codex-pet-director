# Architecture

Use this when the user asks how the skill works, when writing README-style explanations, or when explaining why the design uses `hatch-pet` instead of rebuilding the pet generator.

## Layered Architecture

```text
User conversation
  ↓
codex-pet-director skill
  ↓
pet_brief.json as the source of truth
  ↓
image confirmation rounds with imagegen
  ↓
locked character + production_base fit gate + Action Director
  ↓
hatch_pet_handoff.json contract
  ↓
hatch-pet final production
  ↓
Director final QA
  ↓
Codex pets folder: pet.json + spritesheet.webp
```

## Components

| Component | Role |
| --- | --- |
| `SKILL.md` | Main workflow, boundaries, and when to load references. |
| `references/question-flow.md` | Beginner-friendly interview blocks. |
| `references/language-guide.md` | Language selection and switching rules. |
| `references/user-introduction.md` | Customer-facing explanation of what the skill does. |
| `references/style-menu.md` | Simple style choices and internal visual translations. |
| `references/action-director.md` | Collects special motion requests, recommends missing actions, and confirms the action card. |
| `references/action-guide.md` | The 9 official Codex pet actions and frame expectations. |
| `references/image-confirmation-flow.md` | How to use 2-4 confirmation images without confusing them with final production images. |
| `references/handoff-to-hatch-pet.md` | How to pass the locked brief to `hatch-pet`. |
| `scripts/check_pet_environment.py` | Detects OS, Codex home, pets folder, write access, Codex desktop evidence, and `hatch-pet`. |
| `scripts/pet_brief.py` | Creates, updates, shows, validates, and language-tags `pet_brief.json`. |
| `scripts/check_pet_asset_fit.py` | Checks that `production_base` can work inside the official 192x208 pet cell. |
| `scripts/build_hatch_handoff.py` | Converts a validated brief into an explicit `hatch_pet_handoff.json` contract. |
| `scripts/check_hatch_output.py` | Checks the final pet package and creates contact sheet, row GIFs, and output JSON. |
| `install.ps1` / `install.sh` | Copies the skill into the user's Codex skills folder. |

## Why This Design

The skill separates creative direction from final production.

- The pet director handles conversation, language, choices, and visual decision-making.
- `pet_brief.json` prevents the character from drifting between rounds.
- Confirmation images let beginners choose visually instead of writing perfect prompts.
- The production-base gate lets the system pursue maximum likeness without breaking the official 192x208 asset limits.
- Action Director lets users state special character moments first, then fills missing official actions without forcing them to answer a technical form.
- `hatch_pet_handoff.json` removes guesswork between the director flow and the production generator.
- `hatch-pet` remains responsible for spritesheet assembly and final Codex package files.
- Director final QA adds a second review layer for row GIFs, transparent unused cells, and exact atlas dimensions.

This keeps the system easier to maintain. If Codex changes the pet production details later, only the production layer should need changes; the interview, language flow, and customer-facing guidance can stay stable.

## Fixed Official Format

The current official Codex pet format is treated as fixed inside this skill:

- 9 action states
- 8 columns
- 9 rows
- 192x208 cells
- 1536x1872 spritesheet atlas

The skill can customize the personality, style, body type, expressions, and how each official action is interpreted. It should not promise extra action slots, custom keyboard controls, hand controller movement, or unlimited animation rows.

## Why Use A Brief

`pet_brief.json` is the contract between the conversation and the generator.

It records:

- chosen language
- environment findings
- identity and reference images
- form and style
- personality
- visual locks
- likeness intent and the tradeoff between maximum resemblance and official pet limits
- blocked dislikes
- confirmation-image choices
- the checked `production_base` image and its asset-fit result
- 9 action special requests, recommendations, final directions, beat sheets, and preview choices

When later prompts are generated, the brief should be used as the source of truth. The confirmed face, silhouette, colors, props, and action meanings should not be reinvented.

## Why Ask In Blocks

Beginners usually do not know how to describe a complete character in one prompt. Blocks make the process easier:

1. Identity: what it is.
2. Form: full-body, half-body, face, floating object, or object mascot.
3. Style: the visual language.
4. Personality: how it should feel.
5. Appearance: must-have and must-avoid details.
6. Action Director: special action moments first, then completed 9 official actions.
7. Final card: the last review before production.

Each block can produce a small visual decision instead of forcing the user to imagine the final pet all at once.
