# 432 记忆材料推进顺序

安全探索时按 Tab 查看获得过的材料和来源，工坊日记展示配方用量。拾取和制作会更新手头材料，回屋到书桌按 E「记下今天」后一起写入 432 存档。

## 随身材料清单

使用内置 ImageGen 按选定 B 稿 `exec-7a2cd7e1-8189-4aa3-88a4-3893d1a83625.png` 拆出两个透明层。左手连空白页 `assets/workshop432/material-list-paper.png` 来自 `exec-8b0b9110-c1e3-498e-a07d-47b2046b4ba8.png`，右手连木笔的初稿 `assets/workshop432/material-list-pen.png` 来自 `exec-4d4e7f83-de32-4c0e-ba52-8458ece4f371.png`。两层都是 1585×992，alpha ≥128 的范围分别为 (0, 34)–(1271, 992)、(1098, 245)–(1585, 992)。左手拇指和纸面遮挡保留在画片里，材料图标和字是实时纸面 UI。

当前右手使用补长袖子后的 `assets/workshop432/material-list-pen-long.png`，来源 `exec-5db97532-70f7-4eb7-89d7-8e7b18b6aaa9.png`，1024×1536，alpha ≥128 的范围为 (128, 45)–(1024, 1536)。笔、手、袖子保持同一缩放比例，整体平移，袖尾自然延伸到画框外。补画提示词如下。

> Outpaint the attached TRANSPARENT game sprite to complete a longer lower forearm and sleeve. This is a first-person adult female right hand holding one straight horizontal golden-brown wooden pencil whose tip points left. Preserve the attached artwork exactly where present: same anatomy, gesture, stocky softly painted fingers and small creases, same pink sleeve and its folds, same warm shadows. Add a natural continuation of its rose-and-cream frilly fabric down and to the right, roughly as much new sleeve as one extra cuff length. The arm descends diagonally toward lower right, a single continuous curved cloth silhouette. The art must include enough drawn area to remain continuous when translated by about 55 pixels up or down and 30 pixels horizontally inside a game crop. Use a vertically oriented transparent sprite canvas, keep the whole pencil on top and the extra sleeve below. Hand and pencil about the top third; foreground art fills frame. Keep the exact direction and in-plane angle of the original pencil. No other objects, no left hand, no pink behind pencil, no white backdrop, no shadows outside the sleeve or floating sleeve fragment. Clean authentic transparency around the one continuous silhouette.

> Game composition-layer extraction, faithful edit of supplied approved first-person scene. Keep EXACTLY the complete cream paper and its left hand and associated pink left sleeve overlapping the left edge. Preserve their pixel positioning, painterly finish, original size, angle, silhouette, fingers and contact shadow. The image is still the original wide 16:10 framing, keep original canvas registration including large empty right area. Remove the forest entirety, REMOVE the right sleeve, right hand, pencil and their shadow, reconstruct the tiny covered paper area at right edge. Make all removed area genuinely transparent with clean alpha, including between hand and paper silhouette if applicable. Erase the three illustrated material icons and ALL internal row lines, including vertical divider, filling with clean continuous cream paper texture. Keep decorative leaf and feather border as existing. Leave whole usable paper area BLANK for game text. Do not alter the left hand, do not add objects or crop the layer into a tight rectangle. Only one left hand attached to paper and sleeve on transparent full original canvas.

> Game composition-layer extraction, faithful edit of supplied approved first-person scene. Keep EXACTLY the complete right hand gripping the existing wooden pencil and its attached pink forearm and sleeve at bottom-right. Preserve skin paint rendering, original size, natural grip, proportions, sleeve folds, angle and ORIGINAL CANVAS PLACEMENT. Remove everything else including paper, left hand, left sleeve and whole forest. The pencil tip and pencil end are fully visible in the cutout. Preserve wide 16:10 original framing with broad empty transparent left field, do not center or recrop the hand. Genuine transparent alpha, no white/studio background or cast shadows. Do not reimagine any details; keep exactly the right hand and pencil from the supplied reference in their original frame position. No extra hands.

## 现有战斗入口

- 在 432 林间空地靠近小团团按 E，即可开始从 291 继承的完整团团战。普通战为六批共 24 只，包含蓝花团团预判和玫瑰团团滚撞。通关后去断层前找大团团，靠近按 E 再确认挑战。挑战资格和首胜弹力球存进 432 的记忆存档，首胜弹力球直接进曲奇铁盒。独立对照仍用入口 71 / 291，272 保留六批试演，273 保留首胜奖励试演。
- 蜘蛛姐姐林间普通战保留在 97 / 354，432 的 Ctrl+F7 已有独立林地试演入口。纸剧场 Boss 保留在 89，场景文件是 world314.tscn，启动表标记为 346。先核对这些历史场景的流程，再选对应入口逐个迁入大地图。
- 从林间空地沿西北山路走上望海纸坪，在入口靠近作业本按 E。沿用 347 的五段入场安排，共 15 只普通纸怪、2 只恐龙、2 只骑士和 1 只怪兽。首波四只小纸怪从书页飞出，之后从台地周边进场。怪兽阶段沿用原落石事件。每只退场掉一张「扯下的作业纸」，落地后走到约 0.86 米内自动吸附，散场时未捡的纸合成一叠放回入口附近。用一张纸在工坊日记的纸飞机页点击照片合成，成品进铁盒底层。既有 432 存档保留原本的纸飞机，新档从零份开始。

