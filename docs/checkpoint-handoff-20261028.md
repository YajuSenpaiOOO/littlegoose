# 当前交接：小白鹅大冒险

更新：2026-10-27。这是当前状态摘要；版本历史见[CURRENT_STATE.md](CURRENT_STATE.md)，专项细节按需读。旧docs/HANDOVER.md及README正文中的world48/122等“当前默认”仅为历史。运行入口以godot_world/project.godot为准。

## 1. 直接开始

- 2.5D共用规范（2026-10-27）：新增根AGENTS.md，所有资源/摆件/显示工作须读 godot_world/docs/2_5d_display_contract.md。新独立插画摆件默认按最终俯视镜头作画、相机朝向展示；地形实际网格，脚点/遮挡/碰撞/接触影/投影/真实光源各自明确。规范不等于共用工厂和旧资产迁移完成。主角保留169/192屏幕身形；全卡片倾斜更接近原图比例，但不等于唯一正确造型，不能以灯光修复强行迁移。196竖直展示是实验，灯穿插仍未宣称彻底解决。

- 统一入口：根目录 `00_开始游戏.cmd`，回车进入最新204；菜单另有普通主版本169、小蜘蛛173及历史目录。旧preview启动器集中在 `tools/preview_history`，不再往根目录加cmd；换最新版本只更新 `tools/launch-game.ps1` 的入口表。
- 最新204（2026-10-27）：修纸飞机辅助圈浮在树干/布景表面。原150世界环点投屏后2D叠画，204专用纸机工厂改世界空间贴地窄带，逐顶点floor_height+0.035、正常深度测试；大高差断开，不跨崖画墙；中心/覆盖扇区小圈一并迁移。同位圈避免重复叠亮，落点计数小点由既有HUD统计替代，笔记页UI保留。半径2.4/选敌/投射/伤害不改，取消/退出清空；11项含GPU真实遮挡对照通过，树根昼夜截图复核。主角/树避让不改，独立204存档，169/173/203保持。见godot_world/docs/paper-ground204.md。

- 性能工作（2026-10-27，已全部还原）：诊断结论有效，修复已按用户要求回滚。诊断：204院子37FPS/森林中心29FPS（vsync关、RTX 5060、1600×1000），169同院子62；204全局+11ms主因whole_tree_fade200扫描（单次4.6–7.4ms每0.07s）、29盏常亮真灯+3盏恒开阴影（森林内关灯省7.9ms）、focus面片约2ms、180+地形扩容；169自身16–18ms地板=Compatibility约1000draw/每帧200万+三角形（阴影重画4–5遍）。修复三步（树扫描共享射线、真灯24m/阴影12m门控、地面154surface同签名合并25）实测204森林28.8→36.7FPS、院子37→44.6、169树丛56→106FPS，forest200回归22/22、院子截图近逐像素一致。用户实玩后报山顶石头墙与眺望远景缺失，要求全部还原；已从docs/perf_fix_backup_20261027/逐字节还原三个文件（whole_tree_fade200/forest_lighting191/coastal_edge140），实机确认154surface恢复、编译干净。还原后取证：墙与远景问题依旧、且169/204节点状态完全一致→非本次优化引入。**远景缺失根因已查明**：woodland_world202._ready第26行自动start_spider170()，试演上下文把meadow.landmarks.grove临时改为森林中心(-48,26)（原grove=(-50,-45.7)西北），而coastal_vista141的淡入淡出每帧按当前grove计算→204载入即在旧西北山脊永远淡出；按F2/F3退出试演会还原grove、远景即回。正确修法待定（vista改用固定参考或试演期间同步处理）。山顶石头墙：墙节点清单169/204一致（79/80两代挡墙在两版本中均隐藏），属更早遗留，待用户指认具体位置与旧版本截图再查。诊断探针scripts/world/perf*.gd全部保留，报告docs/perf*-report.json与perf*-run.log有效；对照截图docs/perf_before_shots/。性能问题本身仍未修复，重启修复时从备份文档与报告继续，注意补全画面核对点位（北坡眺望口等）。地形结构结论（2026-10-27追加实测）：基础地板主因是地面渲染结构——ground节点（@MeshInstance3D@5）被coastal_edge140以layers=0停绘、由子节点NorthernBufferTrim140承载154个surface各配独立材质，同shader仅20组参数（128个surface参数完全相同）；Compatibility下1 surface=1 draw×主画面+2段阴影≈460 draw且全图AABB永不视锥剔除。实测隐藏该子网格：院子1040→575draw省3.1ms、森林1207→587draw省5.8ms；同参数surface合并（154→21）预计无损拿回大部分。阴影选项实测（森林中心）：大地形cast_shadow关−2.2ms（块级截图差异在动画噪声内）、太阳阴影2段→1段−2.5ms、阴影距离42→18m−1.0ms、太阳阴影全关−3.3ms（树影消失，不推荐）。太阳现状：shadow 2段平行分割、max_distance 42、woodland_world104有Q键质量开关。探针perf204_terrain/terrain2/trims/trimmat/groundmat。地形合并尚未实施；改地形前注意137/138回归历史，先备份。地形合并已实施（2026-10-27第二轮）：coastal_edge140._ready 在 NorthernBufferTrim140 构建后按渲染签名（shader代码+全部uniform+顶点布局）合并相同surface，154→25；保留每组第一个材质实例（仍在ground_materials内，脚印每帧上传正常）。地面父节点（layers=0不渲染）、地理/碰撞/台阶不变；coastal_breeze143/rail_station85 等按surface遍历的脚本兼容。验证：院子截图块级差异4/160（近逐像素一致）、森林91/160（低于同场景动画噪声基准83/160同量级）；forest200行为回归22/22；204累计（相对最初未修复）：院子37.2→44.6FPS、森林中心28.8→36.7、夜景30.1→36.8、台阶30.6→35.2；169（仅合并收益）：院子62→68、树丛56→106（draw 817→516）、站台draw 586→283。回滚：docs/perf_fix_backup_20261027/coastal_edge140.gd 覆盖回scripts/art/即恢复154 surface版本。

