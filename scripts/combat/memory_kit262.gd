extends "res://scripts/combat/memory_kit246.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="flashlight":data.fx="持续发射贯穿光束。自身决心低于1/3时亮红灯，伤害变为常态的2倍；射频不变。"
 if id=="balloon_sword":data.fx="气球剑黏附减速：每剑8%，最多5层，每层独立持续3秒。团团扑跳距离同步缩短；团团Boss效果减半，保留弹跳节拍。"
 return data
