# Action Guide

Official Codex pets use 9 fixed action rows. The action names, row order, and frame counts are not user-configurable.

| State | Frames | User-facing question | Common directions |
| --- | ---: | --- | --- |
| `idle` | 6 | 平时待着时，它在做什么？ | blink, breathe, tail sway, prop wiggle, quiet stare |
| `running-right` | 8 | 它向右移动时怎么动？ | run, hop, slide, drift, jet, teleport, tiny steps |
| `running-left` | 8 | 它向左移动时怎么动？ | mirror right movement if safe, otherwise redraw |
| `waving` | 4 | 它打招呼时怎么做？ | wave, nod, salute, raise paw, lift tool |
| `jumping` | 5 | 鼠标放到它身上时，它怎么反应？ | hop, happy bounce, shy jump, startled pop |
| `failed` | 8 | Codex 失败或卡住时，它怎么反应？ | droop, smoke, short-circuit, sigh, angry stomp, pretend okay |
| `waiting` | 6 | 等你回复时，它怎么表现？ | head tilt, look at user, tap foot, yawn, quiet nudge |
| `running` | 6 | Codex 工作时，它像在做什么？ | typing, scanning, thinking fast, carrying code, casting, loading |
| `review` | 6 | 有结果要你查看时，它是什么样？ | inspect, nod, frown, detective look, focus loop |

## Form Adaptation

Do not force literal legs or full-body acting when the selected form does not support it.

| Form | Movement adaptation |
| --- | --- |
| 全身小宠物 | run, hop, jump, wave, expressive full-body reactions |
| 半身小伙伴 | body bob, head tilt, face expression, shoulder/prop movement |
| 头像/屏幕脸 | screen flicker, eye changes, small bounce, tilt, glow pulse |
| 漂浮小东西 | drift, bob, tilt, tiny jet, orbiting attached prop |
| 小物件拟人 | slide, wobble, tiny feet, lid/handle movement, face changes |

## Beat Examples

Use frame beats when writing prompts.

`failed` 8-frame example:

```text
1 normal freeze, 2 eyes glitch, 3 body droops, 4 tiny attached smoke puff, 5 ears/prop slump, 6 sits low, 7 weak restart blink, 8 settles into failed pose
```

`waiting` 6-frame example:

```text
1 neutral, 2 looks toward user, 3 head tilt, 4 tiny tap or prop movement, 5 holds patiently, 6 returns to loop
```

`review` 6-frame example:

```text
1 leans in, 2 eyes scan, 3 prop/screen glows, 4 nods or frowns, 5 makes judging pose, 6 returns to focus
```

## Prompt Rules

- Preserve the locked identity across all states.
- Prefer pose, expression, and attached prop motion over detached effects.
- Avoid text, UI, grids, shadows, backgrounds, loose symbols, and effects that drift away from the sprite.
- Keep every pose inside one 192x208 cell.
- If `running-left` would break an asymmetric design when mirrored, generate it separately.
