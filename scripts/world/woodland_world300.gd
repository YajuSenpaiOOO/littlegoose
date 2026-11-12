extends "res://scripts/world/woodland_world299.gd"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 300 · 城楼折纸指挥 / 正门出场")
func stage_script297() -> Script:return preload("res://scripts/art/paper_stage300.gd")
func preview_hint297() -> String:return "300 山顶纸剧场　F12重播 / F3回院\n妹妹：扒城垛→折纸→指挥；大门打开后纸恐龙从正门出场"
func _process(delta: float) -> void:
 super._process(delta)
 if available297:guide206.text="城楼动作与正门出场试演 · F12重播\n目前无Boss伤害/奖励；结束后妹妹继续折纸、探头和指挥"
