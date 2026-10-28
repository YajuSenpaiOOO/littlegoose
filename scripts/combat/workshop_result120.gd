extends "res://scripts/combat/workshop_result119.gd"
func show_menu(finished: bool) -> void:
 super.show_menu(finished)
 if not finished: return
 stats.text=("团团们都休息了。" if battle.won119 else "这次先休息一下。")+"\n本场拾取蓝色弹性液滴 %d 份\n口袋里共 %d 份"%[battle.drops120.picked120,battle.memory_kit116.gel119]
