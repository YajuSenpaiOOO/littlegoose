extends "res://scripts/combat/memory_kit245.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="red_banner":data.fx="闪避原地留下接力旗，下一轮攻击由画中鹅补射主角一份。等待期间不超时，重复闪避不换旗；发射后收起。铅笔不转向，鹅转头。测试补射35%。"
 return data
