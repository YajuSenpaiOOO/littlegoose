extends "res://scripts/world/woodland_time118.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text="119 · 团团约玩与蓝色液滴\nF5 去和团团玩 · F3 回小院\n三位先玩，两位同伴从附近加入\n散场获得液滴 · 回院按 F 制作弹弓\n鼠标方向辅助 · 左键射击／蓄力\nShift 闪避 · 右键蹲防／弹反\nF7 暂停 · Esc 先休息\nCtrl+F9 帧率 · F1 隐藏说明"