## 材料与生活顺序

1. 弹弓。林边捡小树枝，在林中空地和小团团主动约玩，捡它们退场掉下的液滴，回日记制作。
2. 纸飞机。纸怪掉作业纸，沿用同一套材料存档和日记配方，以单材料配方验证流程。
3. 水宝宝。小团团有 10% 概率掉小水宝宝。靠近自动收起，回到小屋右下方的澡棚，靠红澡盆按 E 泡一颗。下一次 07:00 成熟，可随时回来取。书桌会同时保存泡澡状态、材料和游戏时间。养大的水宝宝收进材料清单。工坊日记对应跨页点击照片，消耗一颗养大的水宝宝，封进玫瑰色玻璃珠，成品放进铁盒底层。
4. 洗澡和吃饭。先让玩家在家实际操作一次，再考虑接上手电筒的生活记录。菜地的双人、三人事件随后单独推进。

弹弓首轮暂用一根树枝和三滴液滴，数量以后按试玩节奏决定。树枝在林边几棵树的根边分散放置，按 E 拾取，走远后补充。脚尖经过会把树枝轻轻拨动，不挡路。战斗中液滴随退场掉出，弹两下后停在草地上。散场时若有多颗尚未吸附，液滴原地缩去，数量合成一颗较大的液滴放在林间空地入口侧。主角进入约 0.86 米的范围后一次收取整份。拾取后播放短音和局部碎光。团团靠近按 E 约玩，经过时可以继续走。其它大地图遭遇各自决定是主动约玩还是敌对警戒，沿用各自的试演入口。

## 小水宝宝掉落图

内置 ImageGen 输出 `exec-c3e1d4f1-3d40-4c9a-9529-b74d76b07769.png`，保留透明源图为 `assets/workshop432/water-baby-drop.png`。尺寸 1262×1246，alpha ≥128 的有效范围为 (218, 249)–(1014, 1000)。清单和场景共用 `water-baby-drop.tres` 的透明裁切。场景画片沿固定 Y 轴面向镜头，有效高度约 0.22 米，脚点在圆珠底部，沿用液滴的接地软影、弹跳和近身吸附，无阻挡，受林地材质调色。

> Create a single standalone transparent PNG game sprite of a small unsoaked water bead toy (水宝宝) dropped by a cute woodland blob in a hand-painted fairy-tale 2.5D game. ONE isolated spherical little translucent rosy coral-pink hydrogel seed, subtly irregular organic round sphere with just a hint of a flattened underside, a tiny clean ivory reflected highlight at upper left, delicate translucent apricot rim, warmer raspberry-pink lower core. Camera looks down from about 25 degrees. Soft painted brush detail, clear silhouette at icon scale, restrained highlights, delicate gouache-like rendering in the style of illustrated cottagecore objects. Design as a small less developed form of a pink grown bouncy water pearl. No other bubbles, no labels, no bubble container, no loose dots, no sparkles outside, no ground, no halo, no external cast shadow. Pure true transparent background. Center it to occupy about 80 percent of the format.

## 树枝资源

当前三款落枝用 `scripts/art/fallen_twig432.gd` 的收尖、弯曲管状网格，最大直径约 0.24 米，沿用林地倒木的 `assets/woodland108/painted_log108.png` 和受光材质。落地中心跟随地形坡面，独立软影随脚点移动。脚尖沿枝身判定拨开，不设实体阻挡或额外投射阴影。

### 林地树皮画片对照

上一版使用 `assets/workshop432/forest-bark-straight.png`（`exec-c7ffae0d-97c6-4d0f-9afb-66237d386664.png`）、`forest-bark-crooked.png`（`exec-c840c0dd-fb62-4127-a8a9-a560898eeb20.png`）和 `forest-bark-forked.png`（`exec-0489edf2-6b04-4d08-a605-a107da46731b.png`）。内置 ImageGen 以游戏树木图集 `assets/forest14/a_trees.png` 作画风参考。前两张为 2172×724，叉枝为 2149×732。以 alpha ≥96 计算，三张可见边界分别为 (54, 80)–(2130, 676)、(25, 20)–(2147, 709)、(28, 22)–(2121, 713)。贴地卡片宽度分别为 1.52、1.63、1.70 米。