- 最新203（2026-10-27）：202森林试演基础上，内置image_gen按194睡猫简化画风重画挂猫/机关布偶，资源assets/forest203、提示词同目录prompts.md。蜘蛛命中改为专属毛絮并叠加13%短挤压/回弹/方向轻晃，保持织网时钟与网垫，不切动作；气球剑独立汁液也替换。接触不扣血、只轻推，反馈有频率/数量上限。主角192、树避让200不改；独立203存档，见godot_world/docs/spider-feedback203.md。

- 最新202（2026-10-27）：森林内直接三蜘蛛试演，F6单/三只、F7重开、1—9组合、F2结束原地看布景、F3回院。现有173小跳/丝球/脚下网垫复用；真实低地碰撞导航，试演退出恢复原林地中心/导航。蜘蛛新增昼夜环境调色，非原生树影接收。中央树191遗留0.65半径/4米高隐形投影圆柱移除，原接触/轮廓影保留。主角192、树避让200不改；正式三鹅门禁/奖励/蜘蛛姐姐未接。独立202存档，见godot_world/docs/forest-spiders202.md。

- 最新201（2026-10-27）：用户反馈200仍先糊脸再消失，明确暂停树问题、记备忘录并转装饰。KNOWN_ISSUES.md与AGENTS已记“未解决/暂缓”，不得继续借装饰调树。201继承200、主角192不改，新内置imagegen画像素短木栏/淡紫旗/小猫/柱顶灯模块，落地6段断续栅栏、2树桩灯角/软布偶，共8新增真实琥珀光；栅栏避断面/路心并有占地、接触/轮廓影、199深度。复用原灯管线，最近20灯范围上传避免调色数组溢出，不改旧灯强度；树桩灯原自动识别，不重复加灯。19项检查含昼夜不过曝/树逻辑未改/实走入口-中央-小屋通过，截图复核。默认从吊床角开始，F9吊床/F7屋/F8样板。独立存档，169/200保持，见 godot_world/docs/forest-decor201.md，资源assets/forest201。

- 最新200（2026-10-27）：用户澄清接受早期整树淡出，主要修未及时触发/整屏树叶糊脸，反对提前清树+碰撞消失。200禁用199静态清场，保留199灯/吊床深度/根部碰撞/同步树影。whole_tree_fade200使用实际billboard绘制基、alpha射线与同屏主角平面深度；大面积近景叶片独立检测，不受树干中心/in_front门槛限制；加入19棵主题外围树与中央树，晚写回避免旧脚本覆盖。恢复早期快退慢回，扫描0.07秒/保持0.65秒，无分组或距离提前移除。602普通树root可见、605有效树碰撞，避让扫描不改碰撞层；22项实机检查含全屏近叶独立fixture与实际台阶路线通过，截图查看。独立存档，169/199不改；详见 godot_world/docs/occlusion200.md。

- 最新199（2026-10-27）：按用户要求精修，主角hero192竖直不变。8盏森林灯/双树/猫10卡片使用card_depth199片元DEPTH代理，保留相机轮廓却按脚点竖直平面遮挡，解决半身穿插；仅Compatibility固定镜头验证。灯保留原画不接自身强光，真实外照不改；树/猫正常受光。双树按原画脚点回投地面校准两碰撞，半径0.43/高1米。普通树shadow19跟随可见alpha淡出；入口PATH南向视线楔形区域清16棵普通树，隐藏根片/关闭碰撞，保留侧边/北冠，动态避让兜底。19项地图检查+4项GPU前后胸头遮挡+1项实际原生影子减弱通过，前后/夜景/路径截图复核；非全部摆件完成。小黑鹅/全演员调色、独立主题树投影/所有旗架等仍待后续。初版顶点深度裁切错误已改片元DEPTH；不得恢复旧POSITION版。详见 godot_world/docs/relations199.md。独立存档，169/198保持。

- 最新198（2026-10-27）：用户撤回197身形试验，明确恢复竖直主角。world198直接用hero192控制器与材质，摆件恢复原朝向，禁用F1/F2角度试验；196近景预清场和森林其他内容保留，169/197保持。下一步暂停加摆件，先做旗架杆/路灯/双树根部的脚点-占地-遮挡适配，再补小黑鹅等演员调色与投影来源整理。初步只读普查（运行197）结果display198-inventory.json，1629精灵/1291碰撞节点/745影子相关节点，并非已分类/已验收。新游戏198未声称修复全部摆件关系，见 godot_world/docs/upright198.md。

