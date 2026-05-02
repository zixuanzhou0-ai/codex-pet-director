# Wukong Spark V3

`Wukong Spark V3` is a real Codex desktop pet package generated for this project and loaded by Codex Desktop.

It is useful as a GitHub showcase because it contains the actual files a finished pet needs:

- `pet.json`
- `spritesheet.webp`

The sprite sheet follows the official Codex pet layout: 9 rows x 8 frame slots. V3 keeps the ordinary state cute and round-eyed, while the golden power-up frames use sharper slanted eyes and teal highlights.

## Preview

![Wukong Spark V3 preview](../../assets/examples/wukong-spark/preview.png)

## Full Static Frames

The frame board below is copied from the real `spritesheet.webp` layout. It keeps the original 9 rows x 8 columns and does not rename the action rows.

![Wukong Spark V3 full spritesheet frame board](../../assets/examples/wukong-spark/all-frames.png)

## Row Animations

These GIFs are generated row by row from the same sprite sheet. They preserve the original row order.

<p>
  <img src="../../assets/examples/wukong-spark/row-01.gif" width="120" alt="Wukong Spark V3 row 1">
  <img src="../../assets/examples/wukong-spark/row-02.gif" width="120" alt="Wukong Spark V3 row 2">
  <img src="../../assets/examples/wukong-spark/row-03.gif" width="120" alt="Wukong Spark V3 row 3">
  <img src="../../assets/examples/wukong-spark/row-04.gif" width="120" alt="Wukong Spark V3 row 4">
  <img src="../../assets/examples/wukong-spark/row-05.gif" width="120" alt="Wukong Spark V3 row 5">
  <img src="../../assets/examples/wukong-spark/row-06.gif" width="120" alt="Wukong Spark V3 row 6">
  <img src="../../assets/examples/wukong-spark/row-07.gif" width="120" alt="Wukong Spark V3 row 7">
  <img src="../../assets/examples/wukong-spark/row-08.gif" width="120" alt="Wukong Spark V3 row 8">
  <img src="../../assets/examples/wukong-spark/row-09.gif" width="120" alt="Wukong Spark V3 row 9">
</p>

## Animation Showcase

![Wukong Spark V3 full animation showcase](../../assets/examples/wukong-spark/showcase.gif)

## Golden Power-Up

The sprite sheet also includes a temporary golden-hair power-up state with a different eye shape from the ordinary form.

![Wukong Spark V3 golden power-up](../../assets/examples/wukong-spark/golden-power-up.png)

![Wukong Spark V3 golden power-up animation](../../assets/examples/wukong-spark/golden-power-up.gif)

## Pet Metadata

```json
{
  "id": "wukong-spark-v3",
  "displayName": "Wukong Spark V3",
  "description": "A sharper Wukong Spark example with stronger motion accents and transformed Super Saiyan-style eyes in the golden power-up frames.",
  "spritesheetPath": "spritesheet.webp"
}
```

## What This Example Shows

- A finished pet is small and portable.
- Codex reads `pet.json` and `spritesheet.webp`.
- The director workflow should help users lock the character first, then produce the 9 official action rows and any special frames inside those rows.
- README screenshots should show frames from the real production sprite sheet instead of hand-labeled action guesses.
