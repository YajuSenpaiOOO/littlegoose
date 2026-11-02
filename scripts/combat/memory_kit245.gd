extends "res://scripts/combat/memory_kit241.gd"
func card(id: String) -> Dictionary:
 var data=super.card(id).duplicate(true)
 if id=="red_banner":
  data.fx="闪避原地落下接力旗；下一轮攻击由画中鹅补射主角的一份，旗子随后消散。最多一旗，约5秒。测试补射35%，替代旧连击增伤。";data.erase("fx2")
 return data
