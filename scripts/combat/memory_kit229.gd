extends "res://scripts/combat/memory_kit168.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="eye_exercise":
  data.fx="射速＋25%，保留弹幕微追踪";data.fx2="射速合计＋50%，追踪增强"
 if id=="flashlight":data.fx="持续发射贯穿光束。生命低于1/3时亮红灯，伤害固定＋35%；射频不额外增加。"
 return data
