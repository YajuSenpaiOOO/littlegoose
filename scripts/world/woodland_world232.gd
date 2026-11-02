extends "res://scripts/world/woodland_world231.gd"
func _init() -> void:
 super._init();memory_save116="user://plush_boss232_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit232.gd").new()
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 232 · 连续剑雨 / 合批刀身胶垫与投影")
func _paper_manager_script146() -> Script:return preload("res://scripts/combat/paper_rain232.gd")
func _sword_manager153() -> Script:return preload("res://scripts/combat/balloon_sword232.gd")
func test_config_path226() -> String:return "user://boss_balance232.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 var cfg=ConfigFile.new()
 if cfg.load("user://boss_balance231.cfg")!=OK:super.load_test226();return
 var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary and PROFILE226.error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",cat_health226)),10.,10000.)
 bat_health226=clampf(float(cfg.get_value("test","bat_hp",bat_health226)),10.,10000.)
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["rain232"]={"payload_gain":1.25,"drop_spacing":.09,"flight_duration":1.25,"render":"four_multimeshes_with_gel_and_shadows","distribution":"three_inner_three_outer","repeat_penalty":.1,"landing_jitter":"min(.28,body_radius*.35), no damage size bonus"};return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("231","232")
