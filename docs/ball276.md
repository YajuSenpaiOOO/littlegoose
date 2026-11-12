# 276 彩色弹力球资源

用户要求原弹/反弹同色并实际绘制图稿，另开始手电变身设计。内置image_gen新建薄荷/奶黄/粉/紫四块拼色玩具弹力球，原PNG复制assets/bouncy_ball276/ball.png，不修改像素。提示词/原输出/显示策略见同目录PROMPTS.md，尺寸与边界/hash见layout.json。原始alpha边界含低透明度边缘，使用alpha>=128有效边界作draw source region，不改PNG。

elastic_visual276在原275瞬态2D投影层用同一纹理/WHITE调制绘制所有原弹和反弹，保持原屏幕尺寸/计数上限，不再用bounces切蓝/橙颜色。命中圈同薄荷色系。275仅抽elastic_visual_script275默认工厂，旧275继续原程序球对照；276覆盖为新资源，原球物理/速度/反弹/分裂/光束路径完全沿用275。无额外碰撞体或贴图外阴影，不改场景/主角/花显示。

5项Compatibility检查通过docs/ball276-validation.json / ball276-validation.log，无脚本/shader错误，旧relay_flag245导出警告仍在。含资源加载有效边界、原反弹同WHITE、旧糖图双状态隐藏、原弹节点/速度和剑互斥保留。已看原弹/反弹同屏截图，两颗拼色一致；人工摆位/状态非美术主观验收，未重跑275全武器回归。

手电变身仅设计，详见flashlight-transform276-design.md，未改成主动。方向为被角披风/玩具手电/纸贴章的自有童年英雄想象，约.7秒开关→聚光→双手递出爆发；建议后续8秒持续、末2秒红灯，输入与冷却下一轮实测。当前不套特定作品角色装备/标识/动作音效，也不作法律风险保证。

latest276，67/elastic275保留原程序色球对照；169不变，未提交/push。
