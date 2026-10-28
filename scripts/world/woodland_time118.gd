extends "res://scripts/world/woodland_time117.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text="118 · 魔法笔记本与糖纸轻瞄准\n靠近小锅／铁盒按 F 翻开笔记本\n右侧书签切换配方、装配 · 可翻页\n同种记忆可制作多份、分别占格\nF5 林地试演 · F3 回小院\n鼠标方向辅助 · 左键射击\nShift 闪避 · 右键蹲防／弹反\nF7 暂停 · Esc 结束／合上笔记本\nCtrl+F9 帧率 · F1 隐藏说明"
