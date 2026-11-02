# A版姐姐制作基准 · 211

## 当前坐姿修订

用户要求复用之前小蝙蝠吊床。当前坐姿改为seated_character_v2.png（纯人物、无吊床布），完整提示词见seated_v2_prompt.md；站姿仍idle.png。坐姿有效高2.10再乘206校准，与站姿头部大小相近。原source.png及seated.png为上一轮历史，不再使用其中坐姿；下文1.84和带布坐姿描述仅记录初版。原205吊床、两帧蝙蝠、挂点、轻摆和玩偶投放均复用。

2026-10-29：用户决定优先完成游戏，蜘蛛姐姐采用210的A方向，主角保留169/192。C保留为日后统一精修参考。只修明显的比例、动作、显示问题，不因精细度反复重构。

内置image_gen根据art_workbench/character_pair_calibration210/pair_a_raw.png生成source.png双姿势透明图。idle/seated只裁开透明边界，未降采样、压色、拉伸。站坐共享大脸、眼镜、玫瑰紫发、围裙和四条蜘蛛附肢。坐姿双手撑布边、腿收在布内。

生成提示词：identity-preserve; SAME spider sister on RIGHT of input reference; preserve chosen A sister exactly: wide face, amber eyes and glasses, rose mauve fluffy hair with left braid, gold spider hairpin, cream web apron, plum skirt, lavender shawl, four cute purple appendages, short arms and chunky proportions. Two separated poses: front standing idle; front sitting snugly in lavender hammock, hands resting on near rim, feet tucked inside. Same head size and pixel clusters. Coarse pixel shapes, simple three-tone shading, neutral lighting, transparent background; no glow, halo, ground shadow, text, redesign, long arms or narrow face.

运行配置复用207受光材质、206等比屏幕高度校准、稳定脚下占地、105轮廓/接触影、199脚点深度；主角hero192不改。站姿基准高2.10，坐姿1.84，保持坐姿头部约等大；最终世界尺寸乘206屏幕校准系数。无新增灯或自发光。坐姿随原205载具挂点运行，需实玩确认布边衔接；上下床仍关键姿势切换。manifest由validate_sister211实机生成。
