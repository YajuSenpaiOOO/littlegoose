# 127：原形轻怒眼与互拱飙汁

2026-10-23。用户确认在126最小变形候选上加入轻怒眼神，并要求互拱复用飙汁效果。

- 新图`assets/tuantuan_v2/shove127_annoyed.png`保留身体、毛团、瞳孔和小噘嘴，只压低眼睛上沿。按alpha≥0.5可见轮廓标定脚点与尺寸，同名json保存结果。用于实际互拱，两侧共用并朝对方翻转。
- 每次近距离互拱伤害节拍调用原有`jelly_fx.burst`，带原果冻飞溅/落地残留/接地影/昼夜处理及较轻接触音；不调用玩家命中回调，不增加连击/击败/掉落。
- 每对团团共享0.24秒特效冷却，避免双方同一拍重复喷汁。继续使用现有全局粒子容量，暂停/离场不触发。互拱微伤、不致死、多人重新选目标均沿用。
- 保留125自由攻击、6位开场/最多8位/全场15位，以及124渐隐。

本轮只做7项针对验证：新表情加载、同拍去重、非逐帧触发、不加玩家反馈、暂停、距离、下次真实顶撞再触发；另拍一张实机图核对表情与飞溅。无全量战斗/存档回归。结果见`outing127-validation.json`、截图`docs/captures/world_restart/outing127_shove.png`。

入口`play.cmd` / `preview_outing127.cmd`，标题127。

## 图像生成

使用内置image_gen编辑126原图，生成后复制到项目资产目录。最终提示词：

Precise tiny facial edit to this exact pixel-art sprite. Preserve canvas, transparent padding, entire cyan body silhouette, proportions, shading, foot contour and white hair tuft EXACTLY. Keep eye centres, eye sizes, tiny vacant cross pupils and highlights in their original locations. Keep the small upside-down U pout unchanged. Only modify the upper contour of the two coral red eyes into a VERY MILD inward-downward eyelid angle, covering at most the top 10-15 percent of each eye, as if this dumb cute jelly is trying to look annoyed while still staring blankly. Retain at least 85 percent of the round red eye shape. NO triangle eyes, NO fierce sharp expression, NO new eyebrows, NO new limbs, NO deformation, NO lean, NO redraw, NO perspective change. This must still look 98 percent identical to the input original Tuantuan, with just a little mildly angry silly stubborn gaze. Exact same coarse pixel grid and dark purple outlines, transparent background, no text, no shadows.