- 最新197（2026-10-27）：用户明确授权主角相机朝向试验。hero197显示基对齐实际相机，保留平面内走路侧摆/动画缩放，物理身体与碰撞不转、原图和脚点不改；相机朝向时关闭192额外法线倾角，F1切回192身形时恢复。显示单位轴比1.0对0.91015444，真实受光/原生阴影保留，113投影读显示transform，残影同步。默认恢复路灯/站台原朝向，F2仍可切竖直。24项实机检查+独立受光/阴影2项通过；小院两身形、站台/森林昼夜截图查看，真实台阶通行；无全敌人命中复测，最终形体仍待用户体验。独立存档，169/192/196保持。规范/AGENTS已记录授权试验例外，不得按旧身形基准擅自撤销。详见 godot_world/docs/hero-facing197.md。

- 最新196（2026-10-27）：用户反馈195南向树冠仍糊脸。新增独立相机邻域预清场，按冠片尺寸/未来相机/中央72%视域判断，不再依赖in_front(hero)先通过，保持4秒、传送安全初始化；604普通树共用。新增15个完整路灯/站台卡片竖直对照，默认竖直，F2准确恢复原朝向，不动原图/比例/位置；森林拆层屋/树等未迁移，灯位仍原定位，不能宣称全场朝向或灯穿插已解决。实机审计：主角X0/普通树FIXED_Y竖直，森林新摆件全BILLBOARD，站台部分显式-25，岩壁台阶为网格，并非所有物体倾斜；不需全量重画。32项Compatibility回归/真实南向通行检查通过，截图查看；连续移动舒适度仍待用户验收。详见 godot_world/docs/foreground196.md。独立存档，169保持。

- 最新195（2026-10-27）：共用whole_tree_fade195管理器接管全地图604棵登记普通树，前方1.8米预判、相邻遮挡组保持2.4秒、慢恢复；近景边缘保留框景而非整棵消失。树根/树冠同步，无逐棵手调坐标。中央主题树等独立摆件沿用旧规则；未改资源、几何角度、灯光或169。30项Compatibility检查通过，含194回归、南向预判/短停保持/根冠同步；舒适度仍待移动试玩。灯卡片与角色相交尚未修，不能宣称灯遮挡已完成。相机25度、主角竖直、部分美术卡片朝相机、岩壁/阶梯为网格，不需要全量重画。详见 godot_world/docs/foreground195.md。

- 最新194（2026-10-27）：移除手工角隐形圆柱和叠加轮廓影，保留接触影/碰撞；内置image_gen重画双树空吊床与独立睡猫，新增侧后方吊床角，删除旧猫叠层与193补绳，中央大树紫布仍保留为空布景。补41个可拨花/蕨/灌木，避开路心、断面和台阶；单点延迟“呜喵”布偶机关随后露出操纵蜘蛛，无伤害/声音，18秒冷却。194继承192身形材质与193灯光/敌人昼夜色，独立存档，普通169未改。25项Compatibility检查通过，实走入口至中央树并查看昼夜/机关截图；最终构图待移动试玩。F8样板/F9吊床角/F6入口/F7屋/F3院；详见 godot_world/docs/forest194.md。

- 最新193（2026-10-27）：用户确认修复敌人夜间仍亮、吊床浮空吊点和森林暖光不足。`enemy_grade193.gd` 仅在193实例中按源shader缓存包装团团/纸怪soft_ink，读取气球剑159同源combat_world_tint159，覆盖普通/翻滚/渐退与闲逛，保留变形参数/受击色/alpha；演员蓝色限制到max(R,G)×1.25避免饱和蓝，不改159弹幕。敌人本次接环境颜色，尚非主角192的原生灯光/树影接收。`forest_art193` 两条分段绳连接固定树上吊点与轻摆床结，不重画资源、不加碰撞。现有灯范围×1.35、衰减1.05，无新增灯数；舞台更靠前、更暖ffc584/系数1.65，已登记光域夜间做保亮度暖色校正，保留真实明暗/阴影。主角几何和材质沿用192，169默认/共享敌人shader不改；193独立存档。23项检查含敌人实拍昼夜/状态参数、绳吊点、192比例与截断回归，截图复核；详见 `godot_world/docs/forest-light193.md`。F4纸/F5团团、F8样板/F7屋/F3院/F10调色/F12灯光对照。氛围效果仍待移动试玩验收。
- 最新192（2026-10-27）：用户指出191过曝/偏白光/角色拉长，核实190将整张角色卡片倾斜X=-25导致投影相对169拉长约9.9%。用户明确选择恢复169身形并保留真实受光/树影。192主角继承188而非190，原几何X=0、脚锚点/动画缩放不改，投影Y/X实测0.91015444，与169相同。原生StandardMaterial3D加2×2常量法线贴图只调整受光法线朝上25度；不旋转/重画角色、不用屏幕椭圆提亮，图集绑定原始sheet。独立小样证明顶部受光及原生阴影接收；大地图12项检查含窗前正午/夜间头部任一颜色通道截断、图集/闪避和原生舞台真实像素响应，均通过并查看截图。地方灯减半，舞台琥珀ffd39b/系数1.2，降低灯下调色豁免，保留白发细节。默认169未改，192预览中全地图角色受光变更；191只增加工厂且默认行为不变。独立192存档，F3/6/7/8/10/11/12沿用。详见 `godot_world/docs/hero-light192.md`；191不得视为美术已验收，后续不要为灯光再改角色几何角度。
- 最新191（2026-10-27）：`scenes/world/world191.tscn`，独立191存档。统一原生路灯/挂灯/三窗与门廊暖光，替代旧灯能量限制；布偶/花/手工角/中央树根接收真实灯光，房屋保留暖色原画并向外照明。原生灯叠加，世界空间灯位/舞台范围减弱调色，避免灯下仍染蓝；无主角屏幕椭圆补光。专属第二层简化树干、柱子、屋体/手工角遮挡，最近3盏地方灯+舞台投影，排除地形阴影条纹；主角沿用原有接触/轮廓影，树干卡片不接自身代理影。森林白天柔和舞台0.68、外界白天关、夜晚1.0，约4米柔边光池及微弱空气束，进出渐变。9项检查含关闭舞台后的实拍像素暖光对照及昼夜切换；最终美术仍待用户移动评价。F12新增灯光整体对照，F10调色，其余F3/6/7/8/11沿用；详见 `godot_world/docs/forest-light191.md`。只迁移当前森林样板的受光，不宣称全部旧地图资产完成统一阴影。
- 最新190（2026-10-27）：森林/全地图夜间受光修订，`scenes/world/world190.tscn`，独立 `forest190_preview.cfg`。去掉角色椭圆提亮和屏幕灯锥叠色；原生主角补光已关闭，保留原生顶部聚光灯，Sprite3D改为正常受光并移除旧舞台色增益。灯芯与窗户按位置/深度保光，不再按暖像素保护玩偶暗部。旧光照图集南边界z18.38333以6米过渡，CPU角色采样同步，修复硬分界；夜间森林不再全量叠黑。9项Compatibility检查和小屋早晚/中央昼夜/小院夜景截图完成；树屋原绘制明暗和透明材质差异仍待视觉完善，勿宣称最终光照完成。详见 `godot_world/docs/forest-light190.md`；F8样板/F6入口/F7屋/F3院/F11小径/F10光色。普通默认169保持。
- 沿用188/189：森林中心已南移至(-48,24)，世界仅向南扩30米，不变旧坐标原点；崖面草树过滤、长路径渐入紫色氛围、重画小摆件、11簇可拨花、吊床猫猫保留。正式三鹅门禁、森林战斗与蜘蛛姐姐尚未接入。以下187及更早条目为历史，不要据此撤销南移。

