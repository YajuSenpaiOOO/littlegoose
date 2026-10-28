extends "res://scripts/combat/notebook_ui119.gd"
func refresh116() -> void:
 super.refresh116()
 if tab118=="recipe" and focused_id in ["paper_plane","homework"]:
  stock118.text="免费开放一份试装 · 拥有 %d 份\n本轮只验证玩法，不消耗纸张材料。"%working_owned.get(focused_id,1)
  craft_button118.disabled=true;craft_button118.text="试装已放进盒中"
  feedback.text="切到装配页放进口袋；每份占1格。"
