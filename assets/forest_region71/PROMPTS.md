# 林地山麓71素材与生成提示词

使用内置 image_gen 工具生成，透明背景；参考图仅用于匹配画风，不编辑原素材。参考：assets/forest14/a_trees.png 与 assets/yard15/props.png。原始输出保留于 C:/Users/ASUS/.codex/generated_images/01a14e32-c53e-7ca3-a249-b34b85513675/。

项目素材：
- wooded_ridge.png：连续岩山远景，2172×724，保留alpha。
- mossy_escarpment.png：林地崖面，2172×724，保留alpha。

## wooded_ridge.png

Use case: stylized-concept. Generate a NEW production game background cutout, using attached images ONLY as style references (existing soft pixel painted trees and mossy stone props). A broad low rocky mountain ridge rising behind an enchanted deciduous forest, a continuous irregular silhouette with 3 unequal crags and terraced boulders, muted blue-grey stone, soft olive moss, a few small leafy bushes in cracks. Style MUST match the references: cozy storybook RPG sprite painting with gentle visible pixel clusters, broad simplified shapes, moderate detail, no photorealistic noise, no dense tiny holes. Wide landscape aspect 3:1. Front view, slightly looking down 25 degrees, ridge fits inside image with transparent margins, base flat along bottom and opaque rocky all the way to base, roughly widest base 95% image width and highest point 85% height. One continuous mountain formation, not a sheet of separated objects. Neutral soft daylight, no baked hard cast shadow. Transparent background, no sky, no ground plane, no frame, no text. This is a distant layer placed behind existing trees, not a whole finished scene.

## mossy_escarpment.png

Use case: stylized-concept. Generate a NEW production game terrain facing asset, using attached images ONLY as style references. One continuous broad moss-topped forest escarpment face, wide landscape 3:1 aspect. The silhouette is a low uneven rocky bank, flat consistent base, top edge mildly stepped 65%-85% image height, filled opaque grey slate rocks from top to bottom. Broad irregular interlocking slab strata with occasional old squared stones embedded in the natural rock, olive moss along the top and sparse trailing ivy. It must look like the exposed side of a large wooded hillside, NOT a detached island, NOT cylindrical columns, not an arena wall, no balustrade. Match reference mossy wall painting and trees: warm whimsical storybook RPG sprite art with light visible pixel clusters and broad readable painted facets, low-medium detail; no photorealism, no granular noise, no repeated holes. Front facing, very little visible top plane, neutral daylight. Transparent background with narrow transparent margin. No sky, no grass field, no trees, no scene, no text. Suitable to map onto short 3D retaining faces; broad shapes rather than a photograph of stone.

## 接入

崖面纹理通过 painted_escarpment71.gdshader 取中下部连续岩层，映射到有起伏轮廓的真实网格侧面，顶面另有与地面衔接的草唇。保留原PNG，无抠图或重绘像素操作。远景使用完整透明岩山图，位于真实升高的后方树带之后，不接近战斗区域外围，不添加岩山整圈碰撞。
