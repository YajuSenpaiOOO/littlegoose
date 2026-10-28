# 院子构图实机第一版

后续修订见 courtyard-ground-v2.md：下文的原生几何石板与地表花朵已被真实像素材质、独立 Y 排序花丛替换。第一版记录保留供对照。

2026-10-16。依据 courtyard-local-v1.png 实现地面骨架、左侧休息角和右侧菜圃；不是参考图的全部细节已完成。

## 已实现

- 保留原房屋与主角尺度。大石坪缩为门前铺装和断续石板，院门的路向南，沿东侧院外绕行后向北伸出。外路中心线读取 courtyard-route-reservations.json，与通行检查共用。
- 长椅移到西侧果树旁，路灯、树桩和低植被组成休息角。东侧两块菜床、短围栏和收纳箱形成花园。门前添小收纳物，保留房门前的通道。
- 关键物件集中在 scenes/world/courtyard_props.tscn，有 36 个可编辑独立节点。菜圃通过 WorldProp 复用物理脚印、排序、接触影和太阳投影；物件能逐个微调碰撞。
- 地面由原草地、土路多边形、分散石板、原图集草花分层绘制。原来沿铺装绕一圈的碎石条带在新版移除。土路与石板用共享材质，避免为每块地面建立独立着色器实例。
- 保留出发站的天色过渡及合并太阳影。默认白天看构图；N 切天色。Tab 切全院总览，C 跟随，H 碰撞，J 地表草花开关。

## 素材与差距

主房屋、树、长椅、路灯和低植被继续复用已有素材。围栏来自原出发站生成资产；菜床作物来自工程已有 Craftpix 农作物包，许可来源文件复制到 assets/courtyard_v1/craftpix-license.txt。菜床木边和地面为 Godot 原生几何，不将整张参考图烘焙成背景。

当前仍没有参考图里的工具台、浇水壶、独立花盆组、柴棚等特色资产。地面磨损和植被细节密度也没有达到参考图；石板目前是可调原生形状与轻微颗粒的第一版材质。此轮用于实际角色镜头下确认布局与尺度，不能宣称一比一复现。尚未进行全场战斗与大量子弹的性能测试。

## 对照和手动调整

preview_world_home.cmd 打开当前版。preview_world_home_previous.cmd 打开本轮前的石坪版本（独立保留旧脚本及 home_props.tscn）。不要将两个版本同时修改为主版本。

当前摆件编辑入口改为 scenes/world/courtyard_props.tscn，选择对象后修改 Collision Adjust / Footprint Override，只影响该实例。旧版 home_props.tscn 仍作为对照使用。少量窗前花箱及低植被目前由脚本布置。

## 验证

- home_pixel_probe.gd 16/16：真实主角移动、房屋/长椅/石头/菜床碰撞、入口畅通、灯光、阴影缓存、总览。
- shadow_revision_probe.gd 8/8：原树脚点与碰撞、所有新旧太阳投影进入合并遮罩、出发站过渡曲线、连续按键。
- ground_join_probe.gd 7/7：36 个编辑节点、实例碰撞微调、草花避让角色初始位置、J 对照。
- courtyard_route_probe.gd：504 点，40 单位直径净空，无实体阻挡；同时检查路中心线确实在已铺土路内。
- OpenGL 实际渲染截图：courtyard_gameplay_v1.png、courtyard_overview_noon.png、courtyard_overview_sunset.png、courtyard_overview_night.png。

局部预览边界墙保留。院外路已铺出，不代表北侧岔路与三个战斗区域已接通。连接相邻场景时仍需处理边界墙开口、接点和往返实走。
