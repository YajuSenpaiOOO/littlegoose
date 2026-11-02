extends "res://scripts/combat/memory_kit234.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="music_class":data.fx="120 BPM。外框与辅助框重合时点击：Perfect伤害＋40%。按住每拍普通攻击，保留原输出预算。射速转为每拍威力。原型仅普通弹幕。";data.erase("fx2")
 return data
