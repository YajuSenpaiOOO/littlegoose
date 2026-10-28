# 林间小院 41：第一轮布景与空间氛围

2026-10-17。当前入口 `scenes/world/world41.tscn`，继承 world40 的玩法和镜头。没有改卡池、每波选卡、弹道、弹反、伤害、角色物理尺寸或战斗场地。

## 试玩

根目录 `preview_world_atmosphere.cmd`、`preview_world_continuous.cmd`、`preview_world_3d_map.cmd` 进入小院；`preview_world_combat.cmd` 在相同美术版本进入战斗。`preview_world_combat40.cmd` 保留上一版对照。

- F12：整套氛围开关。恢复原环境光、雾和太阳设置，并关闭新增野花、近景树及对应碰撞。
- Ctrl+F12：只切林间光束。
- Alt+F12：轻景深试验，默认关闭；以人物附近为清晰区，柔化极近处和远处。
- F3 回小院；2 岔路；原滚轮缩放、F1 隐藏说明、战斗/选卡/F5/F8 继续沿用。

## 本轮内容

- 两棵同画风前景树框住小院，用现有树根接地、碰撞、遮挡淡出和独立投影管线。位置避开主路。
- 少量白色野花沿屋角、石墙、弯路外侧和入林路成小片布置。保留中间通道，不用大团灌木替代草。单个 MultiMesh 批次、透明裁切，GPU 执行微风和近身拨动，没有每朵花单独的 CPU 模拟或碰撞体。
- 略冷的环境填光与暖阳区分，树荫更深；使用距离雾从 24 米开始拉开后景，而不是整屏叠灰。
- 五处世界坐标光带，方向来自实际太阳，使用场景深度遮挡。是风格化低成本光束，不是真实体积散射，尚不会自动判断每个树冠空洞；需要继续随布景调整。
- 可选景深使用 Compatibility 可运行的九采样深度后处理，半径很小，不是散景镜头模拟。先处理不透明场景，再绘制半透明树冠、光束和辅助线；透明效果自身不参与这层模糊。默认关闭，没有动态模糊。

真实透视地图已经有自然视差，无须另造跟镜头滑动的地表层。小院/林路用实体前中后景；湖岸、车站后续需要更远的对岸或远山时，再做世界坐标远景卡片。没有给当前封闭林地加固定天幕风景。

## 资产与代码

- 新生成素材：`assets/atmosphere41/daisy_sprig.png`，内置 image_gen 工具生成，原始透明图保留。完整提示词见同目录 `prompt.md`。
- 可复用模块：`scripts/art/woodland_atmosphere41.gd`；野花、光束、轻景深各有独立 shader。
- 场景只用 `world41.gd` 继承 `world40.gd`，后续迁移 buff 仍以 CURRENT_STATE 中的 world40 规则为基准，不需要重写本轮美术。

## 验证

`scripts/world/atmosphere41_capture.gd` 保存 world40 / world41 的小院、林路、岔路同机位截图。`atmosphere41_probe.gd` 检查当前视角、批次、花根/通道、对照开关恢复、实际渲染差异，以及进入原有遭遇流程。结果写入 `docs/atmosphere41-validation.json`。图像对照时冻结场景与时钟，避免把摆动/呼吸造成的差异误认为后处理生效。

截图在 `docs/captures/world_restart/atmosphere40_*.png` 与 `atmosphere41_*.png`。这是局部初稿，完整远景、更多植物变体、院子生活摆件和正式性能基准尚未完成。

本次 11 项检查通过。独立 `atmosphere41_performance.gd` 排除截图比较的 CPU 停顿后，在本机 1440×900 窗口（项目逻辑尺寸 1600×1000）小院机位各采样 120 帧：关闭氛围约 107 FPS，开启约 110 FPS，可选景深约 110 FPS；属于本轮运行波动，没有测出明显退化，不代表开特效提升性能，也不覆盖全地图或战斗峰值。记录在 `atmosphere41-performance.json` 和同名日志。不要拿截图探针后立即读取的 Engine FPS 当性能基准。

技术依据：[Godot 渲染器支持表](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)、[Environment 距离雾](https://docs.godotengine.org/en/4.6/classes/class_environment.html)。当前使用 Compatibility，未切换 Forward+，未开启原生体积雾或原生景深。
