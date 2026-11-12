extends "res://scripts/world/woodland_world297.gd"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 298 · 山顶纸城堡 / 开门出场")
func stage_script297() -> Script:return preload("res://scripts/art/paper_stage298.gd")
func stage_anchor297() -> Vector2:return meadow.landmarks.grove+Vector2(-24,-26.)
func preview_spawn297() -> Vector2:return meadow.landmarks.grove+Vector2(-24,-19.5)
func preview_hint297() -> String:return "298 山顶纸城堡　F12重播 / F3回院\n草地战场 · 纸门打开与插杆恐龙出场试演，尚无Boss攻击"
func _process(delta: float) -> void:
 super._process(delta)
 if available297:guide206.text="山顶纸剧场 · F12重播\n城门打开→纸恐龙绕出；目前不造成伤害"
