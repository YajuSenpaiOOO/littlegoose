extends SceneTree
const BUILDS339=[
 {"id":"base","levels":{}},
 {"id":"eye","levels":{"eye_exercise":1}},
 {"id":"clone_eye","levels":{"eye_exercise":1,"forest_fireboy":1}},
 {"id":"sling_eye","levels":{"eye_exercise":1,"slingshot":1}},
 {"id":"sling_clone_eye","levels":{"eye_exercise":1,"slingshot":1,"forest_fireboy":1}},
 {"id":"sling_ball_eye","levels":{"eye_exercise":1,"slingshot":1,"bouncy_ball":1}},
 {"id":"sling_clone_half","levels":{"eye_exercise":1,"slingshot":1,"forest_fireboy":1},"charge":.5},
 {"id":"light_eye_no_q","levels":{"eye_exercise":1,"flashlight":1}},
 {"id":"light_eye_q","levels":{"eye_exercise":1,"flashlight":1},"q":true},
 {"id":"light_plane_eye_q","levels":{"eye_exercise":1,"flashlight":1,"paper_plane":1},"q":true},
 {"id":"snack_clone_eye","levels":{"eye_exercise":1,"snack":1,"forest_fireboy":1}}
]
class Bench:
 extends "res://scripts/world/woodland_world340.gd"
 var measuring339:=false
 var secondary340:=false
 var cannon_damage340:=0.
 var cannon_sources340: Dictionary={}
 var bounce_start340:=0
 var age339:=0.
 var goal339:=Vector3.ZERO
 var damage339:=0.
 var warm339:=0.
 var hits339:=0
 var threshold339: Variant=null
 var releases339:=0
 var release_ratios339: Array[float]=[]
 var charge339:=1.
 var use_q339:=false
 var sources339: Dictionary={}
 var bins339: Dictionary={}
 func load_test226() -> void: pass
 func export_stats226() -> Error: return OK
 func boss_step314(_delta: float) -> void: pass
 func hurt_player(_damage: float,_from: Vector2) -> void: pass
 func hitstop(_duration: float,_force := false) -> void: pass
 func structure_contact326(_at: Vector3,_normal: Vector3,_broken := false) -> void: pass
 func _advance_impact_time() -> void:
  impact_clock.clear()
  Engine.time_scale=2.
 func _refresh_aim114(_cursor: Vector2) -> void:
  target114=null
  aim114=goal339
 func aim_at_screen(_cursor: Vector2) -> Vector3: return goal339
 func paper_aim146() -> Vector3:
  return Vector3(goal339.x,floor_height(Vector2(goal339.x,goal339.z))+.05,goal339.z)
 func fire_input_held() -> bool:
  if not measuring339 or not hero.controls_enabled or combat_paused: return false
  if buffs.level("slingshot")>0 and charge_active and charge_ratio()>=charge339:return false
  return true
 func _release_charged(at: Vector3,ratio: float) -> void:
  if measuring339:
   releases339+=1
   release_ratios339.append(ratio)
  super._release_charged(at,ratio)
 func hurt_cannon326(index: int,damage: float) -> void:
  var hp:=cannon_hp326[index]
  super.hurt_cannon326(index,damage)
  if measuring339 and hp>cannon_hp326[index]:
   cannon_damage340+=hp-cannon_hp326[index]
   cannon_sources340[source337]=float(cannon_sources340.get(source337,0.))+hp-cannon_hp326[index]
 func damage_fastener321(shot: Dictionary,at: Vector3) -> void:
  var hp:=fastener_hp321
  super.damage_fastener321(shot,at)
  var loss:=hp-fastener_hp321
  if not measuring339 or loss<=0.:return
  damage339+=loss
  hits339+=1
  if age339>=4.:warm339+=loss
  if threshold339==null and damage339>=144.:threshold339=age339
  sources339[source337]=float(sources339.get(source337,0.))+loss
  var bin:=str(int(age339/5.))
  bins339[bin]=float(bins339.get(bin,0.))+loss
 func _physics_process(delta: float) -> void:
  if measuring339 and use_q339 and not combat_paused and cooldown288<=0. and not transform288.playing:start288()
  if measuring339 and not combat_paused:age339+=delta
  super._physics_process(delta)
