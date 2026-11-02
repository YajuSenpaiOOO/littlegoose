extends "res://scripts/world/woodland_world233.gd"
func _init() -> void:
 super._init();memory_save116="user://plush_boss234_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit234.gd").new()
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 234 · 分裂载荷继承 / 课堂笔记说明")
func _paper_manager_script146() -> Script:return preload("res://scripts/combat/paper_rain233.gd")
func cat_script221() -> Script:return preload("res://scripts/combat/fat_cat_boss233.gd")
func test_config_path226() -> String:return "user://boss_balance234.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 var cfg=ConfigFile.new()
 if cfg.load("user://boss_balance233.cfg")!=OK:super.load_test226();return
 var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary and PROFILE226.error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",cat_health226)),10.,10000.)
 bat_health226=clampf(float(cfg.get_value("test","bat_hp",bat_health226)),10.,10000.)
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("233","234")
# Each split owns its saved payload. Damage here is already resolved by its parent.
var split_generation234 := -1000
func damage_for_shot(shot: Dictionary) -> float:
 if shot.get("final_damage234",false):return float(shot.fixed_damage110)
 return super.damage_for_shot(shot)
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var payload={"stream":shot.get("stream110",false),"heavy":shot.get("stream_heavy110",false),"lane":shot.get("stream_lane110",0),"charged":shot.get("charged",false),"note":shot.get("note110",false),"snack":shot.get("snack146",buffs.level("snack")),"tracking":shot.get("tracking146",buffs.level("eye_exercise"))}
 var before=pending_splits110.size();super._apply_shot_hit(shot,hit)
 for i in range(before,pending_splits110.size()):pending_splits110[i].payload234=payload.duplicate()
func inherit_split153(shot: Dictionary,split: Dictionary) -> void:
 super.inherit_split153(shot,split)
 if not split.has("payload234"):return
 var payload: Dictionary=split.payload234
 shot.final_damage234=true;shot.packet146=true;shot.snack146=payload.snack;shot.tracking146=payload.tracking
 shot.charged=payload.charged;shot.note110=payload.note
 if payload.stream:
  split_generation234-=1
  shot.stream110=true;shot.stream_heavy110=payload.heavy;shot.stream_lane110=payload.lane
  shot.stream_generation110=split_generation234;shot.stream_sequence110=0
  if is_instance_valid(shot.get("shadow")):shot.shadow.hide()
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 report.motion233.payload_unchanged_from232=false
 report["payload234"]={"split":"saved identity and resolved half damage; second generation quarter damage","notes_gain":.45,"plane_presentation":"unchanged233"}
 return report
