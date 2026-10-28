extends "res://scripts/combat/notebook_ui160.gd"
func refresh116() -> void:
 super.refresh116()
 if focused_id=="hero_moment":
  feedback.text="主动Q：主角时刻。与课堂笔记共用一个主动位置，先卸下另一份。"
  if tab118=="recipe":
   stock118.text="试玩开放一份 · 占1格\n正式配方待后续设计。"
   craft_button118.disabled=true;craft_button118.text="试玩已开放"
