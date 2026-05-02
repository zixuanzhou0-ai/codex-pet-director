# User Introduction

Use this when the user is new, asks "what is this", shares the skill with customers, or needs a clear explanation before starting.

## Short Introduction

```text
这是一个 Codex 桌面宠物高定制向导。
你不用懂图片格式、动作帧或安装目录。我会先检查你的环境，然后像做角色设定一样，一步一步问你想要什么宠物，并在关键阶段生成几张图让你选。
最后确认后，我会把方案交给 hatch-pet，生成 Codex 能使用的宠物文件。
```

## Detailed Customer Explanation

```text
这个工具适合想做“自己的 Codex 桌面宠物”的人。

它会帮你完成三件事：
1. 先确认你的 Codex 是否能装宠物。
2. 帮你把一个模糊想法变成清楚的角色设定。
3. 把确认好的角色交给官方宠物生成流程，做成可以安装的 pet.json 和 spritesheet.webp。

整个过程不用你理解技术细节。你只需要回答像这样的问题：
- 它像什么？
- 它是什么性格？
- 它开心、等待、失败时会怎么动？
- 你喜欢哪张确认图？
- 有哪些东西一定要保留，哪些一定不要？

如果你有参考图，可以发给我。如果没有，我也可以先生成几种方向让你选。
```

## What The User Gets

Explain the final output like this:

```text
最后你会得到一个 Codex 官方格式的桌面宠物包。
它通常包含：
- pet.json：告诉 Codex 这个宠物叫什么、图片在哪里、怎么显示。
- spritesheet.webp：一张包含 9 个动作的动画图。
- 预览图或动作预览：用来确认效果。

这个宠物会放到 Codex 的 pets 目录里，之后 Codex 就可以识别它。
```

## What This Does Not Do

Use plain wording:

```text
它不是一个新的桌宠软件。
它不会修改 Codex 本体。
它也不会给 Codex 增加新的动作槽。
它是在 Codex 已经支持的官方宠物格式里，把角色、风格和动作做到尽量高定制。
```

## Language Switch Introduction

Say this early when useful:

```text
你可以选择语言：中文 / English / 日本語 / 한국어 / Español / Français / Deutsch。
如果中途想换语言，直接说“切换到英文”或“Switch to English”就可以。
```

## Beginner Promise

Keep this promise in the conversation:

```text
我会一次只问一个板块，不会一次丢给你一大堆表格。
每轮我会先总结你的选择，再进入下一步。
关键视觉阶段会给你看 2-4 个方向，你可以直接选 A/B/C，也可以说“我要 A 的脸 + B 的颜色”。
```
