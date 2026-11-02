extends "res://scripts/combat/memory_kit232.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="homework":data.fx="记下最近三轮直接攻击。Q翻阅后，每轮按原蓄力与伤害的45%重放；三轮分别计算。闪避中止并保留笔记。"
 return data
