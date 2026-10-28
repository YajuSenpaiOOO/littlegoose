extends "res://scripts/combat/notebook_ui161.gd"
func refresh116() -> void:
 super.refresh116()
 if focused_id in ["forest_fireboy","three_player","boarding_school"] and tab118=="recipe":
  stock118.text="试玩各开放1份 · 加1／2／3只分别占1／2／3格\n每只额外鹅40%伤害，本体不受惩罚。"
  craft_button118.disabled=true;craft_button118.text="试玩已开放"
