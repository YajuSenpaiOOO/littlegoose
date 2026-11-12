extends "res://scripts/combat/memory_kit288.gd"
const PROFILE346=preload("res://scripts/combat/balance_profile346.gd")
func card(id: String) -> Dictionary:
 var entry:=super.card(id).duplicate(true)
 if id=="forest_fireboy":entry.fx="占2格，额外小黑鹅＋1，沿本体路径开火车；额外鹅40%伤害，保留射速与弹幕形态，本体不受惩罚。"
 if id=="three_player":entry.fx="占4格，额外小黑鹅＋2；每只40%伤害，保留射速与弹幕形态，本体不受惩罚。每只副鹅按2格计费。"
 return entry
func used(ids: Array) -> int:
 # Legacy notebook retains its own historical budget for unrelated cards.
 return super.used(ids)+ids.count("forest_fireboy")+ids.count("three_player")*2
