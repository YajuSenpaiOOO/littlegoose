# 298 · 山顶纸城堡 / 草地战场 / 开门出场

用户否定297的3D地板、空中程序书与女孩平移，要求移到山顶最上方，放大城堡并让纸偶从城堡后/门内出场。本版在既有140山顶草地后部：grove+(-24,-26)，主角从grove+(-24,-19.5)看演出。使用原山地网格/碰撞/围栏/野餐设施，不改地形、不批量清树或重开旧遮挡调参。297历史预览保留。

## 空间与开场

草地直接当战场，不铺书本封面或3D纸地板。298不实例化297的book、lanes、plinth，女孩固定在城堡后grove相对坐标(-25.15,-29.1)的实际草地高度，全程位置不变。先抱书惊讶/切抬手施展关键帧，城堡原地翻起、两侧薄卡纸山树从较高位置飘落立起，不再演3D书抛到空中或角色滑动。手中书的细致翻页动作尚未画，不把两张关键帧当完整手部动画。

城堡原图297复用，宽6.4→9.8m，保持图像比例，有效高约4.38m，最终相机朝向X=-25度。角色保持竖直169/192展示例外及1.6m有效高，不倾斜角色。薄纸墙和门有独立稳定脚下碰撞，不能把透明PNG矩形当作真实体积；支持角色与布景原生轮廓影。角色使用主角独立复制材质，各纸道具独立粗糙材质，未改场景灯或自发光。

3.8–4.6秒双扇纸门沿左右门轴朝内打开；门开度>.65才禁用门挡，城墙碰撞保留。4.5–7.35秒插杆恐龙由城堡后侧z=-1.2沿草地走到前方z=4，带程序摇晃，小纸怪在后面随行当操纵者，不从地下升起。7.5–8.2秒关门，8.6秒恢复玩家控制。现在是无伤害出场示范，恐龙还没有AI/血量/技能，非真正刷怪波次或Boss战。

## 美术资源与来源

内置image_gen三次分别生成gate.png（左右纸门合图）、scenery.png（山树相连侧景板）、dinosaur.png（恐龙与操纵杆）。均用297 castle.png为像素风/配色参考，原始PNG复制到assets/paper_stage298，未程序修绘/抠图/重采样。尺寸/alpha128边界/脚点/span/hash在layout.json。

原始目录C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/：
- gate：exec-98763e8b-40ef-4826-8ad6-970dabc990cc.png
- scenery：exec-5d1ce468-e48e-4ab6-91a8-3524543e7335.png
- dinosaur：exec-a2a16bdc-e4bb-412d-83f0-847cb65f0332.png

门按alpha边界由两个原生AtlasTexture取左右半张并设外侧门轴，只作游戏组件UV取样，不改原PNG。门总宽2.9m，侧景每块3.5m，恐龙连杆总宽1.7m（按原图比例，约2.22m总高）；杆末端接近地面，恐龙脚位于杆上方，是纸偶而非生物脚锚。小纸怪沿用paper134/base_C及原脚点/比例，缩到.42m有效高。

## 接入与验证

world297只添加默认保持旧入口的stage工厂/锚点/出生点/说明虚方法，298覆写；不动169默认/291战斗/旧山顶地形。298仅展示，禁旧团团快捷键/Q/C，F12重播、F3回院，取消/结束归还控制。不接正式存档/奖励。

validate_paper298.gd检查山顶高度、无旧3D书/地板、固定女孩、门开合/碰撞、纸偶走出及贴地、真实门口物理射线、取消/重播/归还控制。报告docs/paper298-validation.json，截图paper298-{before,scenery,gate,emerging,settled}.png。美术和各角遮挡仍以实机截图/用户体验为准，不能把节点存在或单方向射线当所有碰撞已通过。

最终23项全部通过，无新script/shader错误，保留旧relay_flag245导出警告。五个时点截图全部查看，山顶castleroot实测Y=11.6723，主角位于原生可走山地。两侧景落下的高度插值补入后另做check-only脚本编译；不把局部逻辑检查当完整视觉验收。

