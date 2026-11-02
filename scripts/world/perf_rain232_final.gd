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
 extends "res://scripts/world/woodland_world232.gd"
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
  super._init();memory_save116="user://rain232_after_preview.cfg"
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
 FileAccess.open("res://docs/rain232-final-perf.json",FileAccess.WRITE).store_string(JSON.stringify({"failures":failures,"samples":results},"\t"))
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
 w._clear_combat_shots();w._cancel_charge();w.apply_levels226();w.weapon_rng.seed=227001;w.buffs.rng110.seed=227001;w.paper_memories146.flight_rng146.seed=227001;seed(227001)
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
func perf232(tag: String,duration: float) -> void:
 var gaps: Array[float]=[];var start=Time.get_ticks_usec();var previous=start
 while Time.get_ticks_usec()-start<duration*1000000.:
  await process_frame
  var now=Time.get_ticks_usec();gaps.append(float(now-previous)/1000.);previous=now
 gaps.sort()
 var row={"tag":tag,"fps":gaps.size()*1000000./(Time.get_ticks_usec()-start),"median_ms":gaps[gaps.size()/2],"p95_ms":gaps[int(gaps.size()*.95)],"draws":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"sword_nodes":w.swords153.get_child_count(),"shots":w.shots.size(),"landed":w.swords153.resting153.size(),"flying":w.swords153.flying153.size(),"flight_entries":w.swords153.flights154.size(),"blades_pool":w.swords153.blades226.size(),"pads_pool":w.swords153.pads226.size(),"shadows":w.actor_shadows.size(),"enrolled":w.effects159.enrolled159.size(),"physics_ms":Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.,"process_ms":Performance.get_monitor(Performance.TIME_PROCESS)*1000.}
 results.append(row);write_report();print("RAIN232_PERF ",JSON.stringify(row))
func run() -> void:
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 w=BenchWorld.new();root.add_child(w);current_scene=w
 while not w.ready228:await process_frame
 w.levels226={"paper_plane":1,"balloon_sword":1,"three_player":1,"eye_exercise":1};w.start_battle225(false);w.hero.set_physics_process(false);w.invulnerability=10000.;w.cat220.hp=100000.;w.cat220.max_hp110=100000.;w.auto114=true;w.repairs220=1
 await perf232("live_early",8.)
 await create_timer(17.).timeout;await perf232("live_mid",8.)
 await create_timer(19.).timeout;await perf232("live_late",8.)
 w.stop225();write_report();print("RAIN232_PROBE_DONE");quit()
