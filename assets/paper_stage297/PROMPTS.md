# 297 · 抛书与纸城堡开场试演

296比较图使用Godot原生Sprite2D绘制原纹理，294/主角正面idle/295按有效高度520px等比缩放、脚底同线。没有重新生成主角或单独拉伸新角色。结果docs/paper296-comparison.png和.json。目视295比294接近主角，头肩比例协调，眼线稍高/腿短可作为角色差异；这是agent判断，不冒充用户验收。

用户授权“如果差不多开始具体展开动画和城堡”，因此建立独立297试演。没有把现有团团战斗替换成纸怪Boss，291保留。

## 生成资源

- throw.png：内置image_gen，以295身份+主角gameplay比例为参考的空手抛出后关键帧；保持295头宽/脸宽/脚底，书由独立程序模型飞出。
- castle.png：内置image_gen，以295配色/像素色块为参考的单张薄卡纸城堡布景，中央透空拱门、折脚、拼纸/胶带与蓝黄旗。
- 原PNG未程序修绘/抠图/重采样。尺寸、alpha128边界、候选脚点/span/hash见layout.json。提示词附后。
- 来源：C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/exec-f476d5fa-252b-469f-b000-2ff412c2d58e.png、exec-b091a070-d747-483a-ba33-9f7b6dc5ab45.png。

## 演出与显示约定

297为grove草地里的独立可重播开场：发现纸怪被打趴（对白气泡）→.72秒切空手抛书→分离书本上升→1.15–1.9秒封面真实铰链翻开→卡纸条铺出/城堡平放下落→2.65–3.6秒城堡立起→女孩回城堡左后方纸台→4.65秒书回手中→5.1秒归还控制。独立书本是原生BoxMesh厚封面/纸页/彩色页签，两侧铰链旋转，不复制角色抱书贴图来假装独立飞行。书本形状/封面细节仍为简化程序原型，回手切帧的连贯性待实玩。

女孩沿用主角竖直展示平面、原生材质复制（独立纹理、清next_pass），有效高1.6m，原PNG每姿态独立脚点校准；游戏主角169/192完全不改。女孩/城堡均接原生轮廓地影，无新增光或自发光。城堡宽6.4m、有效高约2.86m，最终相机朝向X=-25度；从贴地X=-90度翻起。纸条/后方纸台为真实薄BoxMesh，不以插画冒充体积。城堡中间拱门保留通行间隙，两侧仅配置稳定薄墙碰撞，展开完成才启用，重播时关闭；女孩是演出演员，无伤害目标/硬碰撞。后方纸台为可见几何支撑，尚不是完整可行走楼层或导航。

开场锁移动与战斗时钟，结束/取消恢复；F12重播，F3回院。该试演隔离普通战/Boss快捷键和主动技能/控制台，防止启动旧团团流程。没有怪物攻击、纸杯捕捉、可破坏纸墙、弹力球布景碰撞联动、掉落或正式存档。恐龙/骑士/纸火焰尚未制作，不能把297当完整Boss战。

## 验证

validate_paper297.gd加载真实世界297，检查无团团战斗、锁定/恢复、角色尺寸、各时点姿态/书本、碰撞时机、重播/取消；截图docs/paper297-{idle,toss,fold,castle}.png，报告paper297-validation.json。完成结果见最终报告；截图只验证指定镜头，非完整昼夜/各角遮挡或玩家战斗验收。树避让、光照既有问题不重开。

最终16项全部通过，无新脚本/shader错误。已看四时点截图；首轮等待单个process_frame早于舞台回调，导致归还控制检查抢跑，改为显式推进原_process完成事件后最终全过。原生几何纸条与城堡使用独立粗糙材质并压低基底亮度，避免本地光池把纸洗白，没有修改场景灯。现存试演限制：草会穿过贴地纸条、独立书封细节简化、人物在后方本地光池下的颜色与柔光/镜头纵深差异仍待实玩调校；纸台仅几何支撑没有完整可行走碰撞/导航。两侧城墙已配薄墙，但尚未验证所有方向实际顶撞或完成可破坏玩法，不能称作完整摆件/战斗接入。

两套启动器latest297；71/combat291保留当前完整战斗，169默认主场景不改。297仅开场，F12重播/F3回院。未提交/push。

## throw完整提示词

Use case: identity-preserve gameplay sprite animation keyframe. IMAGE1 is the approved-proportion paper girl gameplay sprite; IMAGE2 heroine game sheet is strict compact-head/body pixel-style reference. Make ONE full FRONT RELEASED-BOOK THROW pose of SAME paper girl. Keep precisely image1 wide head, actual wide round face, eye size/head-body ratio, cheeky determined expression, chestnut short fluffy hair/crown curl, blue/yellow page tab clips, green eyes, cream blouse/sage apron/taupe skirt/brown short boots and muted pixel palette. Do not lengthen body or slim face. Both short arms have just tossed a heavy book upward: elbows bent naturally outward around shoulder height, open palms pointing up above shoulders on either side of face; arms are NOT long vertical sticks, shoulders/wrists anatomically connected, five fingers simplified into readable pixel clusters. Slight upward gaze and small proud open smile. CRITICAL: NO BOOK held anywhere, no book floating in image, no dinosaur in hands; the book will be a separate game object. Reveal the formerly hidden simple apron bib and one small cream paper crane brooch, no clutter. Feet planted on same baseline as image1, upright fixed front game view, no jump/side tilt. Full-body same overall head-to-foot framing/dimensions and foot center as reference. Exact same coarse pixel-cluster scale and outline weight as image1 and heroine, no detailed painting/vector. Genuine transparent background, no shadow/floor/effects/scenery/labels/text/extra pose. One sprite only.

## castle完整提示词

Use case: stylized-concept, production 2.5D pixel-game papercraft prop. Image1 paper girl gameplay sprite is palette/pixel-cluster/handmade identity reference only; do NOT include girl. Draw ONE broad freestanding CUT-PAPER CASTLE THEATRE BACKDROP on genuine transparent background. A single coherent flat cardboard silhouette with central squat turret and two smaller side towers, scalloped battlements, broad empty central archway/gate, a few simple hand-cut windows, small folded flags. Soft pastel cream/kraft cardboard, dusty sage and terracotta accents, small yellow/blue cardstock tabs; slightly wonky hand-cut edges, visible pencil fold lines, cream paper seams and tiny matte tape corners. Bold readable stepped pixel clusters and dark muted plum/brown outlines matching reference, broad simple shaded blocks, no fine illustration textures. IMPORTANT: this is a THIN stage-flat of a castle, NOT a massive real stone building, no deep rooms/real castle roof volumes. Draw for game's fixed camera looking down25degrees: mainly front face with a small visible thickness/folded rear support hint near lower sides. Flat base along bottom with two little folded cardboard support tabs; viewer can clearly understand it was folded flat and popped up. Central battlement lower than highest side flags, enough uncluttered top edge for girl to peek over later. Central archway should be genuinely transparent/open through the asset (not painted black). Width about2.3x its visible height. No ground plane/base platform/book in picture, no soil/grass/floor/shadow/scenery; no characters/monsters/weapons/text/lettering/labels/sheet/extra props. Full castle including all support feet and flags inside frame with generous margins. One isolated castle cutout, no background/glow/vignette. Materials tactile papercraft but conveyed in actual coarse pixel art, not photorealistic/cardboard render.
