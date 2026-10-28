extends "res://scripts/world/woodland_time116.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text="117 · 像素百宝盒与棒棒糖轻瞄准\n小院靠近铁盒按 F 整理记忆\nF5 林地试演 · F3 回小院\n鼠标指向演员附近 · 左键射击\n头顶糖星表示辅助目标\nShift 闪避 · 右键蹲防／弹反\nF7 暂停 · Esc 结束演出／关闭铁盒\nCtrl+F9 帧率 · F1 隐藏说明"
