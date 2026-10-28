# 小屋入口：出发站素材体系

2026-10-15。当前默认场景 `scenes/sandbox/home_pixel_study.tscn`。运行工作目录 `preview_world_home.cmd` 或 `preview_world_props.cmd`，也可直接运行本 Godot 工程。

## 本轮方向

用户反馈手绘实机不及出发站，改用成熟的像素素材混合路线。A 全景继续约束小屋、林地、湖岸与车站的总体位置；本轮只重建小屋入口一屏，不声称已完成全世界。

直接复用出发站选定的外部图集植被、原图集末行草丛，以及之前定制的铺装、低植被带、花箱、长椅与路灯。没有新生成或下载美术资源。小屋由原图集瓦片组合成一个独立排序物件；不按像素相邻关系合并树木。采用现成素材的固定绘制视角，暂停手绘 35° 路线。

三类树共 19 棵，围成左、右和后侧林缘；8 组低植被补树脚层次，尺寸与空隙有变化。2 块石头、2 个花箱、1 张长椅和 2 盏灯组成门前生活区域。中心保留通行空地，石板路向下延伸。角色、团团的屏幕大小与上一版接近；团团仍为外观占位，不战斗。

## 素材与代码来源

以下全部来自 `../godot_yard` 的已存在内容，复制后新工程独立运行，不读取旧工程的 res:// 路径。

- `assets/tiles/exterior.png`：原图集；基础草地仅使用 (2,18) 一格，树和草丛使用此前已确定的 atlas 区域。未复制整套旧 tileset 或旧 TileMap，避免带入其他资产依赖、站立物件与旧遮挡分组。
- `scenes/world/cottage_art.tscn`：原小屋的瓦片组装，整体按一个脚点排序。
- `assets/world_rebuild_v1/*.tres` 与 `scripts/world/world_prop*.gd`：独立物件的脚点、尺寸、碰撞、虚拟高度和投影规则。
- `assets/departure_plaza_v1/{paving.png,understory_bed_v2.png,flower_box_v1.png,street_light.tres,porch_light.tres,fallen_leaves_v1.png}` 与 `assets/garden_theater_v1/{bench_v1.png,festival_post.png}`：既有定制素材及灯参数。部分资源作为后续复用来源保留，当前场景未使用落叶贴图与门灯参数。
- `scripts/art/{station_light,station_light_profile,projected_actor_shadow,contact_shadow,garden_tree_leaves}` 及配套 shader：局部光、有限高度影、物件接触影、实际树位置驱动的落叶。与此前已经迁入的 world_lighting、自然投影及角色薄脚底影配合。

本轮没有改动旧工程代码或素材。

## 光影与交互

使用原夕照/白天/夜晚/清晨资源；固定每档时间，可按 N 比较。阳光为有限地面投影，物件静止时使用已有缓存。路灯依照天空参数平滑调整亮度，同时为角色与摆件提供有限的局部投影。

初次检查发现重复添加脚印原生遮挡会让长椅出现过长的点光阴影，已移除该重复通道，沿用出发站的有限平面影。未重做整个光影算法，也未声称自动消除了所有素材自身的固定明暗。

默认镜头跟随，缩放为 3；主角世界高约 31.3，屏幕约 94。移动使用现有样板 CharacterBody2D 控制器和真实物件碰撞。完整战斗、使魔、剧情、门口交互和事件触发器仍未迁移。

按键：WASD 移动，Shift 快走，N 天色，O 投影开关，C 跟随/固定，V 显示/隐藏林缘（碰撞仍保留，供画面对照），H 脚点及碰撞，R 复位，F1 面板，Esc 退出。

## 验证

- 实际 OpenGL 渲染并查看夕照与夜晚；同时保存白天截图。路径 `docs/captures/home_pixel_{sunset,noon,night}.png`。
- `scripts/home_pixel_probe.gd` 14/14 通过：独立树/物件注册、两盏灯与真实位置、29 个太阳投影、19 棵树对应的落叶来源、脚底接触、角色屏幕比例、小屋/长椅/石头的实际移动碰撞、主路通行、昼夜灯影与静态缓存。
- 历史手绘地皮样板 `yard_walk_probe.gd` 11/11 通过，保留可比较状态。

下一步先由用户比较本屏与手绘版的融合和氛围。确认后再按 A 布局拓展道路和三个区域；旧事件坐标继续不作为地理约束。
