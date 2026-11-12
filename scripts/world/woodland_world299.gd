extends "res://scripts/world/woodland_world298.gd"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 299 · 落纸插景 / 纸怪抱杆")
func stage_script297() -> Script:return preload("res://scripts/art/paper_stage299.gd")
func preview_hint297() -> String:return "299 山顶纸剧场　F12重播 / F3回院\n城堡与纸景垂直落下插稳 · 正常纸怪抱杆组合 · 尚无Boss攻击"
func _process(delta: float) -> void:
 super._process(delta)
 if available297:guide206.text="落纸插景试演 · F12重播\n本轮仅改落景与抱杆，妹妹城楼动作后续补关键帧"
