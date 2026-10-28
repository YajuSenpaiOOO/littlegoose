extends "res://scripts/combat/notebook_ui146.gd"
func refresh116() -> void:
 super.refresh116()
 if tab118=="recipe" and focused_id=="balloon_sword":
  stock118.text="原料设定：团团的蓝色弹性液滴\n试玩开放一份；正式配方消耗待验证。"
  craft_button118.disabled=true;craft_button118.text="试玩已开放"
  feedback.text="切到装配页放入口袋；每份占1格。"
