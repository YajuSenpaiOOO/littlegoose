# 生活小院44：菜园与开放庭院

2026-10-17 完成44；2026-10-18 当前入口升级45（见下方批次补记），继承43植被/浓景深与40玩法。保持 GL Compatibility、25°透视相机和原镜头规则。本轮是待用户确认的布景，未实现种植经营。

参考原始 layout-A.png 与 courtyard-local-v1.png：房屋右侧菜园、屋前活动空间、低矮边界；根据当前地图道路调整比例，没有把整张概念图直接铺进地图。

- 三块错开的木边菜畦，20株独立白菜/生菜/胡萝卜叶/支架番茄，轻微摆动。
- 土壤沿地面高度铺设；床体与低木围栏有独立碰撞，支点贴地，围栏有真实投影。
- 菜畦之间可走，入口对准小径，东侧围栏顺着现有道路收边。
- 门前与菜畦间加入带厚度、磨边的不规则石板；屋前仅用两段短围栏框住庭院，保留开放院口。
- 菜畦与石板下清掉54处原草；移开重叠的灌木与花，不额外堆满装饰。
- 静态木杆/立柱合并绘制，物理碰撞仍独立。没有做正式性能基准。
- 工具间、工作台和路灯未加入，待当前空间关系确认后继续。

## 运行与对照

根目录 preview_world_garden.cmd，项目默认入口也切换到 world44。
Ctrl+F3 近看菜园；F3 回屋前；Ctrl+G 对照本轮庭院；Alt+F12 调景深。
Ctrl+1/2/3 植被层次与 Ctrl+F2 面板沿用43。preview_world_vegetation43.cmd 保留上一版。

## 资源与实现

- [生成的透明作物图集](../assets/garden44/vegetables.png)
- [完整生图提示词及出处](../assets/garden44/prompt.md)：使用内置 image_gen，以已选房屋为画风参考。
- profiles.json 记录象限与脚点，运行时裁分，不修改原图。
- scripts/art/kitchen_garden44.gd：菜畦、作物、围栏、石板、草与既有植被适配。
- 三个 garden_*44.gdshader：土壤、木材和石板的程序材质。

## 验证

普通GPU渲染运行 garden44_probe.gd，9项检查通过，见 [结果](garden44-validation.json)：
实际角色走进菜园、穿过菜畦间小路并走出；原屋前至林路与开放院口通行；切换布景时碰撞同步；旧战斗遭遇仍能启动。没有重新运行完整卡池/全地图性能测试。

已检查最终同机位截图：
[屋前](captures/world_restart/garden44_home.png)、
[院口](captures/world_restart/garden44_entrance.png)、
[关闭布景](captures/world_restart/garden44_before.png)、
[开启布景](captures/world_restart/garden44_after.png)。

## 2026-10-18 批次补记：45材质与小摆件投影

没有另建一份小摆件说明；后续同一批小院布景继续集中记录。
当前预览与项目默认入口 world45；preview_world_garden44.cmd 保留44版。

- 围栏/木边菜畦仍是简单3D几何体，生成木纹沿每根木杆的长轴展开；横杆、斜杆与立柱分别适配，再合并静态网格。
- 石板仍保留原有厚度、轮廓与位置，表面使用生成石面，世界坐标采样减少拉伸，沿用边缘压暗。
- 两张纹理由内置 image_gen 生成，参考已选房屋风格，PNG不改像素；开启mipmaps，避免远距离采样碎点。
- 20株菜苗、灌木及根裙、花与小石子加入双面alpha轮廓投影；20株菜苗和8株灌木加贴合地形的柔接地暗部。原围栏、房屋和树影保留。
- 菜苗拨动参数同时接上实际主角位置。没有新增种植/采集规则。
- 不切Forward+，不改地形、碰撞、相机或战斗。本轮没有正式性能基准。

Ctrl+T 循环：原材质 → 手绘木纹＋原石板（当前默认） → 木纹＋石面。用户反馈：原石板更好，栅栏纹理差别不明显；保留生成石面仅作对照。
Ctrl+H 开关本轮新增投影/接地暗部；Ctrl+F3 近看菜园；Ctrl+G 原庭院整体对照。

