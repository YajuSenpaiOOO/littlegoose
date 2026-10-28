extends "res://scripts/world/woodland_time114.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text="115 · 方向软锁定试验\nA 鼠标指大致方向，左键射击\n离开怪物仍保持圈选；明显转向换目标\nB 自动瞄准＋自动射击（对照）\nWASD 移动 · Shift 闪避 · 右键蹲防／弹反\nF2 换模式重开 · F5 重试 · F7 暂停\nEsc 结束 · Ctrl+F9 帧率 · F1 隐藏说明"
