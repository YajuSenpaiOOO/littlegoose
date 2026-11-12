# 315 标准站姿比例候选

来源为内置 imagegen，主角 walk_source 中央正面、314 等高对照和 295 旧站姿为参考。目标是修正头脸与身体的关系，保持栗色短发、绿眼、蓝黄发夹及折纸书身份。

原始 PNG 保存为 idle_front.png，未程序拉伸、修绘或降采样。输出来源 exec-0a7c5585-566f-41b2-8154-23b70530fb6f.png。透明底、竖直显示候选，尺寸 1086×1448，alpha≥128 边界 [112,105,972,1374)，脚点 (542,1374)。目前只生成标准稿和等高对照，尚未替换 314 动作帧。

## 完整提示词

Redraw ONE standard front idle gameplay sprite of the brown-haired paper girl. IMAGE 1 is the heroine gameplay sheet: use ONLY its center FRONT IDLE as the absolute body proportion master. IMAGE 2 is an equal-height comparison: LEFTMOST white heroine is the target proportion, brown girl on the FAR RIGHT is the overly narrow long version to correct. IMAGE 3 is the brown girl's identity and costume. At equal overall height, redraw the brown girl with the heroine's broad rounded head, broad actual skin face and wide eye spacing; compact short neck, very short torso, compact skirt and short legs. Match the heroine's compact big-head gameplay silhouette, not a slender doll. Broaden the face and shoulders and shorten the chin-to-hem span relative to head. Keep brown fluffy bob, short curled forelock, blue and yellow page-tab clips, green eyes, cream blouse, muted sage apron dress and brown short boots. Both hands comfortably hold a SMALL closed craft book against belly, cream crane emblem on its cover; fit the book to the compact body. Calm slightly determined closed smile. Coherent freshly drawn pixel clusters, chunky brown stepped outlines, restrained broad color blocks, same detail density as heroine. One centered full-body standing figure, feet level, generous transparent margins. Genuine transparent background, no shadows, glow, lettering, scene, extra characters or layout. Preserve identity, but take anatomical proportions from the WHITE heroine, not from the brown references. Do not simply scale the brown girl.

## 像素颗粒候选

用户认可315比例，要求关注与主角的像素颗粒一致性。新增idle_pixel_v2.png和idle_pixel_v3.png，均内置imagegen以主角walk_source中央正面与315标准姿势为参考直接重画，保留原PNG，无程序降采样。v2以约100逻辑像素高的粗块画法试稿，目视比主角过粗；v3细化至约180逻辑像素高的画法，同时保留315比例。生成分辨率不等于真实逻辑网格，仍以等高对照和游戏尺寸判断。

v2来源exec-db819613-ed3f-4d76-8c0e-54df9c671147.png。v3来源exec-d19b4740-54dd-4960-846c-98f36ee8098c.png，1086×1448，alpha≥128边界[132,102,950,1375)，脚点(541,1375)，有效高1273。尚未接入运行帧。整套动作需统一头身、笔触、足点和手中道具锚点。