资源：[木纹](../assets/garden45/wood.png)、[石面](../assets/garden45/slate.png)、
[两份完整提示词与出处](../assets/garden45/prompts.md)。

验证：[garden45-validation.json](garden45-validation.json)，10项通过。
包含三档材质切换保持布局/物理、相机不变，新增投影开关可恢复，以及冻结画面、隐藏柔接地暗部后，真实轮廓投影仍改变5082个渲染像素。该像素数是本次机位诊断，不是跨设备性能指标。
截图：[首次默认（含生成石面）的历史截图](captures/world_restart/garden45_home.png)、
[原材质](captures/world_restart/garden45_material0.png)、
[木纹](captures/world_restart/garden45_material1.png)、
[木纹＋石面](captures/world_restart/garden45_material2.png)、
[影子关](captures/world_restart/garden45_shadow_off.png) /
[影子开](captures/world_restart/garden45_shadow_on.png)。

## 2026-10-18 批次补记：46树冠、落叶与院口灯

当前入口 world46；preview_world_garden45.cmd 保留上一版。继续在本份小院记录中汇总，没有为每件摆件单开文档。

- 原石板仍为默认，材质与摆件影子开关沿用45。
- 单张树贴图仅在树冠区域轻微偏移采样；底部和主干区域不动，碰撞和根裙几何体不变。近处最多48棵更新，远处静止；独立树影使用相同风时钟。周期计算移到顶点阶段，避免每个树冠像素重复做三角函数。保留原遮挡淡出逻辑和重建根裙后的重新绑定。
- 落叶是程序生成的折面小叶片，固定32个MultiMesh实例复用；只从附近树冠范围生成，避开房屋和水面，飘落后短暂停留、淡出。没有每片刚体、每片实时阴影或节点不断创建。未做玩家踢叶/草地推动落叶。
- 一盏生成的小木灯位于院口右侧围栏外，主杆有碰撞与轮廓日光投影。灯罩有少量发光，附近仅一盏短程暖色OmniLight，不增加点光源阴影贴图。入口开放，院前草地继续留白。
- 保持Compatibility和当前浓景深，没有体积雾、全地图动态叶子或新的昼夜系统。

开关：Ctrl+B 树冠微动；Ctrl+K 落叶；Ctrl+L 小灯（含碰撞与局部灯光）。
Ctrl+F3 近看菜园，F3回屋前，滚轮沿用。树冠开关不用WASD，避免按对照键时误走动。

[生成的小灯PNG](../assets/woodland46/lantern.png) /
[内置image_gen完整提示词与脚点记录](../assets/woodland46/prompt.md)。

验证：[woodland46-validation.json](woodland46-validation.json)，13项通过：
树根和物理变换稳定、树影同风时钟、冻结画面的树冠实际变化、固定叶片容量、各开关恢复、实际角色穿过灯旁院口、旧第一波战斗启动。
同机位各120帧短测，中位帧间隔约10.232ms（效果关）/11.462ms（效果开），P95约12.805/13.996ms，绘制调用约1221/1227。仅当前RTX5060 Laptop环境的暖机样本，不是跨设备承诺，也不是全地图/全战斗性能基准。

截图：[屋前](captures/world_restart/woodland46_home.png)、
[院口](captures/world_restart/woodland46_entrance.png)、
[效果关](captures/world_restart/woodland46_effects_off.png) /
[效果开](captures/world_restart/woodland46_effects_on.png)。
leaf_detail_test仅为颜色诊断时放大的一片测试叶，不是正式叶片尺寸。
2026-10-18 位置修正：灯移至 (-1.0, .85)，让主杆和灯笼完整轮廓均离开短围栏；重新检查屋前截图与院口实际行走，13项检查通过。下一轮优先讨论光色、局部空气与远近层次，暂不继续填满院前。


## 2026-10-18 批次补记：47三档光影与加高小灯

当前入口 world47，preview_world_garden46.cmd 保留上一版。
Ctrl+7 原光色；Ctrl+8 暖阳深林影（暂定默认，等待用户选择）；Ctrl+9 薄雾柔光。
三档保持同机位、同景深、同布局、同素材。原石板仍为默认。无新生图素材。

