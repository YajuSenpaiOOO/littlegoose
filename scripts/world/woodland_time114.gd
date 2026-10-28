extends "res://scripts/world/woodland_time113.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text="114 · 45秒战斗试验\nA 方向瞄准＋轻辅助 · 左键射击\nB 自动瞄准 · 自动射击\nWASD 移动 · Shift 闪避\n右键按住蹲防 · 按下瞬间弹反\nF2 换模式重开 · F5 当前模式重试\nF7 暂停 · Esc 提前结束\nCtrl+F9 帧率 · F1 隐藏说明"
