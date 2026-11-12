extends "res://scripts/world/woodland_world309.gd"

func card_script301() -> Script:
 if card_type301(spawned301) == "knight":
  return preload("res://scripts/combat/paper_card312.gd")
 return super.card_script301()

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 312 · 骑士牵引 / 冲击反馈")

func _ready() -> void:
 await super._ready()
 hint288.text = "312 骑士牵引 / 冲击反馈\nF8混合 / F9恐龙 / F10怪兽 / F11骑士"

func _process(delta: float) -> void:
 super._process(delta)
 if ready301:
  guide206.text = guide206.text.replace("309 305骑士基线", "312 骑士牵引 / 冲击反馈")
