# Style Menu

Offer style choices in simple Chinese. Internally translate user choices into stable visual rules for small Codex pets.

## Default Recommendation

If the user is unsure, recommend:

```text
可爱 + 像素游戏 + Codex 科技感
```

This combination usually reads well at 192x208.

## Styles

| User choice | User meaning | Internal visual translation |
| --- | --- | --- |
| 可爱软萌 | 圆圆的、亲切、治愈 | rounded shapes, soft face, simple warm expression, limited palette, chunky outline |
| 酷酷赛博 | 发光、屏幕、机械、小科技感 | screen face, small glow accents, teal/blue highlights, simple mechanical ears/tail, no busy wires |
| 像素游戏 | 复古、像小游戏角色、动作清楚 | pixel-adjacent edges, strong silhouette, clear poses, low-detail props |
| 日系 Q 版 | 大头小身、表情丰富 | chibi proportions, large readable face, tiny limbs, expressive eyes |
| 魔法幻想 | 披风、星星、法杖、小魔法感 | tiny cloak, charm, wand, attached opaque sparkle-like accents, no large spell circles |
| 职场助手 | 干净、专业、可靠小搭档 | tidy silhouette, small tool/notebook/keyboard prop, calm expression, restrained movement |
| 搞笑捣蛋 | 表情夸张、动作有梗 | elastic expressions, mischievous eyes, exaggerated but readable poses |
| 暗黑神秘 | 安静、深色、神秘但不要恐怖 | darker palette, small glow, quiet face, no gore, no horror detail |

## Questions

Ask:

```text
你希望它更可爱、更酷、更像游戏角色、更像小助手，还是更搞笑？
可以混合，比如“可爱 + 赛博”。
```

Ask dislike preferences:

```text
有没有你不喜欢的风格？
比如不要太幼稚、不要太写实、不要太复杂、不要太暗。
```

## Prompt Rules

- Keep the Codex pet house style: compact, readable, transparent-background friendly, thick outline, limited colors.
- Simplify any detailed style into a small mascot.
- Avoid long style stacks. Use at most two dominant styles and one accent.
- Use the user's words in the summary, but use the internal translation in generation prompts.
