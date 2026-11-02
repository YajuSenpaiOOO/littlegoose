# 肥猫215 · 原版西南向六帧移动草稿

用户明确选择原始矮宽肥猫 exec-da711545-8670-46c2-b16f-ee75b0cae223.png，不采用214补丁/布标或骑乘合图。内置imagegen以原图为参考生成六帧，原图与合图原样保留。此处独立Godot二维预览，不是游戏场景或四向资源接入。未改godot_world、主角、地图或统一启动入口。

展示：固定西南向，六帧按行排列；透明有效区域阈值0.6读取后仅记录裁区与顶部中心锚，运行时Atlas区域取样，不编辑合图。原稿身体有轻微跨帧形变，动画节奏与相似度待用户观看；不能当成像素级锁形完成。alpha阈值丢弃生成低透明晕边，不重新画材质。近远脚目前依赖整张帧图，不是已经拆好的独立骨骼。

独立2D预览无世界占地、碰撞、真实灯光、地形投影或骑乘。正式接入时仍须依据2.5D规范另行配置。空格暂停，左右逐帧，减号/等号调速，Tab切换小图移动。默认14帧/秒；小尺寸位移慢于腿部节奏。原版保留作并排对照。

## 完整生成提示词

Create a WALK CYCLE SPRITE SHEET of the EXACT ORIGINAL cat in reference. Identity-preserve strictly: same LOW WIDE fat cream/apricot/lilac calico plush cat, SAME broad body silhouette, tiny bean eyes and omega mouth, pretending fierce brow stitches, cheeks, ears, tail, existing small side stitch ONLY, same southwest-facing three-quarter slightly overhead 25 degree view, same chunky micro-pixel shapes. NO redesign, new patches/tags/collar, rider, accessories or camera rotation. Sheet layout EXACTLY THREE COLUMNS by TWO ROWS, SIX equally sized rectangular cells, row-major chronological frames 1..6, no labels or grid lines. Each cell contains ONE entire cat at IDENTICAL size, horizontal body center, foot baseline and framing. All six images with clear generous transparent gutters so none touch another. Head, face, body markings and upper back registered identically across all frames; body only bobs 1-2 source pixels, never stretches/morphs. Animate THE FOUR VERY SHORT STUB LEGS doing a fast determined little scurry: alternate diagonally paired legs, wide grounded forward contact -> short backward push -> lift with rounded toe curled slightly -> switch pair -> backward push -> lift -> seamless return to first frame. Near front foot and near rear foot visibly swing in OPPOSITE phases, alternate broad forward and backward tilt with very small travel under belly. Far-side feet follow opposite phase when visible. Keep all feet short with naturally connected roots and rounded ends, no long legs, no fingers/claws, no detached beads. Clear differences between frames in foot placement, no six identical idle cats. Cute contrast of frantic short feet under a heavy largely steady body; not jumping, not bouncing whole body. Tail subtly follows weight only. Transparent background, NO purple glow/aura (reference aura should be omitted), NO shadow/floor, no motion blur, no motion marks, no text, no extra cats outside the six cells. Consistent simple pixel art throughout, no fine textures or 3D. Use landscape canvas fitting 3 by 2 sheet.

## 验证

独立Godot导入与Compatibility运行无Parse/Compile错误；运行捕获全部6帧（preview-check.json），查看第1/4帧截图确认原图对照、配准、透明晕边阈值和缩小显示。未以截图宣称运动观感验收；14fps节奏、腿部幅度与残留跨帧形变待用户观看。
