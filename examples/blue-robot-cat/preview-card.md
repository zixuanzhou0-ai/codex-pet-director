# Blue Robot Cat Preview Card

## User Idea

做一个蓝色机器人猫，像一个陪我写代码的小助手。它不要太幼稚，也不要太写实，要有一点赛博感，但整体还是可爱。

## Locked Direction

- **Name**: BitCat
- **Form**: 半身小伙伴
- **Style**: 可爱软萌 + 酷酷赛博
- **Personality**: 聪明、安静、偶尔吐槽
- **Main colors**: electric blue, white, graphite gray
- **Must keep**: screen-face eyes, small cat ears, tiny code badge, compact silhouette
- **Avoid**: scary face, heavy armor, realistic fur, long text on body

## Confirmation Image Choices

The user picked:

```text
要 A 的脸 + B 的颜色 + C 的气质。
```

That means future action prompts must keep the same face, colors, ears, badge, and body shape.

## Action Summary

| Official action | User-facing behavior |
| --- | --- |
| `idle` | blinks slowly and breathes with a tiny screen glow |
| `running-right` | slides right with small paw boosters |
| `running-left` | mirrors the right movement, preserving the badge side if possible |
| `waving` | raises one paw and flashes a small greeting icon |
| `jumping` | pops up in surprise when the mouse approaches |
| `failed` | screen glitches, ears droop, then weakly restarts |
| `waiting` | tilts head and taps a tiny paw |
| `running` | scans code quickly with screen eyes moving left to right |
| `review` | leans forward and gives a strict checking look |

## Production Handoff

When the user confirms the final card, create a simplified `production_base` for the official `192x208` pet cell, run `check_pet_asset_fit.py`, then generate `hatch_pet_handoff.json` with `build_hatch_handoff.py`.

Only after that handoff exists should the flow pass the locked brief to `hatch-pet`. Do not add extra official actions or extra frames, and do not use the high-detail confirmation image as the main production reference.