当前已知：关门时女孩会被城堡墙遮住，开门才从拱门里看到她，后续需专用探头指挥窗/固定位置设计；小纸怪仅沿杆后随行，尚未专门画抓杆动作。恐龙不攻击、不造成接触伤害、不占正式怪物名额，尚无喷火/骑士/波次/掉落。山树景不是新的真实树，不接旧整树避让或全场树清理；不替换山顶已有野餐道具。卡片边脚与坡地仍有局部接地缝，需要后续在确定构图后精修。

两套启动器latest298，72/stage297保留旧开场，71/combat291保留完整战斗。169默认主版本不变，未提交/push。

## gate 完整提示词

Use case: production pixel-game papercraft prop component. Reference image is the existing thin paper castle; MATCH its chunky pixel clusters, dark muted plum/brown outlines, warm cream/kraft/terracotta and dusty sage palette. Draw ONE CLOSED DOUBLE CASTLE GATE ONLY, isolated genuine transparent background. Two symmetric thin cardboard leaves meet at straight vertical center seam, overall silhouette is a broad ROUND-TOP ARCH, bottom flat. Combined width about1.3 times height. Each leaf has simple hand-drawn vertical timber-like lines, a few flat sage paper reinforcing strips, tiny yellow paper handles near central seam, visible light kraft paper thickness at outside edge. Everything reads hand-cut/cardboard stage prop not real iron/stone and not 3D sculpted door. Left/right top each follows its half of the arch, no surrounding arch frame/wall/castle, no opaque rectangle around gate, no shadow/floor/text/other objects. Full component inside generous transparent margins, frontal camera plane, two leaves exactly aligned in one image for game to split at center as separate hinged cutouts. Coarse pixel shapes, simple stepped shading, restrained details matching reference. Only the connected closed pair, no alternate views/sheet.

## scenery 完整提示词

Use case: production 2.5D pixel-game paper theatre scenery prop. Reference is a thin cardboard castle; match its exact warm cream/kraft/terracotta/dusty-sage palette, chunky stepped pixel clusters and muted dark brown/plum outline. ONE coherent low side-stage backdrop: two rounded overlapping hand-cut sage paper hills with a cluster of three simple paper trees growing from their silhouette, one taller rounded tree and two small fir-like folded trees. All on ONE flat continuous cardboard standee, obvious hand-cut outline, a couple visible fold seams and small matte tape patches. Thin cream/kraft edge with two small folded support tabs near base. Reads charming amateur handmade cardboard theatre scenery, no real leaves/wood/stone, no realistic terrain. Broad low silhouette, width about1.7x height, mainly front with just small top/thickness cues for fixed game camera looking down25degrees. Actual chunky pixel art, broad simple color blocks, same cluster size as castle, no dense texture/airbrushing. Genuine transparent background; full outline/support feet within generous margins. No ground plane/grass/soil/book/character/castle/rod/extra separated objects, text, labels, sheet, shadow or glow. One connected side scenery flat only.

## dinosaur 完整提示词

Use case: production pixel-game paper puppet enemy prop, ONE full-body cutout on genuine transparent background. Reference castle supplies exact chunky pixel clusters, muted dark plum/brown outline, warm handmade cardstock aesthetic. Design a charming squat mint/sage PAPER DINOSAUR PUPPET on a visible thin wooden/cardboard control rod. Side silhouette facing viewer LEFT with head turned slightly toward camera enough to see a friendly round dark eye. Small silly T-rex-like dinosaur: big rounded head, stubby snout, tiny open mouth, two tiny forearms, big rounded belly, short legs, modest tail balancing to right, a few blunt terracotta paper back-spikes, cream belly panel. Clear flat layered cardstock, visible folded knee/tab and 2 tiny tape seams; no real scales/fur/anatomical muscles. A narrow warm brown stick visibly attaches behind lower belly and extends DOWN beneath the feet about35% of dinosaur body height; rod bottom visible. This is one connected puppet+rod asset, like someone below/behind scenery is operating it; no hand/operator included. Pixel shading simple broad stepped color blocks matching reference, dark outline readable at tiny game scale. Fixed front game camera looking down25deg, paper face remains mostly side-on stage silhouette. Full puppet and entire stick inside generous margins, no floor/shadow/background/glow, no castle/character/scenery/text/labels/sheet/alternate poses. One adorable handcrafted paper dinosaur, not a real living dinosaur or glossy toy.
