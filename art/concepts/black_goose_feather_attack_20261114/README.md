# 小黑鹅正面抬手弹羽毛 · 三动作 / 三弹体

2026-11-14，内置image_gen六次独立生成，以assets/black_goose_flight378/selected-C.png为身份/配色参考。原始PNG无损复制，完整提示为prompt-action-A/B/C.txt与prompt-projectile-A/B/C.txt；manifest.json记录原路径、尺寸、透明有效边界、SHA256和帧区域。

动作各一张1536×1024四格关键姿势稿，阅读顺序左上→右上→左下→右下：准备、抬手、释放、收势。

- action-A.png：单手弹指，动作较紧凑。
- action-B.png：掌心托羽轻拨，动作较柔和。
- action-C.png：袖口拈羽再弹，准备与释放过程更明显。

动作参考锁定正面、右手（画面左）施法、角色自身右腿后翘、左脚较低，背翼保持展开以便比较手势。生成式重绘仍有跨帧细节/手形变化；这是动作候选，不是最终只动手臂的成品动画。选定后需固定头身/翼根，拆手臂，清理画内羽毛与运行弹体的重复，并校准各帧枪口。

弹体候选均朝右、羽梗在左：

- projectile-A.png：奶白淡紫，短而饱满，暗底较明亮。
- projectile-B.png：流线紫羽，较细长，偏速度感。
- projectile-C.png：圆润卷梗小绒羽，偏Q弹和童趣。

预览：action-preview.gif将Godot原生2D绘制的四个预览帧编码为GIF，时长260/220/140/300毫秒，仅慢速看关键姿势。projectile-comparison.png由Godot原生绘制大图和24/36/48屏幕像素宽的明暗底预览，非最终游戏尺寸。preview-frame0..3.png为原生预览帧，脚本scripts/art/preview_feather_attack_20261114.gd可复现。没有通过程序重画或修改原生成PNG。

未选定任何版本，不改385入口、不替换糖弹/数值、不接攻击动画/碰撞/光照/世界挂点。这批是art/concepts候选，不宣称完成2.5D运行资源验收；以后接入再确定实际弹体尺寸、碰撞、速度、受光、影子及显示平面。
