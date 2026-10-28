# 小屋门外：手绘样板 01

2026-10-15。主场景：`scenes/sandbox/cottage_study.tscn`。

## 本轮交付

以 B 全景为画风参考，通过内置 image_gen 分别生成地面、小屋、树与石头。实际 PNG 位于 `assets/environment`，锚点与来源记录在同目录 `manifest.json`，完整四组提示词在 `art/source/sample-01-prompts.md`。生成原图直接用于本样板，没有用脚本修改图像像素。

一屏局部对应 A 布局里的小屋入口，不是整个大世界。游戏画面基准 1600×1000；主角可见高 94，团团约 82，小屋 430，主树 475，副树 435，石头 88。先使用旧角色的原有脚点与行走帧，避免同时重绘角色而失去比较基准。

地面是单独的背景层，所有立体物件按脚点独立排序，有各自碰撞。太阳影与角色脚底接触影复用旧系统；小屋改用 alpha 轮廓投影，移除了第一轮矩形屋顶影造成的过直阴影带。长投影没有烘焙进环境图。

## 已迁入的内容及归属

来源均为 `../godot_yard`。本目录内维护后续样板改动，不回写旧工程。

- `scripts/art/hero_frames.gd` 与 `assets/hero_pixel/`：原角色前后左右行走帧、idle、脚点和所需 PNG。只复制对应 JSON 引用的图片。
- `assets/tuantuan_v2/idle_front_v1.png` 与原 pose 数据：团团的待机外观。
- `scripts/art/world_lighting.gd`、`world_light_profile.gd`、`natural_sprite_shadow.gd`、`projected_actor_shadow.gdshader`、`actor_foot_contact.*`：日光、有限投影、静态缓存与窄脚底接触。world_lighting 的旧角色类判断改为 sample_character 元数据，actor_shadow_pose 替换为不依赖旧战斗类的便携接口。
- `projected_prop_shadow.*`、`ground_shadow_math.gd` 和原天空 preset：随光影接口迁入，保留后续物件平面影能力。当前样板使用自己定义的三套天空参数，不开启局部灯光。
- `study_actor.gd` 为新建的最小样板控制器，只使用原帧率与脚点数据；不代表正式 player.gd 的战斗、冲刺或移动手感已完成迁移。

## 验证

Godot 4.7.2 的独立资源导入通过；实际 OpenGL 渲染输出 `docs/captures/cottage_day.png`、`cottage_sunset.png`。

`scripts/study_probe.gd` 共 24 项通过：独立排序对象及投影登记、薄脚底影、四方向帧脚点、真实 CharacterBody2D 对树干/石头的移动碰撞、树后地面通行、暮色有限投影及静态缓存。

## 当前评审重点

1. 现有像素角色在厚重手绘环境中的立牌感，是否保留。
2. 默认角色大小，以及人物与门、树和石头的比例。
3. 地面的笔触密度：本版较丰富，扩大成战场前需根据实机观感确定是否进一步简化。
4. 昼夜变化下的素材明暗。本轮素材本身仍有柔和绘制阴影，动态太阳不能重算其受光面；此限制尚未用法线解决。

当前两棵树共享同一源图，尚未扩充树种。外围花园、围栏、灯和连续植被组留到画风确认后，不在一屏验证前批量制作。
