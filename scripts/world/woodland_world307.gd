extends "res://scripts/world/woodland_world306.gd"

func card_script301() -> Script:
 return preload("res://scripts/combat/paper_card307.gd")

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 307 · 骑士定点回荡")

func _ready() -> void:
 await super._ready()
 hint288.text = "307 骑士定点回荡\nF8混合 / F9恐龙 / F10怪兽 / F11骑士"

func _process(delta: float) -> void:
 super._process(delta)
 if ready301:
  guide206.text = guide206.text.replace("306 纸偶读招", "307 骑士定点回荡")
