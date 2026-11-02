extends "res://scripts/world/woodland_world228.gd"
const RED_GAIN229 := 1.35
var red_seconds229 := 0.
var stage_seconds229 := 0.
func _init() -> void:
 super._init();memory_save116="user://plush_boss229_preview.cfg"
 buffs=preload("res://scripts/combat/buff_book229.gd").new();buffs.rng110.randomize()
 memory_kit116=preload("res://scripts/combat/memory_kit229.gd").new()
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 229 · 眼保健操25% / 手电低血红灯")
func test_config_path226() -> String:return "user://boss_balance229.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 var cfg=ConfigFile.new()
 var path="user://boss_balance228.cfg" if FileAccess.file_exists("user://boss_balance228.cfg") else "user://boss_balance226.cfg"
 if cfg.load(path)==OK:
  var saved=cfg.get_value("test","levels",{})
  if saved is Dictionary and PROFILE226.error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
func flashlight_red229() -> bool:
 return buffs.level("flashlight")>0 and player_hp>0. and health_fraction()<1./3.
func flashlight_damage_gain110() -> float:return RED_GAIN229 if flashlight_red229() else 1.
func flashlight_rate_gain110() -> float:return 1.
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/balance_hud229.gd")
func reset_stats226(partial: bool) -> void:
 super.reset_stats226(partial);red_seconds229=0.;stage_seconds229=0.
func open_window226() -> void:
 super.open_window226();window226["start_hp"]=player_hp;window226["red_seconds"]=0.;window226["stage_seconds"]=0.
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 report["balance229"]={"eye_rate_level1":1.25,"eye_rate_level2":1.5,"flashlight_threshold":"health_fraction < 1/3","flashlight_damage_gain":RED_GAIN229,"flashlight_rate_gain":1.,"red_seconds":red_seconds229,"stage_seconds":stage_seconds229}
 return report
func _process(delta: float) -> void:
 if ready228 and active114 and not combat_paused:
  var red=flashlight_red229();var stage=is_instance_valid(moment161) and moment161.running161()
  if red:red_seconds229+=delta
  if stage:stage_seconds229+=delta
  if not window226.is_empty():
   if red:window226.red_seconds+=delta
   if stage:window226.stage_seconds+=delta
 super._process(delta)
 if ready228:
  guide206.text=guide206.text.replace("228", "229")
  if active114 and flashlight_red229():guide206.text+="\n红灯：手电伤害＋35%"
