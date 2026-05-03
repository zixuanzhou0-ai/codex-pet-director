# 黑瞳裁决者

`黑瞳裁决者` is a real Codex desktop pet package loaded from the local Codex pets folder and copied into this repository as a finished example.

It contains the actual files a finished pet needs:

- `pet.json`
- `spritesheet.webp`

The sprite sheet follows the official Codex pet layout: 9 action rows x 8 frame columns.

## Preview

![Dark Judge preview](../../assets/examples/dark-judge/preview.png)

## Full Static Frames

The frame board below is generated from the real `spritesheet.webp` layout. It keeps the original 9 rows x 8 columns.

![Dark Judge full spritesheet frame board](../../assets/examples/dark-judge/all-frames.png)

## Row Animations

These GIFs are generated row by row from the same sprite sheet. They preserve the official row order.

<p>
  <img src="../../assets/examples/dark-judge/row-01.gif" width="120" alt="Dark Judge row 1">
  <img src="../../assets/examples/dark-judge/row-02.gif" width="120" alt="Dark Judge row 2">
  <img src="../../assets/examples/dark-judge/row-03.gif" width="120" alt="Dark Judge row 3">
  <img src="../../assets/examples/dark-judge/row-04.gif" width="120" alt="Dark Judge row 4">
  <img src="../../assets/examples/dark-judge/row-05.gif" width="120" alt="Dark Judge row 5">
  <img src="../../assets/examples/dark-judge/row-06.gif" width="120" alt="Dark Judge row 6">
  <img src="../../assets/examples/dark-judge/row-07.gif" width="120" alt="Dark Judge row 7">
  <img src="../../assets/examples/dark-judge/row-08.gif" width="120" alt="Dark Judge row 8">
  <img src="../../assets/examples/dark-judge/row-09.gif" width="120" alt="Dark Judge row 9">
</p>

## Animation Showcase

![Dark Judge full animation showcase](../../assets/examples/dark-judge/showcase.gif)

## Pet Metadata

```json
{
  "id": "dark-judge",
  "displayName": "黑瞳裁决者",
  "spritesheetPath": "spritesheet.webp"
}
```

## What This Example Shows

- Head-only pets can still use all 9 official action rows.
- The motion reads through tilt, expression, bounce, glow, and hair movement.
- The row GIFs make compact head-form pets easier to evaluate before release.
