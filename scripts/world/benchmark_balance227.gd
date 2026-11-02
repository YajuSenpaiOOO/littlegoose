extends SceneTree
const PROFILE=preload("res://scripts/combat/balance_profile226.gd")
const BUILDS=[
 {"id":"base","levels":{}},
 {"id":"eye","levels":{"eye_exercise":1}},
 {"id":"one_goose","levels":{"forest_fireboy":1}},
 {"id":"three","levels":{"three_player":1}},
 {"id":"three_eye","levels":{"three_player":1,"eye_exercise":1}},
 {"id":"light","levels":{"flashlight":1}},
 {"id":"light_eye","levels":{"flashlight":1,"eye_exercise":1}},
 {"id":"light_three_eye","levels":{"flashlight":1,"three_player":1,"eye_exercise":1}},
 {"id":"sling","levels":{"slingshot":1}},
 {"id":"sling_eye","levels":{"slingshot":1,"eye_exercise":1}},
 {"id":"sling_three_eye","levels":{"slingshot":1,"three_player":1,"eye_exercise":1}},
 {"id":"sword","levels":{"balloon_sword":1}},
 {"id":"sword_eye","levels":{"balloon_sword":1,"eye_exercise":1}},
 {"id":"sword_three_eye","levels":{"balloon_sword":1,"three_player":1,"eye_exercise":1}},
 {"id":"plane","levels":{"paper_plane":1}},
 {"id":"plane_eye","levels":{"paper_plane":1,"eye_exercise":1}},
 {"id":"plane_three_eye","levels":{"paper_plane":1,"three_player":1,"eye_exercise":1}},
 {"id":"plane_sword_three_eye","levels":{"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1}},
 {"id":"stage_three_eye","levels":{"hero_moment":1,"three_player":1,"eye_exercise":1}}
]
class BenchWorld:
 extends "res://scripts/world/woodland_world227.gd"
 var measuring := false
 var bench_phase := "cat"
 var sample_age := 0.
 var damage := [0.,0.,0.]
 var bench_hits := [0,0,0]
 var first_hit := [-1.,-1.,-1.]
 var thresholds := [-1.,-1.,-1.]
 var warm_damage := 0.
 var sample_frames := 0
 var frames_over_50ms := 0
 var input_seconds := 0.
 var release_count := 0
 func _init() -> void:
  super._init();memory_save116="user://boss_baseline227_preview.cfg"
 func load_test226() -> void:pass
 func export_stats226() -> Error:return OK
 func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 自动站桩基准（非实战 / 不改配置）")
 func fire_input_held() -> bool:
  if buffs.level("slingshot")>0 and charge_active and charge_ratio()>=1.:return false
  return super.fire_input_held()
 func _release_charged(target: Vector3,ratio: float) -> void:
  if measuring:release_count+=1
  super._release_charged(target,ratio)
 func record_enemy_damage226(actor: Node,amount: float) -> void:
  super.record_enemy_damage226(actor,amount)
  if not measuring:return
  var index=0 if actor==cat220 else bats220.find(actor)+1
  if index<0 or index>2:return
  damage[index]+=amount;bench_hits[index]+=1
  if first_hit[index]<0.:first_hit[index]=sample_age
  if thresholds[index]<0. and damage[index]>=(100. if index==0 else 32.):thresholds[index]=sample_age
  if index==0 and sample_age>=4.:warm_damage+=amount
 func _process(delta: float) -> void:
  if measuring:
   sample_age+=delta;sample_frames+=1
   if delta>.05:frames_over_50ms+=1
   if fire_input_held():input_seconds+=delta
   if bench_phase=="bat":phase_age220=0.
  super._process(delta)
var w: Node3D
var results: Array=[]
var failures: Array=[]
var initial_config: PackedByteArray
var config_exists := false
var cfg_path := "user://boss_balance226.cfg"
var confirmation := false
func _initialize() -> void:call_deferred("run")
func check(ok: bool,message: String) -> void:
 if not ok:failures.append(message);push_error(message)
func write_report() -> void:
 var report={"schema":1,"complete":results.size()==(9 if confirmation else 38) and failures.is_empty(),"created_local":Time.get_datetime_string_from_system(),"conditions":{"world":"woodland_world227.gd","renderer":"gl_compatibility","stationary":true,"pigs":false,"player_health_default":14,"distance_xz":3.,"cat_duration":12.,"cat_warm_interval":[4.,12.],"bat_duration":6.,"target_hp_inflated":100000.,"thresholds":[100.,32.],"native_autoaim":true,"sling_auto_release_full":true,"stage_at_start_when_equipped":true,"accuracy":null,"not_a_live_combat_sample":true},"failures":failures,"samples":results}
 FileAccess.open(("res://docs/baseline227-confirmation.json" if confirmation else "res://docs/baseline227-results.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
func settle(count: int=4) -> void:
 for i in count:await physics_frame
func place_player(target: Vector3) -> bool:
 # Test fixtures only. Keep forest geometry, collision and occlusion intact.
 for direction in [Vector2(-1,0),Vector2(1,0),Vector2(0,1),Vector2(0,-1),Vector2(-1,1).normalized(),Vector2(1,1).normalized()]:
  var at=Vector2(target.x,target.z)+direction*3.
  if not w.open_drop225(at):continue
  var origin=Vector3(at.x,w.floor_height(at)+.55,at.y)
  var ray=PhysicsRayQueryParameters3D.create(origin,target,1|2,[w.hero.get_rid()])
  if not w.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():continue
  w._teleport15(at);w.hero.reset_actions();w.hero.velocity=Vector3.ZERO;w.hero.locomotion=Vector2.ZERO;w.hero.combat_impulse=Vector2.ZERO
  return true
 return false
func measure(build: Dictionary,phase: String,repeat: int=0) -> void:
 check(PROFILE.error(build.levels)=="","Illegal loadout "+build.id)
 w.measuring=false;w.auto114=false;w.levels226=build.levels.duplicate(true);w.loadout_name226=build.id
 w.start_battle225(false);w.pigs_enabled220=false;w.clear_pig220();w.invulnerability=10000.;w.player_hp=float(build.get("health",14.));w.hero.set_physics_process(false);w.cat220.set_physics_process(false)
 w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 for bat in w.bats220:bat.hp=100000.;bat.max_hp110=100000.
 if phase=="bat":
  w.battle_phase220="repair";w.phase_age220=0.;w.cat220.dead=true;w.cat220.hit_area.collision_layer=0
  w.rig_at220=Vector2(w.cat220.position.x,w.cat220.position.z)+Vector2(1.65,-.75);w.rig_height220=.1
  w.rig220.place220(w.rig_at220,.1,0.);w.rig220._process(0.)
  for bat in w.bats220:bat.set_enabled220(true)
  if build.get("single_bat",false):w.bats220[1].set_enabled220(false)
  await settle()
  check(place_player(w.bats220[0].hit_area.global_position),"No clear bat fixture")
 else:check(place_player(w.cat220.hit_area.global_position),"No clear cat fixture")
 w._clear_combat_shots();w._cancel_charge();w.apply_levels226();w.weapon_rng.seed=227001;w.buffs.rng110.seed=227001;seed(227001)
 w.cooldown=0.;w.fire_needs_release=false;w.combo=0;w.stop_until=0.;Engine.time_scale=1.
 await settle(8)
 w.target114=null;w.aim_tick114=-1;w.rebuild_cells110();w.auto114=true;w._refresh_aim114(w.get_viewport().get_mouse_position())
 check(is_instance_valid(w.target114),"Native autoaim must acquire target: "+build.id+"/"+phase)
 var target_name=str(w.target114.name) if is_instance_valid(w.target114) else "none"
 var hero_start=w.hero.position
 w.damage=[0.,0.,0.];w.bench_hits=[0,0,0];w.first_hit=[-1.,-1.,-1.];w.thresholds=[-1.,-1.,-1.];w.warm_damage=0.;w.sample_age=0.;w.sample_frames=0;w.frames_over_50ms=0;w.input_seconds=0.;w.release_count=0
 var launches=w.paper_memories146.planes_launched146;var deliveries=w.paper_memories146.deliveries146
 var wall_start=Time.get_ticks_usec();w.bench_phase=phase;w.measuring=true;w.auto114=true
 if build.levels.get("hero_moment",0)>0:w.moment161.request161()
 var limit=12. if phase=="cat" else 6.
 while w.sample_age<limit:
  await process_frame
 w.measuring=false;w.auto114=false
 var row={"build":build.id,"player_health":w.player_hp,"single_bat":build.get("single_bat",false),"attack_cooldown_at_end":w.attack_cooldown(),"charge_time_at_end":w.charge_time(),"levels":build.levels,"slots":PROFILE.cost(build.levels),"phase":phase,"repeat":repeat,"seconds":w.sample_age,"wall_seconds":float(Time.get_ticks_usec()-wall_start)/1000000.,"damage":w.damage.duplicate(),"hit_events":w.bench_hits.duplicate(),"first_hit":w.first_hit.duplicate(),"time_to_100_cat_or_32_each_bat":w.thresholds.duplicate(),"dps":w.damage[0]/w.sample_age if phase=="cat" else (w.damage[1]+w.damage[2])/w.sample_age,"cat_warm_dps":w.warm_damage/maxf(.001,w.sample_age-4.) if phase=="cat" else null,"frames":w.sample_frames,"frames_over_50ms":w.frames_over_50ms,"attack_input_seconds":w.input_seconds,"charged_releases":w.release_count,"planes_launched":w.paper_memories146.planes_launched146-launches,"plane_deliveries":w.paper_memories146.deliveries146-deliveries,"initial_target":target_name,"hero_position":str(hero_start),"hero_drift":w.hero.position.distance_to(hero_start),"final_target":str(w.target114.name) if is_instance_valid(w.target114) else "none","effective_levels":w.buffs.levels.duplicate(true),"shot_counter_not_accuracy":w.fired_count,"hits_counter_not_accuracy":w.landed_hits}
 check(row.hero_drift<.01,"Hero moved during baseline")
 results.append(row);write_report();print("BASELINE227_SAMPLE ",JSON.stringify(row))
 w._clear_combat_shots();w._cancel_charge();w.stop_until=0.;Engine.time_scale=1.
func run() -> void:
 confirmation="--confirm" in OS.get_cmdline_user_args()
 config_exists=FileAccess.file_exists(cfg_path)
 if config_exists:initial_config=FileAccess.get_file_as_bytes(cfg_path)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 w=BenchWorld.new();root.add_child(w);current_scene=w
 while not w.ready227:await process_frame
 # Two phases per build: no carry-over aircraft, charge, notes or stage cooldown.
 var selected=BUILDS
 if confirmation:
  selected=BUILDS.filter(func(build):return build.id in ["three_eye","light_eye","plane_sword_three_eye"])
  selected=selected.duplicate(true)
  selected.append({"id":"light_eye_half_health","levels":{"flashlight":1,"eye_exercise":1},"health":7.})
  selected.append({"id":"plane_three_eye_single_target","levels":{"paper_plane":1,"three_player":1,"eye_exercise":1},"single_bat":true,"phases":["bat"]})
 for build in selected:
  for phase in build.get("phases",["cat","bat"]):await measure(build,phase,1 if confirmation else 0)
 w.stop225()
 check(FileAccess.file_exists(cfg_path)==config_exists and (not config_exists or FileAccess.get_file_as_bytes(cfg_path)==initial_config),"User balance configuration changed")
 write_report();print("BASELINE227_DONE samples=",results.size()," failures=",failures.size());quit(0 if failures.is_empty() else 1)
