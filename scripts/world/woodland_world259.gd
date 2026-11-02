extends "res://scripts/world/woodland_world258.gd"
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_boss259.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 259 · 团团Boss / 闪避路线")
func _process(delta: float) -> void:
 super._process(delta)
 if ready251:guide206.text=guide206.text.replace("258 团团Boss · 弹反保护修正","259 团团Boss · 闪避路线")
