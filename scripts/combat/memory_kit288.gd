extends "res://scripts/combat/memory_kit275.gd"
const FLASH288 := "Q主动变身：显形后8秒按住左键直射贯穿光线，最后3秒红灯，伤害约为前段的1.58倍。结束后冷却30秒；平时保留普通攻击／原武器。与主角时刻、课堂笔记共用主动位置。"
func card(id: String) -> Dictionary:
 var entry=super.card(id).duplicate(true)
 if id=="flashlight":entry.fx=FLASH288
 return entry
