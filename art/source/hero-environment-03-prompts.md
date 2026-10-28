# 主角环境样板 03：完整生成提示

2026-10-16。使用内置 imagegen，未使用 CLI/API。输出原样复制入 assets/hero_environment_v1/，未以图像脚本重绘、裁切或修改 alpha。调色、缩放与 alpha 排除由游戏材质完成；原输出保留。

## oak.png

保存路径：`assets/hero_environment_v1/oak.png`。

主角 walk_source.png 仅作为画风参考；透明背景。

```text
Use case: stylized-concept. Asset: ONE standalone transparent game tree sprite for a cozy 2D top-down RPG. Input image is ONLY the visual rendering/style reference, a white-haired chibi heroine sprite sheet; DO NOT draw any character. Match her fine pixel-cluster illustration, confident clean contours and soft layered cel-like shading. Subject: one mature friendly oak-like deciduous tree with a substantial warm chestnut/umber trunk, gentle exposed root flare, a rounded asymmetrical crown made of 5-7 broad readable foliage masses. Leaves in fresh sage, mellow spring green and warm yellow-green highlights, deep muted teal shaded undersides. Warm and welcoming with real weight and age, not saccharine, not neon. Three-quarter overhead RPG view compatible with a front-facing standing sprite, show the entire crown and a short clear trunk below it. Trunk visible for bottom 22 percent of tree. Clear unambiguous foot point at ground-contact center of the trunk, no ground plane. Transparent canvas, full silhouette with margin on all sides, one tree only. Fine pixel illustration around logical 180x220 resolution enlarged cleanly; soft block-group shading, few fine leaf accents, no stippling, no photoreal bark or grain, no coarse 16x16 retro pixels. Neutral diffuse daylight albedo; avoid strong directional lighting and cast shadows. No flowers, fruits, pots, stones, grass carpet, ground shadow, labels, guides, character or reference sheet.
```

## grass.png

保存路径：`assets/hero_environment_v1/grass.png`。

主角 walk_source.png 仅作为画风参考；不透明，运行时镜像重复。

```text
Use case: stylized-concept. Asset: ONE seamless square grass-ground albedo tile for a cozy 2D RPG. Reference is a chibi heroine sprite sheet, use ONLY its clean fine pixel-cluster illustration and soft shading technique. Do not include any character. Straight orthographic top-down flat ground. Fresh soft meadow green, sage and muted warm yellow-green sunlit masses, sparse restrained cooler green mottling for depth. Overall bright middle value, warm welcoming tranquil countryside, substantial natural softness, not fluorescent, not mint pastel candy. Broad calm irregular color masses, very low contrast texture; ONLY a few tiny grass blade clusters, no individual blades covering every pixel. Very little granular noise. Roughly 128x128 logical art pixels cleanly enlarged, grouped deliberate pixel marks with soft 3-tone color transitions. No outlines on the grass. Seamless tiling on all four edges. Entire canvas is grass, no border, no vignette, no barren dirt blobs, no flowers, stones, trees, shrubs, path, water, shadows or text. Neutral diffuse daylight ALBEDO only, no lighting gradient. Leave quiet visual breathing room for the character. This replaces a muddy gray-green noisy texture: make this distinctly clearer, fresher and quieter.
```

## earth.png

保存路径：`assets/hero_environment_v1/earth.png`。

无输入图片；不透明，运行时镜像重复。

```text
Use case: stylized-concept. Asset: ONE seamless square warm earthen footpath material, 2D cozy RPG game ground albedo. Companion to fresh sage meadow grass. Straight top-down orthographic, entirely flat material, no perspective, not a scene. Warm light oatmeal/ochre sandy earth with softly compacted clay areas, broad quiet beige variation and only occasional small subdued mineral flecks. Clean fine pixel-cluster illustration, soft broad 3-4 tone patches, logical 128x128 art pixels cleanly enlarged. Bright middle value, inviting and sunny but neutral daylight albedo, not yellow-orange saturated. No continuous pebble carpet, not sandpaper, no tiny grain everywhere. The floor should let a detailed chibi character stand out clearly. Seamless tiling on every edge, no vignette, no gradients from light, no shadows. Fill all canvas with earth only. No grass borders, road shape, stones, paving slabs, footprints, trees, vegetation, characters, labels or text. Natural worn path with weight and calm simplicity.
```

