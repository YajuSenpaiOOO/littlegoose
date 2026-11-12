# 265 睡姿与软垫：生成记录

工具：内置 image_gen，透明alpha输出，无CLI/API备用。图片生成后直接复制原文件到本目录，没有用代码绘画或缩小图像冒充像素画。layout.json仅记录原PNG哈希、原始alpha边界及游戏alpha_scissor=.5对应的可见边界/脚锚点，不改变PNG。

用户修订：最初睡姿保留两块红色区域，被用户明确拒绝；红色是眼白，闭眼不应该露出。最终sleep.png使用第二版：去红块、小睡眼、更圆润的身体、收小的白毛。醒来仍使用原idle_front_v1.png。被拒稿留在工具原输出目录，不在游戏引用。

## 最终睡姿提示词（内置工具）

Use case: identity-preserve, precise sleeping-pose revision for a transparent pixel-art game sprite. Image 1 is the REJECTED sleep pose to correct. Image 2 shows original character identity. User correction is essential: the large coral-red areas in the original are the EYE WHITES, not eyelids or cheek patches. When sleeping, the eyelids are mint-colored like the body, so BOTH LARGE RED AREAS MUST DISAPPEAR COMPLETELY. No red circles, no red eye patches, no pink eyelid masses. Draw two small gentle closed sleepy curved eyes directly on the mint face, widely spaced but not huge, with a tiny relaxed cute mouth. Make the creature noticeably CUTER, softer and rounder: a plump horizontal oval body gently sprawled on its belly, comfortably flattened rather than melted into a puddle. The small white tousled hair cap is only roughly the top fifth of the silhouette; reduce the enormous explosive tuft from image 1. Retain mint/aqua body, dark plum chunky pixel outline, clean limited blocky pixel shading, native low-resolution game sprite style. NO hands, arms, legs, feet, tail, ears, flower, accessory, cushion, scene or new creature anatomy. Tiny closed eyes and softly tucked rounded outline give a peaceful sweet sleeping expression; avoid a smug grin or angry eyebrows. One complete creature centered, generous transparent margins, fully transparent alpha background. No letters or Zzz, no painted shadow or ground. Preserve species while making the sleeping expression charming.

参考：被拒睡姿exec-c23be079-2452-4fa5-b458-df66d2d15478.png和项目assets/tuantuan_v2/idle_front_v1.png。
最终原输出：C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/exec-b1cd067c-129c-4d52-8e10-fd27f612fd34.png。

## 软垫提示词（内置工具）

Use case: stylized-concept. Asset type: one isolated transparent pixel-art prop for a cozy 2.5D forest game. A broad low SOFT FLOOR CUSHION for a sleepy round mint creature to lie on. Muted dusty mauve/lavender cloth, warm cream piping and simple large quilt seams, two tiny rose-colored fabric patches, gently puffy rounded rectangular/oval footprint. Viewed from the final game camera slightly above the front, 25 degrees down: clearly show the broad top plane plus a thin soft front side. Low horizontal shape, approximate silhouette width to height 2.7:1, top surface spacious and uncluttered. Deliberate chunky low-resolution pixel clusters, dark plum pixel outline, restrained 3-tone shading, warm gentle storybook palette matching a cute mint blob creature. Not a realistic photo, not high-detail painting, not a hard sofa, no legs, no backrest, no tufted luxury upholstery, no grass/flowers/ground/background, no creature, no text. Complete single cushion centered with clear transparent margins and real transparent alpha. No cast shadow painted outside the cushion; the game adds contact shadow separately.

最终原输出：C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/exec-d3f0647c-856f-4471-be67-c4ac493c5c65.png。

## 接入信息

- sleep.png：1355×1160；.5alpha可见框(137,405)—(1235,966)，脚锚点(686,965)。可见宽3.4m，保持原团团竖直角色平面和旧soft_body32调色路径，休息时弱呼吸，不给主角改几何。身体站在软垫上方.24m，醒来换回原idle。无单独自发光/无灯位。
- cushion.png：2057×764；可见框(38,69)—(2019,714)，前沿脚点(1028.5,713)。可见宽4.2m，明确相机朝向Sprite3D，画面已包含25度顶面，不再倾斜贴图。位置为休息脚点后方.35m、地高+.025，防止相机朝向卡片前挡住角色。使用原生shaded、不发光、不增加灯具。
- 实体占地：软布垫明确可穿过，无碰撞。大团团休息时使用独立圆柱脚下占地radius .85m/height .45m，位置y=.225；不按整张插画轮廓推体积。挑战开始重建原Boss胶囊，不把休息碰撞迁移进战斗。
- 影子：两者各接共用actor silhouette；无原生卡片投影；Boss旧椭圆隐藏。休息姿态继续用原visual，投影跟实际睡姿贴图，而不是旧醒姿。树/灌木保留原遮挡，可挡局部边缘，未静态清树或移除碰撞。
- 已看同镜头睡/醒、昼/夜、前后遮挡，实测两侧真实身体顶撞。休息点经静态净空、平坦度、同层高度与导航路径检查，当前在山脚林边，距战斗中心约7.1m；无需在普通战中穿过NPC。复杂全地图树遮挡仍为既有问题。
