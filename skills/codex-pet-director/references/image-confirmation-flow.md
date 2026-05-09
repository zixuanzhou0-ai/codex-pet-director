# Image Confirmation Flow

Use images to help the user decide. Do not confuse confirmation images with production images.

## Image Roles

### User Confirmation Images

These are drafts shown to the user.

Default counts:

- Character direction: 2-4 images
- Form comparison: 2-3 images
- Style comparison: 2-4 images
- Formal character image: 1-2 images
- Key action preview: only selected key rows by default, usually `idle`, `running-right`, `failed`, and `review`

Goal: help the user choose direction, form, style, expression, and major action personality.

Record the chosen broad visual direction as `confirmations.concept_confirmation` when a specific image becomes the user's preferred concept.

### Formal Character Image

This is the high-detail image that locks the character's appearance for the conversation. It may be beautiful, expressive, and close to a reference image, but it is still not the production input for `hatch-pet`.

Record it as `confirmations.formal_character_image`.

Tell the user:

```text
这张图用来锁定角色长相，不是最终动画资产。
接下来我会把它压成适合 Codex 桌宠的生产版本。
```

### Production Base

This is the only image role that may be handed to `hatch-pet` as the main production reference.

It must:

- preserve the strongest user-requested identity cues
- fit the official 192x208 pet boundary
- use transparent or clean flat chroma background
- have simple readable silhouette and limited detail
- pass `scripts/check_pet_asset_fit.py`

Record it as `confirmations.production_base` and record the check result as `confirmations.production_base_fit`.

When running `check_pet_asset_fit.py --output-dir`, also record:

- `confirmations.production_base_preview`: `cell-preview.png`
- `confirmations.production_base_report`: `review.md`
- `confirmations.production_base_user_confirmed`: true only after the user confirms the 192x208 preview

### Production Images

These are created later for the actual pet package:

- production base reference
- 9 action row strips
- contact sheet
- preview videos
- final spritesheet

Goal: create a working official Codex pet.

Tell the user:

```text
前面给你看的图，是帮你选方向的草稿图。
角色确认后，我会再做一张适合 192x208 的生产基准图。
只有生产基准图通过检查后，才会进入正式动作生成。
```

## Per-Block Image Strategy

| Block | Image strategy |
| --- | --- |
| 它是谁 | Generate broad character directions if enough visual detail exists. |
| 它是什么形态 | Generate form comparison only if the user is unsure. |
| 它是什么风格 | Generate style variants using the same character concept. |
| 它是什么性格 | Generate expression or mood previews, not full redesigns. |
| 它长什么样 | Generate the formal character image, lock identity, then generate and check `production_base`. |
| 动作导演 | Ask for special action moments, fill the 9 official actions, then generate selected key action previews before full production. |
| 最终确认 | Show pet card; do not generate more unless user asks for revisions. |

## Selection Language

Ask:

```text
你更喜欢哪一个？
也可以混合，比如“要 A 的脸 + B 的颜色 + C 的气质”。
```

If the user wants changes, ask concrete choices:

```text
你想改哪里？颜色、脸、表情、形态、风格、道具、可爱程度、酷感、复杂程度？
```

## Identity Lock

After the formal character image is confirmed:

```text
从现在开始，我会保持它的脸、颜色、形态和主要特征不变，只调整动作。
```

Then all later prompts must include the confirmed formal character image, the checked production base when available, and the pet brief's visual locks.

For production, the identity lock must be translated into `production_base`: keep the user's must-preserve traits, simplify fragile details, and do not change the core character. If `production_base` fails the 192x208 check, do not continue to `hatch-pet`.
