# 小白鹅：新世界制作目录

最新院子修订：石板与土径已改用独立像素材质，地面花朵改成可穿行、按脚点排序的植株。素材、提示词和实机验证见 `docs/courtyard-ground-v2.md`。

当前方向：保留 A 全景的空间布局，采用出发站已验证的像素素材体系（免费基础图集 + 定制特色摆件）。此前 B 手绘风格及 35° 试验保留作对照，暂停扩产。小屋、童年林地、姐姐的湖岸和暮色车站组成连续世界。

本目录已初始化为独立可运行的 Godot 4.7 工程，当前主场景是一屏“小屋门外”美术样板。完整战斗和剧情尚未迁移。

旧版可运行工程：`../godot_yard`。旧战斗、角色控制、光影与剧情系统是迁移来源。按需要复制并整理依赖；新工程最终不通过相对路径依赖旧工程。不整包复制旧地图和实验素材，不在两处同时维护同一功能。

## 目录

- `docs/`：当前制作计划、资产清单、迁移记录。
- `art/references/`：布局和画风参考，仅作制作参考，不导入游戏。
- `art/source/`：生成原图、分层稿、候选与加工源文件，不导入游戏。
- `assets/environment/`：选定并整理好的地面、植被、建筑与摆件资源。
- `assets/characters/`：实际使用的角色资源。
- `scenes/sandbox/`：一屏美术样板及功能验证场景。
- `scenes/world/`：正式区域场景。
- `scripts/`：逐项迁入或新建的运行代码。

## 运行样板

当前默认场景为参考图布局的院子第一版：运行本工程、`preview_world_home.cmd` 或 `preview_world_props.cmd`。WASD 移动，Shift 快走；N 切换夕照/白天/夜晚/清晨，O 光影开关，C 跟随镜头，V 林缘植被，H 碰撞，R 复位，F1 面板。记录见 `docs/home-pixel.md`。

N 已恢复为出发站小样的指数收敛过渡；J 可对比铺装边缘和树脚衔接。树与石头现在可在 `scenes/world/courtyard_props.tscn` 中手动摆放、微调碰撞。操作说明见 `docs/ground-join-and-editing.md`。此前太阳影合并记录保留在 `docs/shadow-revision-01.md`，其中旧 N 切换说明以 `docs/courtyard-local-plan.md` 为准。

上一版手绘地皮与镜头跟随场景保留在 `scenes/sandbox/yard_walk_study.tscn`，记录见 `docs/yard-walk.md`。

上一版纯色地面摆件样板保留在 `scenes/sandbox/prop_study_35.tscn`。记录见 `docs/props35.md`。

最新视角白模：双击工作目录 `preview_world_angle.cmd`。按 1 / 2 / 3 比较 25° / 35° / 45° 俯角；WASD 移动，G 网格，O 几何投影，R 复位。它用于确定地面压缩、物件倾角和角色适配，尚未覆盖正式画风或完整物理。记录见 `docs/angle-study.md`。

## 第一版手绘样板（历史对照）

双击工作目录的 `preview_world_handpaint.cmd` 可单独运行第一版手绘样板。以下按键只适用于该历史场景。

- WASD / 方向键：移动；Shift：快走。
- N：柔和日光 / 暮色 / 月夜；O：方向投影开关。
- H：显示摆件脚点与碰撞范围。
- `[` / `]`：主角比例 85% / 100% / 115%。
- R：主角复位；F1：面板；Esc：退出。

场景包含一张手绘地面、独立小屋、两棵同源树、一块石头，以及旧项目的主角行走图和团团待机图。团团当前是外观和碰撞占位，不攻击。此处地面是一屏样板背景，尚未制作跨区域拼接方案；窗户暖色是原图绘制，尚无独立夜间发光通道。

首版手绘记录见 `docs/sample-01.md`。当前先评审像素素材版的小屋入口，再决定是否按 A 布局扩展。

详细顺序见 `docs/production-plan.md`。完整概念图提示词保留在 `../docs/world-style-exploration/README.md`。

院子构图第一版已搭建，默认白天；Tab 全院总览。与参考图的差距、素材来源及验证记录见 docs/courtyard-build-v1.md。preview_world_home_previous.cmd 保留本轮前的石坪版本。