- 最新187（2026-10-26）：preview_forest_ground187.cmd / scenes/world/world187.tscn，原址对照试版。道路PATH+TRAIL合并成单折线，共用转角两侧截面，修复三角缺口；实际入口到屋前行走与全部接缝端点检查通过。树下9%/房屋下12%拆成贴地网格，上部Atlas卡片，交界柔化/拒绝爬岩壁；独立挂灯适配裁切，树按实际alpha遮挡淡出。小摆件约0.016米逻辑像素采样，仅渲染预览，非重画。5项检查与截图通过；接地拼接、透视仍属试验，不能宣称完全解决。用户提出南移：建议中心南移20–25米，保留入口上口/延长小径/北侧林冠挡亮景；现边界z18.38会越界，187未迁移/未扩边界。下一步需做独立南向扩展设计，不能改旧网格原点。详见docs/forest-ground187.md；F8样板/F6入口/F7屋/F3院/F9阴影/F10光色。默认169保持。

- 最新186（2026-10-26）：preview_forest_mood186.cmd / scenes/world/world186.tscn。撤掉185的球形树冠/方屋投影体与外加错向石板；大树和小屋改成实际贴图alpha、相机平面还原的地形轮廓投影，小屋窄接触影沿左墙/门廊落地。新增深度区域光色：入口逐段渐冷，内部深蓝绿/灰紫暗部，中央可读，琥珀灯火保色及局部暖池，回院平滑清除；F10光色、F9阴影对照。新森林前景树改柔和alpha淡出，减少颗粒。15项实机定向检查通过，最终视觉复核报告见forest186-final-visual.json。F8样板/F6入口/F7屋/F3院；独立forest186_preview.cfg，默认169/地形183/正式进度保持。详见docs/forest-mood186.md。

- 最新185（2026-10-26）：preview_forest_stage185.cmd / scenes/world/world185.tscn。用户否定183写实密集树及184圆润包石树，现用11m不对称横枝、错落扁叶簇、自然根部与紫布小舞台；取消整圈石盘，岩碎片独立摆放。独立灯笼配真实暖光，挂点跟随相机平面精确贴合紫布两端。房屋/树新增原生立体投影体（只投影）、地形贴合接触影及石基，房屋底边略埋地。24项通行/投影对照检查通过；最终4项近景对照通过。F8样板/F6入口/F7屋/F3院/F9阴影对照，独立forest185_preview.cfg；默认169和地形183保留，无正式解锁/森林遭遇。坐标剔除错误的中途推测已证伪并撤销，不能当已修根因。详见docs/forest-stage185.md；资源及prompt见assets/forest185与assets/forest184。

- 最新183（2026-10-26）：`preview_forest_alcove183.cmd` / `scenes/world/world183.tscn`。按182反馈恢复180式南岸环抱低地，西北额外挖小屋凹窝，岩肩夹住独立进屋石路；屋移到(-11,-11)一带，补石基/接触影/实际地形轮廓投影，保留相机平面billboard。image_gen新生成蓝绿主景树、毛线篮软幽灵猫手工角、淡紫花蘑菇苔石，已接入；彩旗独立、托举灯和实体架沿用。18项Compatibility实机检查通过，含入口绕树到新屋往返、阶梯与南侧主要通路视线。F8样板/F6入口/F7新屋/F3院，独立forest183_preview.cfg；默认169不改，未接三鹅解锁/森林战斗。紧贴南岸及旧外围树淡出仍可能遮挡/颗粒，见docs/forest-alcove183.md；新资源与prompt见assets/forest183。

