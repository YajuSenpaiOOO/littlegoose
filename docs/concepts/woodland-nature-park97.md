# 林间自然游园构图草案（97施工参考）

2026-10-20。基于world96实际截图，以内置image_gen制作的构图讨论图。**这是概念图，不是游戏运行效果。用户确认后已据此实施world97；运行效果及验证见[97记录](../nature-park97.md)。**

![构图草案](woodland_nature_park97.png)

用户提出左侧用高石山/峭壁与有树的山顶遮挡虚空，并考虑将场地改成自然公园或孩子玩的地方。

建议采用林间自然游园：高崖与山顶树带形成西侧实体边界，后方接原林台。崖脚设小观景台与短石阶；树下挂木板秋千；一侧用倒木与少量踏桩形成平衡游玩区；弯曲环路连接各处与入口。中央草坪供奔跑和战斗，低花沿路径/石脚集中生长，保留绿地缺口与花草独立组件。

草案只用于讨论空间关系。落地时中央活动面宜先按约18×14m核验移动、闪避及三波敌人完整寻路，再调整环路和物件，不能直接按图中人物比例缩成小院。秋千、踏桩首先可作为场景物件，可坐/摆荡/踏跳交互需另外设计。需要匹配画风的独立素材、真实碰撞与投影，不能把整张概念图贴成游戏地面。

建议先做左侧高崖/山顶树林遮空和地形围合，再重排路径与中央留白，之后分别制作秋千、倒木踏桩和座位，最后调整花草密度。沿用现有相机、昼夜、战斗和周边更新系统。

## 完整生成提示词

内置image_gen；输入为docs/captures/world_restart/woodland96_rest_day.png；输出为本目录woodland_nature_park97.png，非透明图。

```text
Use case: stylized-concept. Asset type: game level art-direction paint-over, a DISCUSSION CONCEPT, not an actual game screenshot.
Input image 1 is the edit target: an actual scene from our woodland game. Keep its 25-degree elevated gameplay camera, its landscape framing, its hand-painted pixel-textured 2.5D game aesthetic, the single little pale-haired character near the foreground centre, and the recognizable mature trees and moss rocks. Recompose the empty clearing into a coherent small forest nature park with traces of children's play. Warm, quiet fairy-tale atmosphere, grounded in the supplied game's visual language; practical objects, not elaborate architecture.
Primary structural change: replace the left boundary and empty background beyond it with a substantial irregular stone escarpment rising approximately one-and-a-half to two tree-trunk heights, connected naturally to the rear rock ridge. Give the LEFT CLIFF a broad grassy top planted with dense mature trees, rooted shrubs, a few smaller overlapping rock shoulders, and an irregular silhouette. The cliff and wooded crest must completely block the leftward view to the void. Do not make a circular enclosing wall, a fortress, or a long perfectly straight stone strip.
Layout: a gently winding narrow pale earth-and-grass footpath enters from the existing right-hand approach, forms an irregular walking loop with a fork, and links three recognizable places. At left-middle near the cliff foot and existing moss stones, a modest overlook/rest nook reached by a few integrated stone steps; just a low log rail on its edge. On the right-middle, one simple wooden plank swing hangs on two ropes from a sturdy living-tree branch, over a little worn patch. On the left-middle to foreground, a low fallen log and four or five uneven tree-stump stepping posts make a small natural balance-play trail. A simple timber seat by the footpath can face the central lawn. These are the ONLY play/park objects. They must feel handmade and belong to the woodland; no plastic playground equipment, slides, metal frames, fenced rectangular playground, vendors, modern signs, crowds or additional people.
Leave a modest readable central greensward around the character for running and combat, approximately 8 by 10 metres at this scale, with a clearly shaped edge. The walking loop, tree masses, play nook, slope and overlook must give the open ground a PURPOSE and a readable front/middle/back hierarchy. Low ankle-height white wildflowers with occasional blue dots grow in connected irregular drifts at sunny path edges and stone feet, with green gaps, separately from grass. No dense high flowerbed or obvious oval disk. Keep material transitions soft and tree shadows coherent on grass, flowers, rocks and timber. Soft clear afternoon daylight, warm sun and cool green shade; not oversaturated neon grass, not photorealistic, not golden fog. Avoid filling the whole ground with scattered props. No text, labels, watermark, UI or debug aiming lines.
```

