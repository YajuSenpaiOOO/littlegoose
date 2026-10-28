# 124：生气互拱、多人争执与柔和退场

2026-10-23。沿用123扑空翻滚、119存档、120概率掉落及122自然散场。

## 修改

- 翻滚采样：关闭纹理重复，在旋转后的采样坐标越界时discard，避免方形贴图边界绕回身体或角落碎像素。保留原图，不修改源素材。
- 新增`assets/tuantuan_v2/shove_angry124.png`低头、鼓脸、生气互拱姿态。以alpha≥0.5可见轮廓计算脚点、比例，避免透明背景中的微弱噪点导致角色缩小。元数据在同名json，动作两侧共用一张图并朝对方翻转，继续共享软体/昼夜系统。
- 多人争执不再要求一对一互相指向：新滚来的团团能加入已有争执；每只选一个附近目标，目标离开则就近另选。玩家命中只解除被打者，其他参与者仍可互拱。增加邻居间距修正，防止几只完全重叠。微伤、不能致死、争执时限与冷却沿用123。
- 倒地先保留原姿态，2.8秒后以1.25秒平滑渐隐；使用真正alpha blending的专用软体着色器，避免原alpha scissor使半透明像素突然整块消失；影子同步减弱，暂停冻结，完成后才删除。

## 难度诊断与对照

原聚会固定round_index=0，因此继承110攻击预约：最多1位windup/lunge，间隔1秒。15位是总量，最多5位同时在场，不等于5位同时构成扑击威胁。6血、约3发/秒的基础射击、受击击退、扑击恢复以及新增翻滚/争执进一步减轻压力；这不是单一血量问题。

保留默认原节奏，F6随时切换压力对照：最多2位windup/lunge、预约间隔0.65秒，血量/总量/掉落保持。先观察是否产生利用相撞争执的意愿，再决定正式血量和阵型，不把参数变难当作乐趣成立。

入口`play.cmd` / `preview_outing124.cmd`，标题124；F5约玩、F6压力对照、F3回院。

## 验证

`scripts/world/outing124_probe.gd`：29项行为/材质/多人争执/并发限制/原生射击完整流程检查，包含受击后剩余参与者重新选目标、真实半透明值、暂停与删除。测试保护玩家生命，不代表难度或乐趣已经验收。输出`outing124-validation.json`及`docs/captures/world_restart/outing124_*.png`。

## 图像生成记录

使用内置image_gen，参考原`airborne_v1.png`，输出复制到项目资产目录；未使用CLI。最终提示词如下：

Edit target: referenced game sprite. Create ONE new animation pose for exactly this same cute cyan jelly Tuantuan character, matching coarse pixel-art grid, dark purple pixel outline, coral red huge eyes and white fluffy tuft precisely. New pose: low crouched forward head-butting posture, facing three-quarter RIGHT, lowered head, exaggerated puffed cheeks, narrowed annoyed eyes and tiny pursed mouth, playfully angry sulking child, clearly leaning forward to shove another jelly. Single isolated full body sprite only, same simple rounded body, no limbs, no accessories, no other character, no text, no symbols, no ground, no shadow. Genuine clean transparent background, no stray pixels, generous empty transparent padding all sides. Retain original palette and pixel art style, not smooth illustration. Pose should be readable at 80 pixels tall.
