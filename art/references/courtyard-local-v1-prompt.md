# 院子局部参考图生成记录

工具：内置 imagegen；2026-10-15 两次请求均连接失败，未生成图片，没有替代调用 API。

2026-10-16 重试：首次连接失败，第二次成功。沿用下方完整提示词与两张参考，产出 `courtyard-local-v1.png`，已复制到项目参考目录；没有替换实机地图或导入为整张地面。

参考 1：../../docs/captures/home_ground_join_sunset.png，当前实机画风与尺度。
参考 2：layout-A.png，区域关系。

正式搭建以 ../../docs/courtyard-route-reservations.json 的道路预留和 ../../docs/courtyard-local-plan.md 为准。

## 完整提示词

Use case: stylized-concept. Asset type: playable 2D pixel RPG cottage courtyard LOCAL environment reference, not a whole world image.
Input images: Image1 is the exact current in-game art, camera, red-roof cottage and sprite scale reference. Image2 is A's large-world layout reference ONLY, not a demand to copy its extremely dense high-resolution artwork.
Generate one beautiful detailed LOCAL courtyard reference filling a landscape canvas. Maintain Image1's honest pixel-art sprites, top-down RPG orthographic ground and upright objects, green chunky tree canopies and red roof stone cottage, consistent pixel size, readable walkable space. Enrich courtyard as a lived-in girl's village home instead of a huge empty symmetric stone plaza. Cottage in upper central portion with front door on its right facade. Reduce plain stone paving into irregular worn threshold and main approach, softly meeting grass and a few step stones. Left side: intimate bench resting nook under a tree, a few potted flowers, small stacked firewood by cottage side. Right: modest vegetable and herb garden, short broken runs of low fence/stone edging, watering can, little work table. Layered shrubs, roots, grass and small flowers in connected uneven groups. Few warm lamps, overcast late afternoon with restrained soft shadows; preserve gameplay readability. One tiny pale-haired chibi protagonist for scale, no enemies. No colossal new monuments, ponds, cliffs or extra buildings.
CRITICAL GEOGRAPHY: This courtyard is SOUTH of A's central junction, not itself the junction. Main exit at bottom-center runs south visibly beyond frame, then curves around the EAST exterior of garden to a visible northeast exit at top-right; this returning outside lane leads north to the central junction and station. Keep lane wide and completely unobstructed. Cottage and courtyard are inside this curved route. West edge trees are visual forest boundary, not a fake path blocked by trees. Optional east small garden walking opening joins same outside lane for eventual lake return. No railways or full combat arenas inside this closeup. Clearly show continuous route from door to south gate and around east outside to north; no fences across paths. Keep paths at least 2-3 character widths. Do not let decorative plants cover crossing nodes. No labels, UI, text, watermarks or multiple panels. This is a buildable coherent single reference at current camera, not cinematic 3D or watercolor.