- 原光色：恢复46的环境光、日光和深度雾，关闭新增分色与柔光薄片；灯仍采用47的加高尺寸，以便比较时几何一致。
- 暖阳：实际环境光从.32降至.235并稍偏冷，日光从.77升至.90且偏暖；温和分色与对比度增强合并进已有景深着色器，不新增全屏采样通道。林影更沉，保留亮面。
- 薄雾：实际环境光.27、日光.83；深度雾19m开始/48m结束，淡青灰色，曲线1.25；仅打开原树缝位置的两片低密度、柔边、按深度淡出的光束薄片。这是Compatibility可用的近似，不是原生体积雾。
- 景深档位沿用Alt+F12；关掉景深后分色仍可用，并绕过25次模糊采样，避免把两个效果绑死。
- 小灯从1.85m提高到2.65m，像素尺寸同比放大；脚点固定，立柱碰撞同步加高，灯罩对应的点光源位置同比调整，照明范围2.9m，无新增点光源阴影贴图。仍在(-1.0,.85)，主杆与围栏有间距。
- 没有新摆件，没有改变镜头、角色比例、行走和战斗规则。

实现：light_profiles47.gd / woodland_atmosphere47.gd / scenic_focus47.gdshader；
woodland_life47.gd只适配灯高，46版原实现保留。

[light47-validation.json](light47-validation.json)：14项通过。
包含冻结画面的三档渲染差异与原档还原、环境参数恢复、镜头/人物/灯位置不变、加高灯的贴图/碰撞/光源尺寸对应、关闭景深后分色保留、院口实际通行与旧第一波启动。本轮未做跨设备性能基准。

同机位截图：
[屋前原光色](captures/world_restart/light47_home0.png) /
[暖阳](captures/world_restart/light47_home1.png) /
[薄雾](captures/world_restart/light47_home2.png)；
[菜园原光色](captures/world_restart/light47_garden0.png) /
[暖阳](captures/world_restart/light47_garden1.png) /
[薄雾](captures/world_restart/light47_garden2.png)。

## 2026-10-18 批次补记：48舞台层次与局部柔光

当前入口world48；preview_world_garden47.cmd保存47历史。
用户反馈47的7/8主要是色差，9灰雾像恐怖场景，不是温馨童话；停止该雾方向。

Ctrl+7 原版；Ctrl+8 舞台层次；Ctrl+9 舞台层次＋局部柔光（当前默认，待验收）。
使用46原光照/远景空气，不使用47短程浓雾及光束薄片。

- 两棵近景框景树在贴图及根裙上同步压暗；景深通道按实际深度加强近景、适度降低远景饱和度，中景保持清楚。不是整屏换一种颜色。
- 暖色柔光限定在三个窗户与灯罩的屏幕投影区域；12个小范围采样只在目标附近执行。白发、白墙与亮黄色树冠不作为泛光源。切换房型时暂关闭原房屋的三处窗户蒙版，只保留灯罩；切换小灯时同步移除其蒙版。
- 沿用已有景深通道，不额外增加全屏绘制；关闭景深仍可保留层次与柔光。局部柔光为兼容模式近似，非HDR原生Bloom。没有新增美术图片、几何体或雾。
- 原石板、2.65m小灯、树冠微动与落叶保留。主角、敌人和场景物理布局未变。

[stage48-validation.json](stage48-validation.json)：17项通过。
包含固定画面的三档实际变化与原档还原、原雾参数不变、主角中心及脚底采样区域像素未变、关景深时效果保留、院口真实行走与旧战斗启动。
未做本轮跨设备性能基准。

[屋前原版](captures/world_restart/stage48_home0.png) /
[层次](captures/world_restart/stage48_home1.png) /
[层次＋柔光](captures/world_restart/stage48_home2.png)；
[菜园原版](captures/world_restart/stage48_garden0.png) /
[层次](captures/world_restart/stage48_garden1.png) /
[层次＋柔光](captures/world_restart/stage48_garden2.png)。