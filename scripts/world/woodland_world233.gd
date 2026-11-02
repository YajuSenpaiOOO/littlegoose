extends "res://scripts/world/woodland_world232.gd"
func _init() -> void:
 super._init();memory_save116="user://plush_boss233_preview.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 233 · 匀速掠过 / 气球剑减速滚动")
func _paper_manager_script146() -> Script:return preload("res://scripts/combat/paper_rain233.gd")
func cat_script221() -> Script:return preload("res://scripts/combat/fat_cat_boss233.gd")
func test_config_path226() -> String:return "user://boss_balance233.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 var cfg=ConfigFile.new()
 if cfg.load("user://boss_balance232.cfg")!=OK:super.load_test226();return
 var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary and PROFILE226.error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",cat_health226)),10.,10000.)
 bat_health226=clampf(float(cfg.get_value("test","bat_hp",bat_health226)),10.,10000.)
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["motion233"]={"air_speed":8.,"roll_slow":"existing 8% per sword, maximum40%","roll_duration":"distance-normalized clock","payload_unchanged_from232":true};return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("232","233")
