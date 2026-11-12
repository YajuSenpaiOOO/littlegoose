extends "res://scripts/combat/notebook_ui168.gd"
func refresh116() -> void:
 super.refresh116()
 var kit=world.memory_kit116
 if focused_id in ["forest_fireboy","three_player"]:
  detail_name.text=str(kit.card(focused_id).name)+"\n每份占 %d 格"%kit.PROFILE346.COSTS[focused_id]
  if tab118=="recipe":stock118.text="单副鹅2格 · 双副鹅4格\n每只额外鹅40%伤害，本体不受惩罚。"
 for i in 4:
  if i<working.size() and working[i] in ["forest_fireboy","three_player"]:
   slots118[i].text=str(kit.card(working[i]).name)+"  · %d格  × 收回"%kit.PROFILE346.COSTS[working[i]]
