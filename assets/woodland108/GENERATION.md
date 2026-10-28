# 原木108的绘本材质

2026-10-21。内置 image_gen 生成，参照 ../park99/swing_oak99.png 的树干笔触。最终 painted_log108.png 为2:1双格原始PNG，左格树皮、右格简化年轮。保留原像素，无像素重绘；Godot shader按格采样，真实网格控制弯曲、凹凸及两端面，原实体碰撞保留。

第一张碎片树皮被用户指出太写实，未复制到项目、未接入游戏。本项目只使用第二张宽纹理版本。

完整最终提示词：

The input image is STYLE REFERENCE ONLY. Match the broad smooth flowing brown trunk paint in this fairy tale oak exactly. Create a game texture sheet, TWO equal square panels side by side, 2:1 landscape. Left: simplified painted trunk surface with long flowing VERTICAL wide wavy brown forms like the reference trunk, soft honey light and olive-brown shade, one or two small simple oval knots, very sparse soft sage moss dabs. Right: simplified circular cut end of a log, pale muted tan, just FIVE OR SIX uneven soft oval concentric rings and ONE short broad crack, slim dark bark outline; fully frontal round disc centered on uniform brown. This is a PAINTED CARTOON game material with large soft color masses, not real bark. Only 5 to 7 principal color values. Reference flowing wide rounded trunk forms, NOT shaggy bark flakes. ZERO tiny marks, ZERO flakes or chips, ZERO wood pores, ZERO photo surface detail, ZERO coarse stone-like bark, ZERO micro brush hatching, no dramatic lighting, no baked shadow, no text, no tree, no scene, no 3D object. Low-frequency hand-painted texture, suitable for viewing small in a cozy illustrated game.