var w: Node3D
var samples: Array[Dictionary]=[]
var failures: Array[String]=[]
var config_before: Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(ok: bool,message: String) -> void:
 if not ok:failures.append(message);push_error(message)
func save339(complete: bool) -> void:
 var data={"schema":1,"complete":complete,"failures":failures,"conditions":{"runtime":"woodland_world340.gd","static_real_castle":true,"cannon_fixture":"alone and two indestructible secondary cannons; attacks disabled","duration_seconds":20.,"clock":"unpaused scaled physics; Q transformation intro excluded","physics_step":1./60.,"engine_scale":2.,"physics_ticks_per_second":120,"castle_hp":1000000.,"enemy_attacks":false,"hero_stationary":true,"hitstop_and_paper_hit_art":false,"not_survival_or_clear_time_test":true,"target":"central wall bay","seeds":[33901,33902],"hero_moment":false,"q_counts_per_sample":true},"samples":samples}
 FileAccess.open("res://docs/dps340-results.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
func settle339(count: int=6) -> void:
 for i in count:await physics_frame
func measure339(build: Dictionary,distance: float,trial_seed: int,seconds :=20.) -> void:
 w.measuring339=false
 check(w.balance_profile226().error(build.levels,5)=="","invalid build "+build.id)
 w.restart301()
 w.theatre314.cancel()
 w.theatre314.sample(4.06)
 w.theatre314.finished=true
 w.waiting_intro314=false
 w.core_phase326=true
 w.panel_open321=true
 w.theatre314.set_panel321(1)
 w.theatre314.enable_castle327(true)
 w.theatre314.enable_cannons326(w.secondary340)
 if w.secondary340:w.cannon_hp326.assign([1000000.,1000000.])
 w.grid111.invalidate()
 w.active114=true
 w.combat_paused=false
 w.hero.controls_enabled=true
 w.fastener_hp321=1000000.
 w.determination_level257=2
 w.levels226=build.levels.duplicate(true)
 w.apply_levels226()
 w.reset_skill288()
 w.paper_memories146.reset146()
 w._clear_combat_shots()
 w._cancel_charge()
 var shape: CollisionShape3D=w.theatre314.castle_target327.get_child(2)
 w.goal339=shape.global_position
 var pos:=Vector2(w.goal339.x,w.goal339.z+distance)
 w._teleport15(pos)
 w.hero.set_physics_process(false)
 w.hero.velocity=Vector3.ZERO
 w.hero.combat_impulse=Vector2.ZERO
 w.hero.locomotion=Vector2.ZERO
 w.hero.facing="up"
 w.hero.render_pose()
 w.auto114=false
 w.weapon_rng.seed=trial_seed
 w.buffs.rng110.seed=trial_seed
 seed(trial_seed)
 w.cooldown=0.
 w.fire_needs_release=false
 w.combo=0
 w.charge339=float(build.get("charge",1.))
 w.use_q339=bool(build.get("q",false))
 await settle339(12)
 var start: Vector3=w.hero.global_position
 var q_start: int=w.activations288
 var launched: int=w.paper_memories146.planes_launched146
 w.cannon_damage340=0.
 w.cannon_sources340.clear()
 w.bounce_start340=w.elastic_stats275.redirects
 w.damage339=0.
 w.warm339=0.
 w.hits339=0
 w.threshold339=null
 w.releases339=0
 w.release_ratios339.clear()
 w.sources339.clear()
 w.bins339.clear()
 w.age339=0.
 var wall:=Time.get_ticks_msec()
 w.measuring339=true
 while w.age339<seconds and Time.get_ticks_msec()-wall<180000:await physics_frame
 w.measuring339=false
 var elapsed: float=w.age339
 check(elapsed>=seconds,"sample timed out "+build.id)
 check(w.hero.global_position.distance_to(start)<.01,"hero moved "+build.id)
 var row={"secondary_cannons":w.secondary340,"cannon_damage":w.cannon_damage340,"cannon_sources":w.cannon_sources340.duplicate(),"structure_bounces":w.elastic_stats275.redirects-w.bounce_start340,"combined_dps":(w.damage339+w.cannon_damage340)/elapsed,"build":build.id,"levels":build.levels,"slots":w.balance_profile226().cost(build.levels),"distance":distance,"seed":trial_seed,"seconds":elapsed,"damage":w.damage339,"dps":w.damage339/maxf(.001,elapsed),"post4_dps":w.warm339/maxf(.001,elapsed-4.),"time_to_144":w.threshold339,"sources":w.sources339.duplicate(),"five_second_damage":w.bins339.duplicate(),"hits":w.hits339,"charged_releases":w.releases339,"charge_policy":w.charge339,"release_ratios":w.release_ratios339.duplicate(),"q_enabled":w.use_q339,"q_activations":w.activations288-q_start,"planes_launched":w.paper_memories146.planes_launched146-launched,"effective_levels_end":w.buffs.levels.duplicate(),"charge_time":w.charge_time(),"attack_cooldown":w.attack_cooldown(),"wall_seconds":(Time.get_ticks_msec()-wall)/1000.}
 samples.append(row)
 save339(false)
 print("DPS339 ",JSON.stringify(row))
 w.reset_skill288()
 w._clear_combat_shots()
 w._cancel_charge()
func run() -> void:
 var cfg_folder:=ProjectSettings.globalize_path("user://")
 for file in DirAccess.get_files_at(cfg_folder):
  if file.ends_with(".cfg"):config_before[file]=FileAccess.get_file_as_bytes(cfg_folder+file).hex_encode().sha256_text()
 Engine.physics_ticks_per_second=120
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 w=Bench.new()
 root.add_child(w)
 current_scene=w
 var limit:=Time.get_ticks_msec()+180000
 while not is_instance_valid(w.structure_ui335) and Time.get_ticks_msec()<limit:await process_frame
 if not is_instance_valid(w.structure_ui335):
  failures.append("world init timeout");save339(false);quit(1);return
 w.hero.set_physics_process(false)
 w.theatre314.set_process(false)
 for secondary in [false,true]:
  w.secondary340=secondary
  for index in [3,4,5]:await measure339(BUILDS339[index],6.,33901)
 w.secondary340=true
 await measure339(BUILDS339[5],6.,33902)
 # Real current 275 original-projectile redirect, not the obsolete 273 queue.
 w.measuring339=false
 w._clear_combat_shots()
 w.buffs.levels["bouncy_ball"]=1
 var area: Area3D=w.theatre314.castle_target327
 var at: Vector3=area.get_child(2).global_position
 var hp_before: float=w.fastener_hp321
 var shot: Dictionary=w.data_shot110(at+Vector3.BACK*.5,Vector3.FORWARD*20.,2.)
 shot.fixed_damage110=10.
 shot.final_damage234=true
 shot.split_depth110=0
 var node=shot.node
 var fired: int=w.fired_count
 w._step_shots(.04)
 check(w.shots.has(shot) and shot.node==node and w.fired_count==fired,"redirect keeps original projectile without spawning")
 check(shot.get("bounces275",0)==1 and is_equal_approx(shot.fixed_damage110,7.),"first structure hit changes original to seventy percent")
 check(is_equal_approx(shot.velocity.length(),20.) and not shot.get("piercing110",false),"speed retained and piercing ends")
 check(shot.ignore_rids110.has(area.get_rid()) and shot.ignore_rids110.has(w.theatre314.bodies[0].get_parent().get_rid()),"both castle aliases excluded")
 var cannons_before: float=w.cannon_hp326[0]+w.cannon_hp326[1]
 w._step_shots(.4)
 check(is_equal_approx(cannons_before-w.cannon_hp326[0]-w.cannon_hp326[1],7.),"redirect reaches other cannon through actual physics")
 check(not w.shots.has(shot) and is_equal_approx(hp_before-w.fastener_hp321,10.),"second contact retires and original castle hit is not duplicated")
 w._clear_combat_shots()
 for index in [0,1]:w.cannon_hp326[index]=0.
 var aliases: Array[RID]=w.structure_aliases340(area)
 var reflected: Vector3=w.bounce_direction340(at,Vector3.FORWARD,Vector3.BACK,aliases)
 check(reflected.dot(Vector3.BACK)>.99,"isolated structure reflects away rather than back into itself")
 for file in config_before:
  check(FileAccess.get_file_as_bytes(cfg_folder+file).hex_encode().sha256_text()==config_before[file],"config changed "+file)
 save339(true)
 print("DPS340_DONE samples=",samples.size()," failures=",failures.size())
 Engine.time_scale=1.
 quit(0 if failures.is_empty() else 1)
