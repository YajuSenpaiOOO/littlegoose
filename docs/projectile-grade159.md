# 159：弹幕共用昼夜调色

2026-10-25。当前气球剑的黏附/回弹已足够验证玩法，本轮不继续增加溅射细节，只修复环境融合并建立后续弹幕的默认通路。

## 问题与改动

原基础弹幕、气泡和胶滴画在2D战斗画布，使用`combat_tint111`。后来新增的3D剑身、黏附胶端、纸飞机和笔记图像绕过了该CanvasModulate，尤其不受光的自定义剑身shader仍以原色显示。

现在3D战斗视觉集中到`CombatWorldEffects159`。该层与2D画布共用已经计算好的昼夜颜色，不另造一套时间曲线。正午、黄昏和深夜会实时同步已有对象，新出生对象也会在自动登记时染色。

- 普通Sprite3D与简单标准材质MeshInstance3D：放进公共层后自动登记，保留原始颜色与独立透明度；材质复制后再调色，不污染共享源资源。
- 自定义剑身shader：通过公共`world_effect_grade159.gdshaderinc`读取一次更新的全局颜色，不逐把更新shader参数。
- 黏附胶片、飞机与笔记图像：自动按Sprite3D处理；2D气泡/胶滴继续由原画布调色，避免重复叠色。
- 使用弱引用剔除销毁对象；连续更新不会把颜色越乘越黑；淡出alpha不被重置，过渡回正午可以恢复原色。

## 新弹幕接入约定

新3D弹幕的管理器或视觉节点挂到`world.combat_effect_root159()`，不要直接散放到世界根。现有纸飞机、笔记与剑管理器的公共创建路径已使用这个入口。

通用Sprite3D和标准材质无需添加昼夜代码。新写的特殊ShaderMaterial仍须沿用公共shader模板：包含`world_effect_grade159.gdshaderinc`，输出颜色使用`grade_world_effect159(color.rgb)`。任意独立shader不会被引擎自动重写；这一条公共材质约定避免以后再次绕过调色。多表面/特殊发光材质按其专用shader设计接入，不应依靠普通单材质覆盖。

确需保持自身发光色的普通视觉节点，可以在加入场景前设置`environment_grade159=false`；公共shader则把`environment_grade159`设为0。界面不放进3D特效层。

## 体验与验证

入口`preview_projectile_grade159.cmd`，保留158入口。原有Alt+2正午、Alt+3黄昏、Alt+4夜晚、Alt+0自然时间，可在同一遭遇中观察剑、胶端和飞机。普通战斗键位不变。

12项定向检查通过：公共层归属、出生自动接入、三时段实时变化、原色和透明度保持、不累乘、材质隔离、发光例外与对象清理。已检查三时段实机图；没有重跑地图/战斗平衡全套。报告`projectile-grade159-validation.json`、日志`projectile-grade159-validation.log`；截图`captures/world_restart/projectile_grade159_{noon,dusk,night}.png`。