- 最新林谷修正182（2026-10-26）：preview_forest_valley182.cmd / scenes/world/world182.tscn。用户反馈181灯/架太低且无碰撞影子、南面高地挡人；新surface182保留北侧Y0.2/核心-2.2，南面逐渐接低草地（约-2.2~-2.28），向前景敞开，原world_bounds不扩。新imagegen托举式灯：2.3米/8柱脚碰撞；架3.2米/两柱真实碰撞，猫挂点2.6米；贴图接actor_shadow113投影、10脚接地影，柱体原生投影。22项实机检查通过，含真实顶撞、南向走出/返回、地形遮挡射线、小屋与台阶。F8样板/F6入口/F7屋/F3院；独立forest182_preview.cfg，无正式解锁/新遭遇。详见docs/forest-valley182.md；原181/169保留，首次缓存约113秒。

- 最新入口样板181（2026-10-26）：preview_forest_dressing181.cmd / scenes/world/world181.tscn，完整地图沿用180地形。内置image_gen三件透明摆件：编织夜灯、举爪幽灵小猫、五片短彩旗（assets/forest181含完整prompt）。删除长紫弧带、隐藏圆柱灯外观，保留真实暖光；18级台阶复用park99._prism99/stone97，不增加硬坎；土路绕根岛通小屋，转弯/门前9薄石片，局部裁草。默认站在样板前，F8样板/F6上入口/F7小屋/F3院。17项Compatibility定向检查与实际往返通过；随后仅将旗/布偶/灯移到路旁较里侧，最终图forest181_sample_final.png单独核对。旧169/180及地形180不改，无正式三鹅解锁/新遭遇。细节docs/forest-dressing181.md；树淡出颗粒感仍待调。

- 180最终验证：23项Compatibility实机检查全通过，含实际小院—入口—台阶—森林—返回小院、三处小屋镜头投影与树shader fade参数。树卡目前沿用17颗粒式淡出，遮挡处有噪点，待后续视觉反馈；不是小屋拉伸。报告forest180-validation.json。

- 最新接入180（2026-10-26）：preview_forest_world180.cmd / scenes/world/world180.tscn，继承173完整大地图，用户授权实际接入。新surface180仅局部下沉森林，轮廓改为不等椭圆凹湾+西/北突出岩肩；旧大地图bedrock92手绘材质与岩面分割直接复用。小院按真实作坊碰撞铺小石子接入，三段台阶与根岛双路线保留。179右向小屋改为与相机画面平行的BILLBOARD_ENABLED以抑制左右移镜剪切；仍非全视角立体房屋。F6森林入口/F7小屋前/F3小院，独立forest180_preview.cfg；正式三鹅门禁与森林遭遇未接。完整往返检查已通过，最终含树shader淡出的报告见docs/forest180-validation.json；详见docs/forest-world180.md。普通169保留对照，初次/缓存启动约一分钟需等待。

- 最新地形179（2026-10-26）：preview_sunken_forest179.cmd / scenes/sandbox/sunken_forest179.tscn。用户纠正小屋朝向/平视并询问开始刷地形；已独立落第一轮：北侧保持原Y0.2、森林Y-2.2、岩石断面、入口三段短石阶（每段6级/0.8米落差）与平缓落脚段，东侧保留测试缓坡。旧树/苔岩/草地复用，冷色林荫；两段紫带独立网格占位。新小屋朝画面右侧/露左墙，增加俯视面，待用户判断；实际跟随相机查证为向下25°。F3小屋前/R入口/F1全景/F2明暗，仍无敌人/存档/正式三鹅解锁/小院连接。22项定向检查和Compatibility实机通过。169及177/178原入口保留。详见godot_world/docs/sunken-forest179.md；尚需主题主景树、灯具/布偶、岩体细化和小屋分层。

- 最新美术试摆178（2026-10-26）：preview_forest_cottage178.cmd / scenes/sandbox/forest_cottage178.tscn，从门前开始。内置image_gen生成透明侧向小屋，实机用整张竖直卡片试角度，保留灰盒碰撞、屋后淡出；屋顶/门廊尚未拆层/可进入室内未做，视觉宽6.7米与碰撞范围仍待造型反馈校准。11项检查与实机通过，177/169未改。用户新地形约定：森林下沉、北侧保留原地势、岩石断面；入口分段短台阶下降，不能整段大斜坡。该约定已记入docs/cottage178.md，177/178暂未刷正式地形。Suno完整提示词包docs/suno-music178-prompts.md含10优先/6备用/4短提示音；无实际音乐生成或接入。

- 最新地形试玩177（2026-10-26）：preview_forest_graybox177.cmd / scenes/sandbox/forest_graybox177.tscn。用户批准先搭灰盒；独立场景直接用西南勘察坐标(-48,0)，不实例化旧世界。27.59米两次转弯小径、28×24米低地、北侧+2.4米高台/东缓坡、中央树根双路线、西北坡脚小屋占位。WASD移动、Shift闪避、R入口、F1全景、F2明暗、滚轮缩放；三鹅仅尺度，无敌人/存档/正式3鹅解锁。21项物理行走等检查及实机验证通过；原4项关键文件与174哈希一致，普通默认169未变。待用户评价尺度与路线，再做氛围样板；详见godot_world/docs/forest-graybox177.md。

