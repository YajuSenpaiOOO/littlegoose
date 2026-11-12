extends "res://scripts/world/woodland_world301.gd"
func card_script301() -> Script:return preload("res://scripts/combat/paper_card302.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 302 · 竖直纸偶 / 受击钟摆")
func _ready() -> void:
 await super._ready()
 hint288.text="302 悬浮纸偶 · 受击钟摆\n恐龙喷火 / 骑士突刺 / 怪兽砸地"
func _process(delta: float) -> void:
 super._process(delta)
 if ready301:guide206.text=guide206.text.replace("301 吊线纸偶","302 悬浮纸偶")
