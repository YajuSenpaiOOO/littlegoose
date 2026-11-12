extends "res://scripts/world/woodland_world306.gd"

func card_script301() -> Script:
 if card_type301(spawned301) == "knight":
  return preload("res://scripts/combat/paper_card305.gd")
 return super.card_script301()

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 309 · 305骑士基线")

func _ready() -> void:
 await super._ready()
 hint288.text = "309 恢复305骑士\nF8混合 / F9恐龙 / F10怪兽 / F11骑士"

func _process(delta: float) -> void:
 super._process(delta)
 if ready301:
  guide206.text = guide206.text.replace("306 纸偶读招", "309 305骑士基线")
  guide206.text = guide206.text.replace("Delete 地面预告", "Delete 恐龙 / 怪兽地面预告")