- 176合并场景图最新状态：再次重试已成功，art/scary_forest176_refinement/merged_lowland_forest.png及merged_scene_prompt.json；北侧高台、低地双路线、暗色树冠、淡紫装饰和暖灯，换为软布偶。此前网络失败记录已过时；待用户评价，未改地图。

- 森林美术方向（2026-10-26）：用户确认小院左侧／西南树林，正式名“很吓人的森林！”，至少3只小黑鹅解锁为设计前提。175三版概念见godot_world/art/scary_forest175_concepts；用户偏好C的低地与北侧高地层次+B的偏暗氛围、淡紫条带和暖灯。旧玩偶太凶，要求软乎乎“呜喵”想吓人却像撒娇；176三款布偶近景及提示词见art/scary_forest176_refinement，尚未选款。合并场景图三次网络错误未生成；正式地图/解锁未实施。

- 工作目录：D:/work/Agent/workplace/小白鹅大冒险。活跃项目为godot_world；godot_yard、godot_showcase及其他资源目录作为历史/参考，不把新逻辑写回旧项目。
- 当前默认：world169；场景godot_world/scenes/world/world169.tscn。最近改动是“每鹅各自放飞纸飞机”，已实现并开启试玩，等待用户反馈；没有已约定但尚未完成的下一项开发任务。
- 最新独立布局试场：`preview_forest_arena174.cmd` / scenes/sandbox/forest_arena174.tscn。用户授权先用地形验证网垫，明确不影响已搭场景；新增远离旧林地的独立测试节点、平地碰撞和导航，中央粗树干/右近路/左宽外圈/两块输出空地/南侧入口。沿用173蜘蛛、网垫与1—9装配，无新控制技能。F6单/三只 F7重开；174内禁旧旅行/F4F5切区，其他旧入口不变。20项定向检查通过，真实走通两路，原树木坐标/旧林地/默认169及关键原文件哈希不变。试玩不发材料或推进正式事件。待用户体验，细节godot_world/docs/forest-arena174.md。
- 最新独立试演：world173，`preview_web173.cmd`。用户批准网垫作为不可拆临时领地：从蜘蛛脚下展开，无中心毛线球/受击体/辅助选中；直径4.8米、完成后10秒、最多3块，移速降低45%且重叠不叠加，离开0.3秒恢复、冲刺与攻速不减。1.8秒织网/开心两跳保留，脚边新增短丝拉伸/淡出反馈。22项定向检查通过，已看实机图，待试玩。F6单/三只 F7重开 1—9组合 F4纸/F5团团。丝球弹反/完美闪避及PNG资源读取修复沿用172；普通默认169、172对照保留。森林地图/正式3鹅解锁/荡丝/爬树未做。详见godot_world/docs/web173.md。
- 171朝向/瞄准修订沿用：小跳按移动方向左右镜像，无新增背面图；丝球窄锥普通辅助，飞机地面标记/自动选敌不变。原13项定向检查保留。丝球永久驻留、成功闪避/弹反仍受丝线减益未采用；172仅加入独立限时网垫。
- 最直接试玩：[preview_goose_air_squad169.cmd](preview_goose_air_squad169.cmd)。标题必须是169。左键标记/持续放飞；1双机、2三机、3住校四机、4蓄力双机、5气球剑三机、6分裂双机、7火车四机、8快射双机、9本体单机；F4纸怪、F5团团；Q按组合翻课堂笔记。
- 普通探索：play.cmd，默认场景也是169。tools/play.ps1若发现旧的managed预览，会复用旧窗口而不重启；不要因此误认新代码已生效。版本专用cmd不受这个判断影响。不要批量结束用户的Godot进程。
- 引擎GUI：D:/work/Agent/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64.exe；命令行/检查用同目录Godot_v4.7.2-stable_win64_console.exe。Compatibility渲染、Jolt物理，保留现有后端。
- 工作树有大量既有修改和未跟踪文件，包括旧项目；不要清理、reset、覆盖或提交整棵树。先辨认本次任务范围。

## 2. 已确定的设计与数值

