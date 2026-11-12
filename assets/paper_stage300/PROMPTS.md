# 300 · 城楼动作与正门出场

内置 image_gen 生成4张原始透明PNG，复制到本目录，无程序修绘或降采样。lean/fold/command以paper_girl295/idle_front.png为角色身份、hero_pixel/walk_source.png为游戏像素与比例参考。castle以paper_stage297/castle.png为造型参考、paper_stage299/operator_dinosaur_v2.png仅为门洞净高参考，不把操纵者画进城堡。

来源目录：C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/
- lean: exec-8b44a343-1b5f-4b78-8cf5-64d94a610f4d.png
- fold: exec-a82c6141-1aee-4346-9e11-fe805e0cb39c.png
- command: exec-f6f9e455-0453-4ccd-bc5c-7e872f305333.png
- castle: exec-dc5353a2-2818-488a-8b4b-feddd6727c57.png

尺寸、alpha128边界、脚点、SHA256见layout.json。三姿势按有效高1.6m与脚点定标，没有分别修改头部。生成command的领口多出金蝴蝶结、部分服饰有细微差异，不宣称逐像素完全一致。

## 接入与验证

paper_stage300继承299。城堡宽12m，大拱门约4.2m宽；左右门叶与独立门碰撞同步扩大。纸怪抱杆组保持299原尺寸，中央(.8,-1.3)→(1.1,4)路线，门打开后才显现、迈出，清门后关门；撤销299绕侧边路径。它仍是无伤害演出曲线，不是正式AI导航或CharacterBody碰撞移动。

妹妹在落景遮挡期间(.95–1.65秒)切换到固定左侧城楼小台，没有横向滑行；这是遮挡切位，不是走楼梯动画。小台及支脚真实网格，单独碰撞，墙沿负责遮住下半身；手势、脸和小折纸露在城垛上方。三张关键帧依次为扒城垛探头、低头折小恐龙、抬手指挥。开场后5.4秒循环探头/折纸/指挥。当前远镜头妹妹较小，动作可读性仍待用户实玩确认，尚无连续手指折纸动画。

Compatibility实机验证31项全过（docs/paper300-validation.json），含开关门实体射线、中央路径位置、三帧选取/有效身高、重播/退出控制恢复与开场后循环。检查了六张运行截图，恐龙从门洞经过，未见脑袋切门框；妹妹处于城垛后，上半身露出。无新script/shader错误，旧relay_flag245警告仍在。无Boss伤害/血量/正式进度/奖励，未改团团和手电战斗。


## lean 完整提示词

Use case: identity-preserve gameplay sprite animation keyframe. IMAGE1 paper girl is strict identity and wide-head/face/proportion master. IMAGE2 heroine center front idle is strict pixel-style/proportion comparison. Create ONE full-body front LEANING-ON-BATTLEMENT pose of SAME paper girl, genuine transparent background. Preserve exact head size, broad rounded cheeks, large green eyes, chestnut fluffy short bob/crown curl, blue-yellow hair tabs, sage apron/cream blouse/taupe skirt/brown boots. Same compact approximately2-head body, same chunky pixel blocks/outline thickness, no new fine detail. Both very short arms reach slightly FORWARD, elbows bent, hands relaxed at a common horizontal support line just below chest, as if resting fingertips over a castle parapet. She leans her upper body slightly forward, looking down toward player with cheeky proud pleased smile; no long arms, no perspective-distorted giant hands. CRITICAL: draw character ONLY; no castle/wall/ledge/book prop in image. Hands visibly open and resting on imaginary ledge, five simplified fingers, natural connected shoulders/elbows. Lower body/boots retained fully for anchoring but will be hidden behind real game battlement. Keep same source crown-to-chin size and foot baseline as IMAGE1, generous alpha margins and full feet. Fixed front game view, no turns or walking. No glow/background/floor/shadow/text/sheet/extra character. One animation keyframe, not illustrated portrait.

## fold 完整提示词

