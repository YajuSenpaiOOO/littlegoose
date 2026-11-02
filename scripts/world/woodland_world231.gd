extends "res://scripts/world/woodland_world230.gd"
func _init() -> void:
 super._init();memory_save116="user://plush_boss231_preview.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 231 · 肥猫新滚动 / 独立趴倒")
func cat_script221() -> Script:return preload("res://scripts/combat/fat_cat_boss231.gd")
func test_config_path226() -> String:return "user://boss_balance231.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 var cfg=ConfigFile.new()
 if cfg.load("user://boss_balance230.cfg")!=OK:super.load_test226();return
 var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary and PROFILE226.error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",cat_health226)),10.,10000.)
 bat_health226=clampf(float(cfg.get_value("test","bat_hp",bat_health226)),10.,10000.)
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("230","231")