| 系统 | 当前行为 |
|---|---|
| 鹅队168 | 森林冰火人+1只/1格，三人小游戏+2只/2格，住校+3只/3格。额外鹅40%伤害，本体100%，无旧减伤/射速惩罚。射速、射程、弹幕形态继承；可叠加，总容量4格。 |
| 队形 | 用户明确要贪吃蛇式开火车，而非左右夹击阵型；住校后在主鹅旁团聚。路径间隔0.72米，约8米/最多256样点；暂停冻结，超过5米瞬移重建。鹅和投影建池复用。 |
| 飞机169 | 每鹅从自己枪口放一架，只带自己的载荷；按来源拆包不复制整队预算。六连投节奏和放飞间隔受射速影响。当前各鹅射速相同，没有不同鹅独立射速成长系统。无“三架上限”；最早“三架”说的是初始频率。 |
| 飞机+笔记 | 笔记按攻击轮次记录，保留最近3轮；Q准备0.65秒、移动降至45%，闪避中止保留记录；重现45%载荷。重现也各鹅一机，不递归记录。 |
| 小零食166 | 仅分裂子弹短程抛物线，向上初速2.6、重力14，按出生高度折算约1.65米水平距离，覆盖命中点附近约两米；不追踪。原弹不加重力，保留半伤和二次分裂。167补独立落地投影。 |
| 课间操167 | 闪避时标记、无即时扣血；闪避结束后0.10/0.25/0.40秒三拍真实伤害，合计标记时弹药基础伤害20%，约0.8秒彩带星芒残留。每闪避每目标一次，死亡/清场取消，短顿每dash ID一次。 |
| 小窝160最新修订 | 静止右键蹲防0.45秒搭建；开口内完全免伤，存在3秒，消失后CD10秒。离开/闪避不拆窝，可返回，计时不刷新。最后0.6秒松塌预警。没有耐久；早期30耐久、70%减伤、6秒、12/18秒CD均已过时。 |
| 主角时刻164/165 | Q在开启位置展开固定半径6.5米区域，存在7秒，圈内伤害+30%/射速+100%，结束后20秒CD，可离开再返回、不续时。165以立体书景片和柔边蜜桃膜/纸页边饰标范围，取消连续发光圆圈。不改变真实昼夜；不是跟着角色走的光环。 |
| 主动装配 | Q一次一个主动；主角时刻与课堂笔记互斥。两者是候选，不要无意让Q同时触发两套。 |
| 气球剑158/159 | 用户选A形，蓝色胶质剑头黏附，程序压缩回弹。每层减速8%，最多5层/40%，独立3秒；不减已发动扑击的速度；伤害预算×75%仅一次。 |

童年阶段可以轻松、可爱，先验证记忆碎片组合和收集乐趣；不要求每只怪都高压。纸怪随风轻飘、团团怪呆萌。用户偏好小步实机试玩，不要未经当前任务需要就扩完整背包/图鉴/配方系统、Boss或地图。

## 3. 最有用的代码入口

文件均相对godot_world：

| 位置 | 作用 |
|---|---|
| scripts/world/woodland_world169.gd | 最新试装、每鹅飞机预设、来源射速/角差快照、manager注入。 |
| scripts/combat/paper_squad169.gd | 按goose_source168拆成每鹅一机，出生枪口、单机载荷、射速快照。继承paper_float162→paper_scatter152→paper_coverage151→paper_flyby150→paper_memories146。 |
| scripts/world/woodland_world168.gd | 鹅来源标记、40%伤害、载荷/光束/接触伤害预算，数学作用域去旧惩罚。 |
| scripts/combat/battle_skills168.gd、goose168.gd | 路径采样、团聚、节点池、跟随。 |
| scripts/combat/cards168.gd、buff_book168.gd、memory_kit168.gd | 当前卡表/数值/槽位/存档。169沿用168，不要改到旧cards110就以为生效。 |
| scripts/world/woodland_world166.gd、167.gd | 糖屑重力分流、独立糖屑影批次。普通弹仍用native/combat113。 |
| scripts/combat/battle_skills167.gd | 闪后延迟伤害与标记；168继承它，功能保留。 |
| scripts/combat/popup_stage165.gd、fixed_stage164.gd | 立体书景片/遮挡淡出、区域判定与增益。 |
| scripts/combat/hero_moment161.gd、pillow_hut160.gd | 主角时刻计时与小窝；文件数字旧，不代表当前数值旧。 |
| scripts/combat/float_follow162.gd、paper_float162.gd | 阻尼悬浮、笔记本平滑切换锚点。 |
| scripts/combat/world_effects159.gd | 新3D弹幕/摆件挂combat_effect_root159自动昼夜染色；自定义shader复用world_effect_grade159.gdshaderinc，特殊自发光可显式豁免。 |

版本继承链很长；先跟最新world的注入方法查真正运行的脚本，避免只改到被覆盖的同名方法。保留旧预览便于对照；除非新任务要求，不为了“整洁”立即重构全部版本链。

## 4. 容易踩的坑与未完成项

- 额外鹅40%是伤害预算，不是全部属性×0.4。气球剑减速等控制附带效果目前仍沿旧规则，多鹅会更快叠控制，尚未完成平衡。不要宣称已解决。
- 固定载荷fixed_damage110已包含伤害倍率，分裂/飞机/笔记/剑重发时不能再次乘鹅倍率、舞台倍率或剑预算。副鹅光束的来源看stream_lane，不能只看emitter110。
- buff_book168.math_scope168只是同步抑制旧forest_fireboy/three_player的数学惩罚；嵌套结束必须归零，不要为去惩罚直接删真实装备等级，否则鹅数量/装配/存档会错。
- 169来源射速是发射时快照，当前统一继承。没有为每只鹅新增可单独升级的射速或独立冷却系统，不要把元数据误读成已有该功能。
- 飞机随机九发模式已有试玩失败反馈，默认辅助六发，F8保留对照；不要无意恢复默认九发。没有飞机硬数量上限。
- 试演F4/F5保留装配、不发材料、不推进事件。正常材料/笔记本已有基础实现，不要把历史“完整系统未做”误读成完全没有任何装配。
- 当前存档user://goose_train168.cfg；逐级迁移167/166/164/161等，不修改旧存档。Godot实际user目录以OS.get_user_data_dir为准，不猜目录或删用户数据。
- 当前试装卡（包括住校）免费开放供验证，正式配方未定；不要擅自收费、发放正式进度或把试验值当最终设计。
- 地图过去137/138曾因改地面裁切/山体/台阶出现严重回归，后来恢复。当前任务不涉及地图时不要顺手动地形、树摆放、楼梯或远海。资料在对应版本专项文档。
- 跟随曾抖动：用显示插值位置+渲染帧阻尼，别恢复每帧硬贴位置或屏幕锚点整像素跳格。暂停应冻结，瞬移/清场应重置惯性。
- 大量Godot数值原型仍待用户试玩；测试通过不等于强度或手感定版。下一步优先处理169试玩反馈。

