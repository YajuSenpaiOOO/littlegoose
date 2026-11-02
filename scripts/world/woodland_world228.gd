extends "res://scripts/world/woodland_world227.gd"
var ready228 := false
var fight_clock228 := 0.
var events228: Array=[]
func _init() -> void:
 super._init();memory_save116="user://plush_boss228_preview.cfg";cat_health226=100.;bat_health226=80.
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 228 · 两段节奏 / 修补喘息 / 织网错峰")
func test_config_path226() -> String:return "user://boss_balance228.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226();return
 # Reuse only the chosen fragments on first entry. The old HP experiment stays intact.
 var cfg=ConfigFile.new()
 if cfg.load("user://boss_balance226.cfg")==OK:
  var saved=cfg.get_value("test","levels",{})
  if saved is Dictionary and PROFILE226.error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
func _ready() -> void:
 await super._ready();ready228=true
func cat_script221() -> Script:return preload("res://scripts/combat/fat_cat_boss228.gd")
func support_script227() -> Script:return preload("res://scripts/combat/spider_support228.gd")
func event228(kind: String) -> void:
 events228.append({"event":kind,"time":float(stats226.get("seconds",0.)),"round":repairs220+1 if battle_phase220=="fight" else maxi(1,repairs220)})
func reset_stats226(partial: bool) -> void:
 super.reset_stats226(partial);events228.clear()
 if partial:event228("segment_start")
func start_battle225(keep_player: bool) -> void:
 super.start_battle225(keep_player);fight_clock228=0.;events228.clear();event228("first_round")
func cat_can_roll227(at: Vector2,to: Vector2) -> bool:
 return not weaving228() and super.cat_can_roll227(at,to)
func weaving228() -> bool:
 return is_instance_valid(support227) and not support227.dead and support227.state170 in ["weave","happy"]
func can_weave228() -> bool:
 return active114 and battle_phase220=="fight" and fight_clock228>=2. and not delivery220 and not is_instance_valid(pig220) and cotton220.active.is_empty() and cat220.phase220 not in ["windup","roll"]
func spawn_support227() -> void:
 # Parent227 requests support during the second repair; this preview requests it
 # during the second cat round instead. Never spawn a new hazard in the repair.
 if not active114 or battle_phase220!="fight" or repairs220<1 or fight_clock228<2.:return
 var was_called=called227;super.spawn_support227()
 if not was_called and called227:event228("spider_called")
func choose_drop220() -> Vector2:
 if battle_phase220!="fight" or weaving228() or cat220.phase220 in ["windup","roll"]:return Vector2.INF
 return super.choose_drop220()
func release_pig220() -> void:
 if battle_phase220!="fight" or weaving228() or cat220.phase220 in ["windup","roll"]:
  drop_wait220=1.;return
 super.release_pig220()
 if is_instance_valid(pig220):event228("pig_drop")
func place_pad172(actor: CharacterBody3D) -> CharacterBody3D:
 if pads172.size()>=2:return null
 return super.place_pad172(actor)
func quiet_support228() -> void:
 for pad in pads172.duplicate():remove_pad172(pad)
 clear_silk171();attacker170=null
 if is_instance_valid(support227) and not support227.dead:
  support227.pad172=null;support227.enter170("watch");support227.wait170=1.25;support227.lift170=0.;support227._render_legacy(0.);support227.impulse=Vector2.ZERO;support227.velocity=Vector3.ZERO
  support227.set_physics_process(false);support227.hit_area.collision_layer=0;support227.collision_layer=0;enemies.erase(support227)
 rebuild_cells110()
func resume_support228() -> void:
 if is_instance_valid(support227) and not support227.dead:
  if support227 not in enemies:enemies.append(support227)
  support227.hit_area.collision_layer=8;support227.collision_layer=16;support227.set_physics_process(true);rebuild_cells110()
func cat_down220(cat: CharacterBody3D) -> void:
 if active114 and battle_phase220=="fight":quiet_support228();event228("cat_down");fight_clock228=0.
 super.cat_down220(cat)
func report_stats226() -> Dictionary:
 var report=super.report_stats226()
 if not report.has("rhythm228"):report["rhythm228"]={"policy":"single roll -> quiet repair -> weaving and follow-up roll","events":events228.duplicate(true),"web_limit":2,"cat_hp":cat_health226,"bat_hp":bat_health226}
 return report
func _process(delta: float) -> void:
 if alternate_encounter251():super._process(delta);return
 var running=ready228 and active114 and not combat_paused
 var previous=battle_phase220
 if running and previous=="fight":fight_clock228+=delta
 super._process(delta)
 if running and active114 and previous!=battle_phase220:
  if battle_phase220=="repair":event228("repair_open")
  if previous=="rise" and battle_phase220=="fight":
   fight_clock228=0.;drop_wait220=maxf(drop_wait220,4.);resume_support228();event228("next_round")
   notice219("肥猫又鼓起来了，小蜘蛛也来帮忙")
 if ready228 and active114 and not combat_paused and battle_phase220=="fight" and repairs220>=1 and not called227:spawn_support227()
 if ready228:
  guide206.text=guide206.text.replace("226 姐姐战","228 姐姐战").replace("226", "228")
  if stage225=="battle":
   if battle_phase220=="fight":guide206.text+="\n"+("第一轮：单滚后留出输出空隙" if repairs220==0 else "再次出击：连滚 / 小蜘蛛织网 · 猪猪错峰")
   elif battle_phase220 in ["lower","repair","rise"]:guide206.text+="\n喘息与反击：棉絮、网垫清场 · 小蜘蛛停手"
