extends "res://scripts/world/woodland_time119.gd"
func update_guide() -> void:
 super.update_guide()
 if is_instance_valid(guide): guide.text="120 · 林间聚会与弹跳收藏品\nF5 邀请团团 · F3 回小院\n附近的伙伴会分批跑来，不显示波数\n打倒后概率掉软弹珠，靠近拾取\n3份液滴制作弹弓 · 散场不额外发礼包\n鼠标辅助 · 左键射击／蓄力\nShift 闪避 · 右键蹲防／弹反\nF7 暂停 · Esc 先休息\nCtrl+F9 帧率 · F1 隐藏说明"
