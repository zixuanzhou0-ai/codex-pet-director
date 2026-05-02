# Image Confirmation Flow

Use images to help the user decide. Do not confuse confirmation images with production images.

## Two Image Types

### User Confirmation Images

These are drafts shown to the user.

Default counts:

- Character direction: 2-4 images
- Form comparison: 2-3 images
- Style comparison: 2-4 images
- Formal character image: 1-2 images
- Key action preview: 3-5 images

Goal: help the user choose direction, form, style, expression, and major action personality.

### Production Images

These are created later for the actual pet package:

- canonical base reference
- 9 action row strips
- contact sheet
- preview videos
- final spritesheet

Goal: create a working official Codex pet.

Tell the user:

```text
前面给你看的图，是帮你选方向的草稿图。
最后真正做宠物时，我会再生成完整动作。
```

## Per-Block Image Strategy

| Block | Image strategy |
| --- | --- |
| 它是谁 | Generate broad character directions if enough visual detail exists. |
| 它是什么形态 | Generate form comparison only if the user is unsure. |
| 它是什么风格 | Generate style variants using the same character concept. |
| 它是什么性格 | Generate expression or mood previews, not full redesigns. |
| 它长什么样 | Generate the formal character image and lock identity. |
| 它怎么动 | Generate key action previews before full production. |
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

Then all later prompts must include the confirmed canonical base image and the pet brief's visual locks.