## 5. 验证方式与证据

用户明确希望精简：只做与当前改动相关的编译、机制探针和必要实机检查。旧交接“每次改动必跑全套”是历史规则，不适用于现在；纯文档无需启动游戏。没有改地图就不重跑旧地图大套件。

- 169：goose-air-squad169-validation.json，27项通过；探针scripts/world/goose_air_squad169_probe.gd。
- 168：goose-train168-validation.json，36项通过；探针scripts/world/goose_train168_probe.gd。
- 167：delayed-dance167-validation.json 15项，dance-stop167-validation.json 5项，均通过。
- 165：popup-stage165-validation.json，15项通过。其他模块按需查各专项文档，不自动重跑。
- 证据位于godot_world/docs，对应.log及captures/world_restart/截图。最新三机起飞/住校四机已看过。不要因一张静态图就宣称运动手感已被充分验证。

PowerShell示例，从工作目录运行（引擎console路径使用上文完整绝对路径）：

```powershell
& 'D:/work/Agent/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe' --headless --path godot_world --check-only --script res://scripts/world/woodland_world169.gd
& 'D:/work/Agent/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe' --path godot_world --script res://scripts/world/goose_air_squad169_probe.gd
```

编译有时exit code仍为0，必须看输出是否含Parse/Compile Error。渲染探针不要用headless，场景启动约30—40秒，不要误以为卡死。不要在测试hurt_player的机制时用“无敌override”绕过真实流程。输入探针按下/松开之间需让process_frame推进；手动改位置后测试显示插值也需给渲染帧更新。

## 6. 美术与后续维护

新增需要匹配可爱像素/绘本风格，透明资源保留alpha、原图和提示词。立体书资源及内置image_gen提示词在godot_world/assets/popup_stage165/PROVENANCE.md，小窝在assets/pillow_hut160/PROVENANCE.md；其他资源按专项文档找。先确认当前选中素材，别把早期被否定的剑或纸怪替回去。

每次完成实质改动后，更新本页受影响的当前事实及CURRENT_STATE顶部；专项文档记录细节。本页保持短且去过时信息，CURRENT_STATE保留历史，不要把两者都继续堆成流水账。
# 2026-10-26 — 188 south-moved forest prototype

- New isolated preview: `godot_world/scenes/world/world188.tscn` and
  `godot_world/preview_forest_move188.cmd`; default remains `world169.tscn`.
- Forest center is now `(-48,24)`. Only the south map edge expands (+30 m);
  old site terrain matches `world_surface142` again.
- Important migration fix: world19 built an invisible south perimeter before
  the derived surface replacement. 188 moves that wall from z=18.383 to the
  new south edge and lengthens both side walls.
- Cliff cleanup is slope-aware: no grass/trees/plants/rocks on the relocated
  rock faces in the validation sample.
- 187 pseudo-pixel shader removed. New actual source redraws live in
  `godot_world/assets/forest188/` (craft corner, supported nightlight, lilac
  ground tuft). Built-in imagegen prompts are summarized in that folder.
- Branch lamps no longer recompute anchors each frame. Hero card ignores local
  3D OmniLight shading; forest post-grade integrates it gently instead.
- `forest188_capture.gd` passes 14/14 real-map checks and walks the inner route.
- Still pending: >=3 black-goose unlock logic, forest combat, spider sister,
  and a final user visual decision on the three new prop redraws.

# 189 — purple forest approach and hammock cat

- Latest preview: `godot_world/scenes/world/world189.tscn`; launcher
  `godot_world/preview_forest_mood189.cmd`. F11 = actual approach path middle.
- New art subclass `forest_art189.gd` adds contact bending/recovery to all
  eleven lilac tufts and a new ghost-kitten sprite in the central tree hammock.
- `forest_mood189.gd` uploads the actual `connection188` polyline for the full
  gradual approach; darker purple grade, amber protection excludes green
  leaves, courtyard exclusion retained.
- Details: `godot_world/docs/forest-mood189.md`. Source cat and complete prompt:
  `godot_world/assets/forest189/` (built-in imagegen).

# Fixed launch entry — 2026-10-27

Use root `00_开始游戏.cmd`: Enter/1 = latest development preview (currently 189),
2 = main 169, 3 = spider 173, 4 = history directory. Its single version table
lives in `tools/launch-game.ps1`. For future preview versions, update that table
instead of adding another root preview launcher. `-Mode list` validates targets
without launching the game.

94 older `preview_*.cmd` launchers moved from root / godot_world into
`tools/preview_history`; their relative paths were updated and checked. No game
scenes, assets or saves removed. Historical docs' old preview paths now refer
to the same basenames in that folder. `play.cmd` retains its existing meaning.

