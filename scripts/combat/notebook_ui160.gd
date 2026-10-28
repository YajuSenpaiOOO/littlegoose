extends "res://scripts/combat/notebook_ui153.gd"
func refresh116() -> void:
 super.refresh116()
 if tab118=="recipe" and focused_id=="pillow_hut":
  stock118.text="试玩开放一份 · 每份占1格\n原料与正式配方待后续设计。"
  craft_button118.disabled=true;craft_button118.text="试玩已开放"
  feedback.text="被动记忆：右键蹲防搭建，不占Q。"