> Create ONE isolated fallen branch game sprite on true transparent background. Use the supplied in-game trees specifically as the visual reference for the BARK: same honey ochre brown broad softly blended painterly highlights, darker mossy olive-brown in creases and one sparse soft moss patch, slightly pixel-painted simplification and soft textured strokes, NO black outlines, no photoreal wood fibers, no gray brown deadwood, no white broken ends. Make it a chunky and unmistakable little fallen tree limb for a hand-painted fairy tale woodland, about 5–7x longer than its average thickness, viewed mostly from above for a horizontal ground decal, laid nearly horizontally with a gentle diagonal from lower left to upper right. Fill canvas closely, extractable silhouette. No soil, ground, leaves around it, cast shadow or backdrop.

三款提示分别补充 “A nearly straight limb with just one tiny snapped nub.”、“A gently curved crooked limb with no prominent fork.” 和 “A forked Y limb with one short unequal prong.”。

### 旧稿记录

`assets/workshop432/forest-forked-twig.png` 由内置 ImageGen 生成，原图 `exec-fb8a0adc-e1d5-47c0-a1d5-4856fa6c0890.png`，1536×1024。补充的 `forest-straight-twig.png` 和 `forest-crooked-twig.png` 分别来自 `exec-db0c8029-0b18-486d-b03e-345e2e6e31b2.png` 和 `exec-f7a23d18-dd86-4cdb-8cbd-110dc2c8f770.png`，均为 1774×887 透明画片。补充两稿延续同一绘本枯木质感，分别画成细直落枝和没有叉的弯曲落枝。三种卡片整图宽约 0.81–1 米，随地面坡度和场景受光，独立软接触影贴地，拾取按角色与真实地面锚点的距离计算。液滴沿用 120 的蓝滴画片，432 单独处理落地和吸附。

> Tiny collectible game asset for a cozy hand-painted fairytale 2.5D woodland. One small fallen Y-shaped dry twig with a clearly readable split suitable for a homemade slingshot. Lay it on the ground diagonally, fork at upper right and its short handle at lower left. View from the game's 25 degree downward woodland camera, inclined rather than completely overhead, convincing dry warm cocoa brown bark, fresh broken cream tips and one tiny suggestion of lichen. Broad gentle hand-painted color patches, clean readable outline, avoid noisy fine detail, looks like it belongs on worn grass by an old footpath. One branch only, no leaves surrounding, no stones or other objects, no text, no painted ground, no cast shadow (added in game), isolated genuine transparent background, keep margins very small around the object. Soft warm neutral light from above-left, pastel storybook painting.

## 作业纸资源

内置 ImageGen 参考 432 望海纸坪截图与现有 `assets/workshop432/fragments/homework.png` 绘制两件道具。作业本 `assets/workshop432/summit-exercise-book.png` 来自 `exec-6da1d08b-e710-47f0-981b-e12cc03ac960.png`，1586×992，alpha 大于 127 的边界为 (126, 88)–(1439, 898)。撕页 `assets/workshop432/torn-homework-drop.png` 来自 `exec-e966654b-a4a6-4e6d-bbb3-6ebd9bd5a9c2.png`，1448×1086，可见边界为 (81, 15)–(1363, 1017)。

作业本图宽 1.19 米，画片向地面倾斜 55 度，透明边缘参与真实日光投影，前缘贴近地面。纸怪从书页抬起。撕页为微翘的画片，单份图宽 0.64 米，叠放 0.82 米，保留轻接触影。两者受场景光，无阻挡体。撕页靠近后以地面锚点开始吸附，入账时在原处发出淡金碎光。

撕页提示词

> Single game collectible sprite, an isolated torn page from a child's school exercise notebook. Transparent background, no cast shadow. Painterly cozy hand-painted 2.5D fairytale game matching references: woodland screenshot is actual lighting and camera target, illustrated blue-green exercise book is paper tone reference. One bent warm cream sheet, torn toothy edge where it ripped from binding, a few faded blue-gray ruled lines and faint pencil scribbles (unreadable), one softly curled edge with underside and dark edge separation. A bold silhouette, light but not white, designed to be recognizable at very small size. Camera 25 degrees down from horizontal, show oblique top and folded lip. No book, no loose pieces, no background, no outlines, no realistic noise. Fill canvas.

作业本提示词

> Single isolated game prop on genuine transparent background: an OPEN child's school exercise notebook, a muted teal cloth cover, thick small uneven warm ivory pages, ink-blue thin ruled lines, a hint of penciled marks, gently upturned right-hand page and visible middle crease. The book lies flat on the ground with no stand, with both open facing pages clearly visible. Match the supplied painted teal notebook, and render camera 25 degrees down from horizontal, same angle and fairy-tale painted softness as in the supplied actual forest screenshot. Slightly off-center rotation, front lower edges and binding visible, airy proportions, readily reads as a notebook from small fixed gameplay view, saturated enough to read in grass. No characters, no pencil, no loose pages floating, no background or baked ground shadow. One asset fills canvas.
