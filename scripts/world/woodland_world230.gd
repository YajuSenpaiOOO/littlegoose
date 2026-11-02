extends "res://scripts/world/woodland_world229.gd"
func _init() -> void:
 super._init();memory_save116="user://plush_boss230_preview.cfg"
 memory_kit116=preload("res://scripts/combat/memory_kit230.gd").new()
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 230 · 肥猫翻身修正 / 纸飞机直落校准")
func cat_script221() -> Script:return preload("res://scripts/combat/fat_cat_boss230.gd")
func _paper_manager_script146() -> Script:return preload("res://scripts/combat/paper_squad230.gd")
func test_config_path226() -> String:return "user://boss_balance230.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 var cfg=ConfigFile.new()
 if cfg.load("user://boss_balance229.cfg")==OK:
  var saved=cfg.get_value("test","levels",{})
  if saved is Dictionary and PROFILE226.error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
func emit_packet146(packet: Dictionary,origin: Vector3,target: Vector3,gain: float,generation := -1) -> void:
 if not packet.get("air150",false):super.emit_packet146(packet,origin,target,gain,generation);return
 for spec in packet.specs:
  var own: Dictionary=packet.duplicate(false);var copy: Dictionary=spec.duplicate(true)
  # Convert the inherited fan to parallel rain lanes, preserving each spec/budget.
  var offset := Vector3.RIGHT*sin(float(copy.angle))*.8
  copy.angle=0.;own.specs=[copy];own.air150=false
  var at := origin+offset
  super.emit_packet146(own,at,at+Vector3.DOWN*8.,gain,generation)
func _step_shots(delta: float) -> void:
 if buffs.level("paper_plane")==0:super._step_shots(delta);return
 # Both native113 and its fallback read global tracking. All aircraft payloads
 # use release-time correction; gear changes clear existing shots in226.
 var saved: int=buffs.level("eye_exercise");buffs.levels["eye_exercise"]=0
 super._step_shots(delta)
 if saved>0:buffs.levels["eye_exercise"]=saved
 else:buffs.levels.erase("eye_exercise")
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 report["air230"]={"mode":"local_release_then_parallel_fall","correction_radius":[1.9,2.05,2.2],"flight_speed":1.5,"body_radius_included":true,"damage_or_count_bonus":false}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("229","230")
