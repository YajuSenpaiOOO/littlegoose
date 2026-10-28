# 游园手绘木材97

2026-10-20，内置image_gen生成，未使用CLI。源图保留于生成目录，项目使用painted_timber_atlas97.png。四象限依次为树皮、裸木纹、端面年轮、灰褐树皮。运行时按等分象限生成独立ImageTexture并生成mipmap，材质分别使用树皮/裸木与端面年轮。实际倒木、踏桩、栏杆、秋千与木座均为3D几何，沿用场景光照与阴影。

## 完整提示词

```text
Use case: stylized-concept. Production game material atlas, FOUR equal SQUARE seamless texture tiles in an exact 2 by 2 grid, no gutters, every quadrant fills its entire square. Entire image opaque. Top-left: chunky aged chestnut-brown tree bark, rugged vertical flowing fissures, uneven flaky ridges, hand-painted moss tiny subdued creases, soft warm grey-brown ochre palette, natural wood not straight boards. Top-right: weathered golden tan bare wood plank grain, organic elongated wood fibres and subtle knots, NO plank separation lines, grain runs vertically. Bottom-left: a flat sawn tree trunk cross-section viewed perfectly straight on, concentric irregular growth rings with few radial fine splits and heartwood eccentric centre at exact quadrant centre; fill whole square with end grain, NO circular border, no bark rim, no round disk silhouette. Bottom-right: lighter grey-brown deeply furrowed bark variant, natural organic branching vertical fissures. Style: hand-painted pixel-textured fairytale 2.5D RPG environment, broad painterly shapes, small pixel clusters, moderate contrast, tactile matte surfaces, no photorealistic fine noise, no plastic highlights. Even neutral diffuse lighting, no cast shadows, no perspective, no objects, text, labels, frame, gradients, background, or transparency. Atlas is used on actual 3D fallen logs, stepping stumps and a wooden swing; keep consistent natural wood palette.
```

