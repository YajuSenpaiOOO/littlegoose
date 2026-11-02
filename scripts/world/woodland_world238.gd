extends "res://scripts/world/woodland_world237.gd"
func _init() -> void:
 super._init();memory_save116="user://music238_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit238.gd").new()
func test_config_path226() -> String:return "user://boss_balance238.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 238 · 辅助框多拍收缩")
func _candy_script117() -> Script:return preload("res://scripts/combat/music_aim238.gd")
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("237","238").replace("音符到线点击","缩到辅助框点击")
