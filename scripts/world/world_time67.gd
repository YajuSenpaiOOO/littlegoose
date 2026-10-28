extends "res://scripts/world/world_time65.gd"

func update_guide() -> void:
	if not is_instance_valid(guide) or clock55==null: return
	var mode := "自然流动" if clock55.speed==1. else "120倍预览"
	if preview: mode="时段预览 · 已停表"
	elif clock55.paused: mode="已暂停"
	elif clock55.at_deep_night(): mode="夜深了 · 回小屋休息可进入次日"
	elif blocked(): mode="暂歇 · 时间暂停"
	var text := "第%d天 · %s · %s\n%s\nAlt+1 晨光 / 2 正午 / 3 落日 / 4 夜晚\nAlt+T 加速 · Alt+P 暂停 · Alt+0 自然\nCtrl+F4 林路 · F3 小屋"%[clock55.day,clock55.caption(),clock55.period(),mode]
	if can_sleep(): text+="\nEnter 休息，次日06:30醒来"
	if sleeping: text="晚安……"
	if is_instance_valid(accents57):
		var rig: String="聚光＋随身补光" if accents57.stage_enabled and world.porch49.fill_enabled else ("仅舞台聚光" if accents57.stage_enabled else ("仅随身补光" if world.porch49.fill_enabled else "两者都关"))
		text+="\nAlt+F 萤火虫%s · Alt+L 聚光%s\nAlt+H 远景柔化%s\nAlt+B 灯组：%s"%["开" if accents57.fireflies_enabled else "关","开" if accents57.stage_enabled else "关","开" if haze_enabled57 else "关",rig]
	var study: Node3D=world.get("landmark62")
	if is_instance_valid(study):
		text+="\nAlt+5 古橡 / 6 银柳 / 7 花树\nAlt+8 旧树 · Alt+N 手绘/3D路牌\nCtrl+F5 古树全貌 · WASD退出\nCtrl+F7 路牌 · Ctrl+F6 湖桥\n当前：%s · %s\nCtrl+F8 树根 · Alt+J 小景[%s]\nAlt+Y 根部接地[%s]"%["旧占位树" if study.old_tree else study.LABELS[study.variant],"手绘路牌" if study.painted_sign else "原3D路牌","开" if study.understory_enabled else "关","开" if study.seated_roots else "关"]
	var lake: Node3D=world.get("bridge59")
	if is_instance_valid(lake): text+="\nAlt+M 水波[%s] · Alt+G 波光[%s]"%["开" if lake.moving else "关","开" if lake.sparkling else "关"]
	var fade: RefCounted=world.get("whole67")
	if is_instance_valid(fade): text+="\n67：Alt+O 整树隐去[%s]\nCtrl+F9 帧率 · F10 清零 · F11 同步"%["缓冲改良" if fade.improved else "旧版对照"]
	# Build once and assign only on visible changes, avoiding inherited text churn.
	text+=_guide_suffix67()
	if guide.text!=text: guide.text=text

func _guide_suffix67() -> String:
	return ""
