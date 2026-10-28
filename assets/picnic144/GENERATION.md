# 山顶野餐摆件资源 / 144

2026-10-24，使用内置 image_gen.imagegen（非 CLI）生成。两份源图均保留真实透明通道，未覆盖旧资产。

- `picnic.png`：半开藤编盒、露出的折叠布与两只搪瓷杯，组合为一个游戏摆件。源图1402×1122，运行时按regions.json提取透明留白内的主体。
- `lantern.png`：带提手和平底的小铜制地面灯。源图1312×1199，同上运行时提取主体。
- `regions.json`：只记录透明图中主体边界；生成源图保持不变。

野餐布为贴合地形的网格与程序格纹，挂灯复用woodland107/branch_lantern107.png，坐石和压布石复用forest87/moss_boulders87.png。

## Final prompt — picnic.png

Create a production-ready isolated environment sprite for a cozy storybook pixel RPG, transparent background. Subject: ONE compact still-life picnic arrangement: a low honey-brown woven wicker picnic hamper, lid half open leaning backward, a soft cream folded linen peeking out, and TWO small enamel mugs at its front, one faded teal and one ivory. Nothing else. No picnic blanket (will be separate ground geometry), no grass, no rock, no scenery, no lettering. View: low 3/4 front view from slightly above, camera elevation 25 degrees, almost orthographic, front faces visible, consistent with an HD-2D woodland game. Hand-painted pixel art with visible deliberate pixel clusters and gentle painterly highlights, muted warm colors, soft dark olive-brown edge contours rather than thick black cartoon outlines. Modest rounded forms, readable at 100 pixels wide. Basket takes 75 percent of composition; mugs beside its front right, all feet share a narrow ground baseline. Upper-left daylight, no bloom, no cast shadow plane, no opaque background. Keep generous transparent padding around the complete silhouette. This is one combined game prop, not an icon grid or an illustrated scene.

## Final prompt — lantern.png

One isolated small vintage ground lantern game prop on transparent background. Cozy hand-painted pixel-art environment sprite for a woodland HD-2D RPG. Weathered dark bronze metal, modest squat hexagonal lantern with flat sturdy foot, curved carrying handle above, warm amber glass panes and a tiny warm flame inside. No pole, no chain, no other objects, no text, no scenery, no shadow plane, no glow halo beyond silhouette. Orthographic low three-quarter front view, looking down only about 25 degrees. Muted olive patina and painterly chunky pixel clusters, warm cream highlights, clear readable at 40 pixels tall. Gentle storybook handmade feel, not realistic product photography or low poly 3D. Entire complete lantern centered, generous genuinely transparent margin. Upper-left daylight. Single sprite only.
