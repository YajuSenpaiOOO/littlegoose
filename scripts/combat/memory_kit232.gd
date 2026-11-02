extends "res://scripts/combat/memory_kit230.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="paper_plane":data.fx="把当前弹幕送到标记区，快速掠过、连续洒落六次。投递伤害＋25%，保留覆盖范围；落下后不横追。"
 return data
