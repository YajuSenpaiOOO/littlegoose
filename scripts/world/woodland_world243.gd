extends "res://scripts/world/woodland_world242.gd"
func _init() -> void:
 super._init();memory_save116="user://music243_preview.cfg"
func test_config_path226() -> String:return "user://boss_balance243.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 243 · 蝙蝠固定判定框 / 后续拍提亮")
func _candy_script117() -> Script:return preload("res://scripts/combat/music_aim243.gd")
func reset_music236() -> void:
 super.reset_music236()
 if is_instance_valid(candy117):candy117.bat_sizes243.clear()
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("242","243")
