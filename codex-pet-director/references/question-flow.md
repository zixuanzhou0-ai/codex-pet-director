# Question Flow

Use this interview for official Codex desktop pet creation. Ask one block at a time. Keep each turn short, friendly, and concrete. Translate the wording into the user's selected language.

## Opening

Say:

```text
我会帮你做一个能直接放进 Codex 使用的高定制桌面宠物。
它会适配 Codex 官方格式，有 9 个固定动作。
你不用懂格式，我会一步一步问你，边做边给你看图确认。
```

If the language is not obvious, ask:

```text
你想用哪种语言完成这个宠物定制？
可以选：中文 / English / 日本語 / 한국어 / Español / Français / Deutsch。
你后面也可以随时说“切换到英文”。
```

Then run the environment check before asking design questions. If the user asks what this is for, load `user-introduction.md` and give the short explanation first.

## Block 1: 它是谁

Ask:

```text
你想做一个什么样的宠物？
它看起来像什么？比如小猫、机器人、云朵、咖啡杯、代码块、小怪物。
你有参考图片吗？有的话可以发给我；没有也没关系。
它有没有名字？没有的话，我可以帮你取几个。
```

After the answer, summarize:

```text
我先理解成：你想要一个……，大概像……。
```

If the user names a known person or character, run the reference research step before generating character direction images. Otherwise, generate 2-4 character direction images if enough visual detail exists.

## Block 1.5: 参考角色识别

Use this block only when the user names a celebrity, public figure, anime/game/film character, mascot, or other known figure.

Say:

```text
我先查一下这个人物/角色长什么样，避免凭记忆做错。
查完我会总结几个关键外观点，你确认以后我再出图。
```

Then follow `reference-research.md`.

After browsing, summarize:

```text
我查到的关键外观是：
1. ...
2. ...
3. ...

适合桌宠保留的是：
1. ...
2. ...
3. ...

这个版本对吗？有没有哪个地方不是你要的？
```

Only generate confirmation images after the user confirms the researched version and key traits.

## Block 2: 它是什么形态

Ask:

```text
你想它是哪种形态？
A. 全身小宠物：动作最丰富
B. 半身小伙伴：表情最清楚
C. 头像/屏幕脸：像一个小助手
D. 漂浮小东西：适合云朵、火焰、星星、机器人
E. 小物件拟人：适合键盘、咖啡杯、代码块、服务器
```

If the user is unsure, recommend full-body for movement-heavy pets and half-body for expressive companion pets.

## Block 3: 它是什么风格

Ask:

```text
你希望它更像哪种风格？可以选一个，也可以混合两个：
可爱软萌 / 酷酷赛博 / 像素游戏 / 日系 Q 版 / 魔法幻想 / 职场助手 / 搞笑捣蛋 / 暗黑神秘

有没有你不喜欢的风格？
比如不要太幼稚、不要太写实、不要太复杂、不要太暗。
```

Generate 2-4 style variations if the character direction is settled enough.

## Block 4: 它是什么性格

Ask:

```text
你希望它是什么性格？
比如安静、聪明、搞笑、暴躁、神秘、温柔、认真、爱吐槽。

它陪你用 Codex 时像什么角色？
比如小助手、搭档、监督员、捣蛋鬼、老师、测试守门员。

它的反应想低调一点，还是夸张一点？
```

For visual confirmation, generate expression or mood previews instead of redesigning the whole character.

## Block 5: 它长什么样

Ask:

```text
它身上一定要有什么？
比如颜色、耳朵、尾巴、帽子、眼睛、衣服、小工具、屏幕、翅膀。

你喜欢什么主色？有没有一定不要的颜色？

它身上一定不要有什么？
比如不要文字、不要恐怖、不要太写实、不要太复杂。

如果你给了参考图，你想它和参考图有多像？
A. 尽量接近：在 192x208 桌宠边界内尽可能像
B. 保留重点：保留最明显的特征
C. 只借鉴感觉：保留气质，不强求外形一致
```

If the user says "一模一样", "完全照着", or "尽量像", explain the boundary without asking them to lower the goal:

```text
我会尽量贴近参考图，但会把它转成 Codex 官方桌宠能承载的版本。
细碎纹理会简化，核心识别点会保留。
```

Record the likeness intent in `likeness.user_requested_level`, key traits in `likeness.must_preserve`, safe simplifications in `likeness.may_simplify`, and unwanted drift in `likeness.must_avoid_drift`.

After this block, generate or refine the formal character image. Once the user confirms it, lock the character identity. Then generate a simplified `production_base` candidate for 192x208 pet production and run `check_pet_asset_fit.py`. If it fails, regenerate or revise the production base before moving on.

## Block 6: 它怎么动

Ask about all 9 official actions in simple language:

```text
平时待着时，它在做什么？
Codex 工作时，它像在做什么？
等你回复时，它怎么表现？
Codex 失败或卡住时，它怎么反应？
有结果要你查看时，它是什么样？
鼠标放到它身上时，它怎么反应？
它打招呼时怎么做？
它向右移动时怎么动？
它向左移动时怎么动？
```

Map answers to the official action names in `action-guide.md`.

## Block 7: 最终确认

Create a pet card:

```text
名字：
形态：
风格：
性格：
主色：
还原程度：
必须保留：
为了桌宠会简化：
必须避免：
平时：
工作中：
等待：
失败：
查看结果：
鼠标靠近：
打招呼：
移动：
```

Ask:

```text
这个方向对吗？要不要改哪里？
```

Only after confirmation, hand off to `hatch-pet`.
Only hand off after `pet_brief.py validate --stage final` passes and `build_hatch_handoff.py` has created `hatch_pet_handoff.json`.
