# 猪猪219 · 双鼻孔棉絮试演资源

内置imagegen生成cotton.png三类棉絮，并以218纯粉红猪三态为参考去掉示意喷流得到poses.png。均保留生成alpha与原文件，无程序重绘/改色。layout.json记录按alpha>=.6读得的裁区与脚锚；第三碎絮仅视觉。

## 角色接入

固定相机basis卡片，不额外倾斜；宽1.6m、pixel_size=1.6/656，三姿势均同尺度。帧内脚锚为alpha区域宽*.46、高*.98，圆脚占地与贴图轮廓分离。AnimatableBody3D半径.4m高.45m，接触不伤人，退场关闭占地。复用207真实受光/199脚点深度和105贴地轮廓影（.45倍），不投原生长影，不新增灯/柱体影子。纯粉红材质，非自发光。

喷射姿势内鼻孔坐标(138,280)/(189,284)相对裁区，发射世界位置由实际显示basis/pixel_size计算。当前固定西南方向，不是四向瞄准，也未接辅助瞄准/正式武器伤害。E为临时近身拍瘪用于测试主动打断。首次.9s地面预告，喷4.2s，软瘪1.5s后消失；独立试演退场2秒后自动重播，F5/F7也可重播。

## 棉絮接入

三组MultiMesh共用QuadMesh+着色器，纹理UV裁区；每片只有固定池记录，无敌人节点、碰撞体、血条、阴影节点。危险类型0/1正常最多16团，额外纯视觉碎絮类型2最多32片；三倍压力上限48+96。尺寸约.34m与.10m，危险命中半径.19m，世界深度遮挡、真实外照法线对齐hero192，无自发光、无独立投影（微小短寿命棉絮设计选择）。大棉团2.5m/s起速、指数减速、1.8s寿命；碎絮.85s。危险团做主角线段扫掠命中与场景射线/地形截断，碎絮不碰撞。主角闪避/防御/弹反复用现有状态，.7s试演受击门控，仅扣219心心，不改正式HP/进度/奖励。拍瘪猪后已喷棉团仍自然飞行消失。

资源验证与性能数据见docs/pig219-validation.json；同森林单猪对照不等于完整Boss+主角武器同时性能验收。最新入口按统一表更新，旧216/212保留。

## cotton219 完整提示词

Create a small GAME VFX sprite sheet of THREE separate white cotton tufts for a cozy micro-pixel woodland game. EXACTLY one row three equal square cells, one isolated cotton sprite centered in each cell with generous fully transparent margins. Left: chunky round irregular 5-lobed cotton clump, clearly readable solid bright warm-white core, pale lilac underside shading, subtle muted plum pixel edge but no heavy dark border. Middle: slightly elongated loose cotton tuft with 3 chunky irregular lobes, warm white and pale lavender, NOT liquid, rope, feather or cloud of smoke. Right: a smaller ragged scrap of cotton, sparse but connected pixel clusters, less visually heavy. All deliberate crisp chunky square pixel clusters, broad simple 2-3 tone shading, no realistic fibers, soft blur or glow. Each sprite stands alone, no motion trail, no background, floor, shadow, text, pig or other objects. True transparent alpha outside tufts. Purpose: independent world-space cotton projectiles and small harmless flakes. Keep every tuft complete within its own cell.

## pig219 完整提示词

Precise background-extraction/object removal edit of the provided three-pose SOLID PINK pig plush sheet. Remove ONLY the TWO WHITE COTTON STREAMS from middle pig nose and surrounding foreground, replace their entire area with real transparent background. Preserve all three pig drawings exactly, including the middle pig's compressed cheeks, thrust-forward snout and two nostril holes, body shape, short integrated feet, pure pink fabric shades, existing tiny seam, ears, tail, eyes, pixel detail and positions. Keep the SAME three equal cells in single row composition. Do not restore calico patches, cream mask or colored socks; pig stays pure pink. No new effects, glow, shadows, background or text. The middle pig is in FORCEFUL OUTWARD EXHALE pose but emits nothing in this sprite because the game will generate two separate streams from nostril attachment points. Keep all three whole uncut pigs with clean alpha.
