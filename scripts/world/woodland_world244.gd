extends "res://scripts/world/woodland_world243.gd"
func _init() -> void:
 super._init();memory_save116="user://music244_preview.cfg"
 buffs=preload("res://scripts/combat/buff_book244.gd").new();buffs.rng110.randomize()
func balance_profile226() -> Script:return preload("res://scripts/combat/balance_profile244.gd")
func hidden_cards226() -> Array:return ["distract"]
func test_config_path226() -> String:return "user://boss_balance244.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 244 · 撤下双弹道 / 碎片取舍")
func load_test226() -> void:
 var cfg=ConfigFile.new()
 var path=test_config_path226() if FileAccess.file_exists(test_config_path226()) else "user://boss_balance243.cfg"
 if cfg.load(path)!=OK:return
 var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary:
  saved=saved.duplicate(true);saved.erase("distract")
  if balance_profile226().error(saved)=="":levels226=saved;loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",100.)),10.,10000.);bat_health226=clampf(float(cfg.get_value("test","bat_hp",80.)),10.,10000.)
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("243","244")
