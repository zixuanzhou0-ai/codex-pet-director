# Wukong Spark

`Wukong Spark` is a real Codex desktop pet package generated for this project and loaded by Codex Desktop.

It is useful as a GitHub showcase because it contains the actual files a finished pet needs:

- `pet.json`
- `spritesheet.webp`

The sprite sheet follows the official Codex pet layout: 9 actions x 8 frames.

## Preview

![Wukong Spark preview](../../assets/examples/wukong-spark/preview.png)

## Full Static Frames

The frame board below is copied from the real `spritesheet.webp` layout. It keeps the original 9 rows x 8 columns and does not rename the action rows.

![Wukong Spark full spritesheet frame board](../../assets/examples/wukong-spark/all-frames.png)

## Row Animations

These GIFs are generated row by row from the same sprite sheet. They preserve the original row order.

<p>
  <img src="../../assets/examples/wukong-spark/row-01.gif" width="120" alt="Wukong Spark row 1">
  <img src="../../assets/examples/wukong-spark/row-02.gif" width="120" alt="Wukong Spark row 2">
  <img src="../../assets/examples/wukong-spark/row-03.gif" width="120" alt="Wukong Spark row 3">
  <img src="../../assets/examples/wukong-spark/row-04.gif" width="120" alt="Wukong Spark row 4">
  <img src="../../assets/examples/wukong-spark/row-05.gif" width="120" alt="Wukong Spark row 5">
  <img src="../../assets/examples/wukong-spark/row-06.gif" width="120" alt="Wukong Spark row 6">
  <img src="../../assets/examples/wukong-spark/row-07.gif" width="120" alt="Wukong Spark row 7">
  <img src="../../assets/examples/wukong-spark/row-08.gif" width="120" alt="Wukong Spark row 8">
  <img src="../../assets/examples/wukong-spark/row-09.gif" width="120" alt="Wukong Spark row 9">
</p>

## Animation Showcase

![Wukong Spark full animation showcase](../../assets/examples/wukong-spark/showcase.gif)

## Golden Power-Up

The sprite sheet also includes a temporary golden-hair power-up state.

![Wukong Spark golden power-up](../../assets/examples/wukong-spark/golden-power-up.png)

![Wukong Spark golden power-up animation](../../assets/examples/wukong-spark/golden-power-up.gif)

## Pet Metadata

```json
{
  "id": "wukong-spark",
  "displayName": "Wukong Spark",
  "description": "A tiny original chibi martial-arts desktop pet with spiky black hair, orange training outfit, monkey tail, bouncing waves, and a temporary golden power-up animation.",
  "spritesheetPath": "spritesheet.webp"
}
```

## What This Example Shows

- A finished pet is small and portable.
- Codex reads `pet.json` and `spritesheet.webp`.
- The director workflow should help users lock the character first, then produce the 9 official action rows and any special frames inside those rows.
- README screenshots should show frames from the real production sprite sheet instead of hand-labeled action guesses.
