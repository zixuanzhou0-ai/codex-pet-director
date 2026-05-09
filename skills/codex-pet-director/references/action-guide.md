# Action Guide

Official Codex pets use 9 fixed action rows. The action names, row order, and frame counts are not user-configurable. The user can customize how each fixed state performs.

| State | Frames | User-facing meaning | Good directions |
| --- | ---: | --- | --- |
| `idle` | 6 | 平时待着时是什么状态 | breathe, blink, stare, crossed arms, small prop motion |
| `running-right` | 8 | 向右移动时怎么动 | run, hop, slide, drift, jet, quick steps |
| `running-left` | 8 | 向左移动时怎么动 | mirror only when safe, otherwise redraw with leftward motion |
| `waving` | 4 | 打招呼或回应你 | wave, nod, salute, raise paw, cold gesture |
| `jumping` | 5 | 鼠标碰到时怎么反应 | hop, startled pop, happy bounce, alert recoil |
| `failed` | 8 | Codex 失败或卡住时怎么反应 | droop, angry stomp, short-circuit, sigh, pretend okay |
| `waiting` | 6 | 等用户回复时怎么表现 | patient stare, nudge, tap, yawn, impatient look |
| `running` | 6 | Codex 工作中像在做什么 | working, charging up, scanning, thinking fast, loading |
| `review` | 6 | 有结果要查看时是什么状态 | inspect, judge, nod, frown, detective focus |

## User Guidance Questions

Ask about character performance first, not technical row names:

```text
这个角色有没有哪几个动作你特别想看到？
比如平时、失败、等待、查看结果、鼠标碰到、打招呼、移动、工作中，它应该表现出什么性格？
```

Use simple option menus if the user is unsure:

```text
失败时你希望它怎么反应？
A. 沮丧低头
B. 生气跺脚
C. 假装没事
D. 短路冒烟
E. 你自己描述
```

```text
等你回复时它怎么表现？
A. 安静等
B. 看着你
C. 轻轻催你
D. 不耐烦
E. 你自己描述
```

```text
有结果要看时它像什么？
A. 开心展示
B. 严肃检查
C. 骄傲点头
D. 像审判结果
E. 你自己描述
```

## Form Adaptation

Do not force literal legs or full-body acting when the selected form does not support it.

| Form | Movement adaptation |
| --- | --- |
| 全身小宠物 | run, hop, jump, wave, stomp, crouch, expressive full-body reactions |
| 半身小伙伴 | shoulder bob, head tilt, face expression, hand/prop movement |
| 头像/屏幕脸 | screen flicker, eye changes, bounce, drift, tilt, expression changes |
| 漂浮小东西 | drift, bob, tilt, tiny jet, rotation, attached prop motion |
| 小物件拟人 | slide, wobble, tiny feet, lid/handle movement, face changes |

## Running Left Rule

Do not blindly mirror `running-right`.

Mirror only when all are true:

- the design is visually symmetric enough
- no one-sided accessory becomes wrong
- no readable text or logo is flipped
- lighting or markings do not become confusing
- the user has not asked for a different left movement

Otherwise, make `running-left` a separate action direction.

## Beat Examples

Use frame beats when writing prompts.

`idle` 6-frame example:

```text
1 stable pose, 2 slight inhale, 3 blink, 4 hair/prop moves, 5 exhale, 6 returns to loop
```

`failed` 8-frame example:

```text
1 normal freeze, 2 eyes tighten, 3 body droops or tenses, 4 attached smoke/tear/star if appropriate, 5 holds reaction, 6 low point, 7 weak recovery, 8 settles into failed pose
```

`waiting` 6-frame example:

```text
1 neutral, 2 looks toward user, 3 head tilt, 4 tiny tap or prop movement, 5 holds patiently, 6 returns to loop
```

`review` 6-frame example:

```text
1 leans in, 2 eyes scan, 3 prop/screen glows if already part of identity, 4 nods or frowns, 5 makes judging pose, 6 returns to focus
```

## Prompt Rules

- Preserve the locked identity across all states.
- Prefer pose, expression, and attached prop motion over detached effects.
- Avoid text, UI, grids, shadows, backgrounds, loose symbols, and effects that drift away from the sprite.
- Keep every pose inside one 192x208 cell.
- If `running-left` would break an asymmetric design when mirrored, generate it separately.
- Record a final direction and beat sheet for every official action before handoff.