Use case: identity-preserve pixel-game animation keyframe. Image1 paper girl gameplay sprite is STRICT character identity/wide head and face/body master; image2 heroine center idle is compact pixel style comparison. ONE full-body front FOLDING PAPER pose. SAME chestnut short fluffy bob/crown curl, blue-yellow page-tab clips, broad warm face, large green eyes, sage apron over cream blouse/taupe skirt/brown short boots. Do not change head width/size or lengthen torso/arms. She tips head/chin down SLIGHTLY, eyes looking down with determined concentrated yet cute expression, tiny pursed mouth. Both short naturally connected arms bent in front of waist/chest, hands visibly pinching/folding one SMALL cream-and-mint sheet into a simple half-finished paper dinosaur. Fingers simplified, natural wrists, no extra hands. No large held book, no table/ledge/castle drawn. The paper can be held just above an imaginary parapet below chest. Whole figure with lower skirt and feet preserved for anchoring, same crown-to-chin scale and foot baseline as reference. Chunky authentic pixel clusters, muted plum contour and simple stepped shading matching heroine and girl, no fine portrait painting/vector. Genuine transparent background, generous margins, no ground/shadow/glow/text/panels/other character. One keyframe only.

## command 完整提示词

Use case: identity-preserve pixel-game animation keyframe. Image1 paper girl is strict identity/head-width/face/body proportion master, Image2 heroine center front idle is compact pixel-style guide. ONE full-body front COMMANDING / SIGNAL TO OPEN GATE pose of SAME girl. Preserve large broad round head/face, chestnut short fluffy hair/crown curl, blue-yellow page clips, green eyes, cream blouse/sage apron/taupe skirt/brown short boots. Same coarse pixel clusters, muted plum outline and short body as reference, do not change head size or extend arms/legs. Her viewer-right arm is raised with elbow naturally bent, open hand lifted just beside temple/upper cheek level, a small assertive 'go!' gesture; viewer-left short arm rests forward at an imaginary parapet below chest. Natural connected shoulder, elbow and five simplified fingers, no elongated hand/forearm. Face eyes looking forward/down toward troops, tiny enthusiastic open smile, proud and cheeky not angry/evil. No book, paper prop, wall, castle or ledge in image; environment will be real game layer. Whole lower body and feet retained, same foot baseline and crown framing as source, fixed front game view, no turn. Genuine transparent background, full figure generous margins, no glow/shadow/floor/text/sheet/extra people. ONE keyframe only, not a portrait painting or smooth vector.

## castle 完整提示词

Use case: precise-object-edit of a production 2.5D pixel cardboard castle backdrop. IMAGE1 is castle to edit. IMAGE2 is the tall paper-monster carrying dinosaur puppet, SIZE/doorway-clearance reference only, do not include operator/dino in output. Preserve castle's thin hand-cut paper identity, cream/kraft/terracotta/sage palette, yellow/blue flags, chunky pixel clusters and plum/brown outline, broad three-tower silhouette, small folded support tabs. Change CENTRAL OPEN ARCHWAY into a substantially taller and wider entrance suitable for the whole tall puppet: doorway clear width about42percent of castle full width and clear height about70percent of castle visible height, rounded arch top, flat open bottom. Raise/rearrange central wall/top tower slightly as needed so a believable continuous cardboard arch/frame remains around opening, no disconnected floating wall pieces. Keep towers at outer sides; central entry is dominant. Doorway is genuinely transparent all the way through, not painted black; no door leaves included because these are separate animated game components. On viewer LEFT between tower and central arch, retain one broad low battlement ledge/top edge where girl can lean, no character drawn. Slightly wonky paper seams/tape corners and fold lines, flat stage facade not real stone building. Frontal fixed game camera25deg hints of thin edges only. Full facade flags/support feet all visible in generous transparent margins; do not crop top or bottom. No floor/book/ground/shadow/background/glow/text/characters/dinosaur/extra props/sheet. ONE enlarged-entry castle flat only.
