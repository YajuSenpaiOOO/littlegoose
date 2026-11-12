extends "res://scripts/combat/memory_kit273.gd"
func card(id: String) -> Dictionary:
 var entry=super.card(id).duplicate(true)
 if id=="bouncy_ball":entry.fx="弹幕变成弹力球，原弹保留速度改向一次；反弹伤害70%、结束贯穿。飞机落地弹起，光束折射；分裂子弹各可弹一次，反弹命中不再分裂。与气球剑互斥。"
 return entry
