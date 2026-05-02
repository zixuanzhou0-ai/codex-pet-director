# Reference Research

Use this when the user names a known person or character instead of giving a detailed visual description.

Examples:

- 明星、演员、歌手、运动员、公众人物
- 动漫角色、游戏角色、影视角色、漫画角色
- 品牌吉祥物、网络形象、虚拟主播、知名 IP 角色

## When To Research

Research before image generation when:

- the user says "做一个像 XXX 的宠物"
- the user names a celebrity, public figure, anime/game/film character, or mascot
- the user mentions a specific version, outfit, era, skin, form, or scene
- the name could have changed visually over time

Do not browse if the user provides a clear reference image and says to follow that image only. In that case, ask for likeness level and continue with the image as the source of truth.

## User-Facing Wording

Keep it simple:

```text
我先查一下这个人物/角色长什么样，避免凭记忆做错。
查完我会总结几个关键外观点，你确认以后我再出图。
```

If the name is ambiguous:

```text
这个名字可能有几个版本。你说的是哪一个？
A. ...
B. ...
C. 我发参考图，你按我的图来
```

After research:

```text
我查到的关键外观是：
1. ...
2. ...
3. ...

你想保留哪些？有没有哪个版本不是你要的？
```

## Source Preference

Use current web search. Prefer:

- official pages, studio/game/publisher pages, verified profile pages
- official wiki or character pages when available
- reliable image/reference pages when official sources are insufficient
- recent sources for living public figures whose appearance may change

Use 2-4 source links in the research summary when possible. Do not quote long source text.

## What To Extract

For real people:

- hair style and hair color
- face impression and expression
- common outfit or visual era
- pose or stage/screen persona
- recognizable accessories
- user-specified period, if any

For fictional characters:

- hair color and silhouette
- eyes, expression, and face shape
- outfit shape and main colors
- signature prop, symbol, or accessory
- personality vibe
- version or form, such as classic, movie, game skin, school outfit, armor, child/adult form

## Desktop Pet Translation

Convert research into small-pet traits. Do not carry over tiny details that will not read at desktop-pet size.

Prioritize:

- silhouette
- 2-3 main colors
- one clear face or hair feature
- one prop or accessory
- one expression habit
- one action personality

Avoid:

- too many costume details
- complex patterns
- tiny text
- large detached background effects
- fragile details that will drift between frames

## Brief Fields

Record research in `pet_brief.json`:

```json
"reference_research": {
  "enabled": true,
  "query": "用户说的名字",
  "entity_type": "real_person | fictional_character | mascot | unknown",
  "chosen_version": "用户确认的版本",
  "sources_summary": [
    "source name: what it confirmed"
  ],
  "source_links": [
    "https://..."
  ],
  "visual_traits": [
    "researched external appearance trait"
  ],
  "desktop_pet_traits": [
    "simplified trait to preserve at pet size"
  ],
  "must_keep": [
    "important recognizable points"
  ],
  "avoid_confusion": [
    "versions, colors, or traits that are not intended"
  ],
  "user_confirmed": false
}
```

Only set `user_confirmed` to true after the user confirms the research card.

## Research Card Template

```text
参考角色识别卡

我查的是：
版本：
类型：

关键外观：
- 
- 
- 

适合桌宠保留：
- 
- 
- 

不要混淆成：
- 

参考来源：
- 
- 

这个版本对吗？如果对，我再生成 2-4 张确认图。
```
