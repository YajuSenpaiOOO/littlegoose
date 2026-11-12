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
 extends "res://scripts/world/woodland_world341.gd"
 var contact341: Dictionary={}
 var build_sum341:=0
 func redirect275(shot: Dictionary,hit: Dictionary,damage: float) -> void:
  contact341={"normal":hit.get("normal",Vector3.ZERO),"incoming":shot.velocity,"position":hit.position}
  super.redirect275(shot,hit,damage)
 var legacy341:=false
 var chain_sum341:=0
 var chain_peak341:=0
 var frame_count341:=0
 var step_us341:=0
 var step_count341:=0
 func inherit_split153(shot: Dictionary, split: Dictionary) -> void:
  super.inherit_split153(shot,split)
  if legacy341 and shot.get("stream110",false):
   shot.stream_generation110=split_generation234
   shot.stream_sequence110=0
   shot.erase("stream_joint275")
 func _step_shots(delta: float) -> void:
  var begin:=Time.get_ticks_usec()
  super._step_shots(delta)
  if measuring339:
   step_us341+=Time.get_ticks_usec()-begin
   step_count341+=1
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
  if measuring339 and beam_active288():
   chain_sum341+=skills110.chains110.size()
   build_sum341+=skills110.build_us263
   chain_peak341=maxi(chain_peak341,skills110.chains110.size())
   frame_count341+=1
var w: Node3D
var samples: Array[Dictionary]=[]
var failures: Array[String]=[]
var config_before: Dictionary={}
func _initialize() -> void:call_deferred("run")
func check(ok: bool,message: String) -> void:
 if not ok:failures.append(message);push_error(message)
func save339(complete: bool) -> void:
 var data={"schema":1,"complete":complete,"failures":failures,"conditions":{"runtime":"woodland_world341.gd","static_real_castle":true,"cannon_fixture":"castle only for visual comparison, cannons enabled for angular steering assertions","duration_seconds":10.,"clock":"unpaused scaled physics; Q transformation intro excluded","physics_step":1./60.,"engine_scale":2.,"physics_ticks_per_second":120,"castle_hp":1000000.,"enemy_attacks":false,"hero_stationary":true,"hitstop_and_paper_hit_art":false,"not_survival_or_clear_time_test":true,"target":"central wall bay","seeds":[34101],"hero_moment":false,"q_counts_per_sample":true},"samples":samples}
 FileAccess.open("res://docs/paper341-smoke.json" if "--smoke341" in OS.get_cmdline_user_args() else "res://docs/paper341-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
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
 if not is_instance_valid(w.structure_ui335):failures.append("init timeout");save339(false);quit(1);return
 w.hero.set_physics_process(false)
 w.theatre314.set_process(false)
 var builds=[{"id":"light_snack_clone","levels":{"flashlight":1,"snack":1,"forest_fireboy":1},"q":true},{"id":"light_snack","levels":{"flashlight":1,"snack":1},"q":true}]
 if "--smoke341" in OS.get_cmdline_user_args():await measure339({"id":"base","levels":{}},6.,34101,.1)
 for legacy in ([] if "--smoke341" in OS.get_cmdline_user_args() else [true,false]):
  w.legacy341=legacy
  for build in builds:
   w.build_sum341=0;w.chain_sum341=0;w.chain_peak341=0;w.frame_count341=0;w.step_us341=0;w.step_count341=0
   await measure339(build,6.,34101,10.)
   samples[-1].legacy_split_visual=legacy
   samples[-1].mean_beam_build_us=float(w.build_sum341)/maxi(1,w.frame_count341)
   samples[-1].beam_mean_ribbons=float(w.chain_sum341)/maxi(1,w.frame_count341)
   samples[-1].beam_peak_ribbons=w.chain_peak341
   samples[-1].mean_shot_step_us=float(w.step_us341)/maxi(1,w.step_count341)
 for i in (0 if "--smoke341" in OS.get_cmdline_user_args() else 2):
  check(absf(samples[i].damage-samples[i+2].damage)<samples[i].damage*.01,"visual batching preserves damage "+str(i))
  check(samples[i+2].beam_peak_ribbons<samples[i].beam_peak_ribbons,"fewer split ribbons "+str(i))
 w.legacy341=false
 w._clear_combat_shots()
 w.buffs.levels={"bouncy_ball":1}
 w.cannon_hp326.assign([1000000.,1000000.])
 w.theatre314.enable_cannons326(true)
 await settle339()
 var area: Area3D=w.theatre314.castle_target327
 var at: Vector3=area.get_child(2).global_position
 var shot: Dictionary=w.data_shot110(at+Vector3.BACK*.5,Vector3.FORWARD*20.,2.)
 shot.fixed_damage110=10.;shot.final_damage234=true
 var node=shot.node
 var fired: int=w.fired_count
 w._step_shots(.04)
 check(w.shots.has(shot) and shot.node==node and w.fired_count==fired,"same projectile after impact")
 var ignored: Array[RID]=[]
 var expected: Vector3=w.bounce_direction340(w.contact341.position,w.contact341.incoming,w.contact341.normal,ignored)
 print("REFLECT341 ",w.contact341," velocity=",shot.velocity," expected=",expected)
 check(shot.velocity.normalized().dot(expected)>.999,"actual contact follows normal despite nearby cannon")
 check(absf(shot.velocity.y)<.001 and shot.velocity.z>19.99,"camera-facing wall stays horizontal in gameplay")
 check(is_equal_approx(shot.velocity.length(),20.) and is_equal_approx(shot.fixed_damage110,7.),"speed and seventy percent damage")
 check(shot.ignore_rids110.has(area.get_rid()) and shot.ignore_rids110.has(w.theatre314.bodies[0].get_parent().get_rid()),"structure aliases ignored")
 var velocity: Vector3=shot.velocity
 w.steer_ball341(shot,.02)
 check(shot.velocity==velocity,"no eye no steering")
 # Put a living cannon inside the forward cone; the previous castle remains excluded.
 var target: Vector3=w.theatre314.cannon_areas326[0].global_position
 shot.node.at=target+Vector3(1.,0.,3.)
 shot.velocity=Vector3.FORWARD*20.
 w.buffs.levels["eye_exercise"]=1
 var old: Vector3=shot.velocity
 w.steer_ball341(shot,.02)
 var turn:=Vector2(old.x,old.z).angle_to(Vector2(shot.velocity.x,shot.velocity.z))
 check(absf(turn)>.001 and absf(turn)<=.0501,"eye gradually turns rebound within 2.5rad per second")
 check(is_equal_approx(shot.velocity.length(),20.),"eye steering preserves speed")
 # Beam continuity fixture: 12 consecutive pulses in six branches.
 w._clear_combat_shots()
 w.buffs.levels={}
 for pulse in 12:
  var split={"at":at,"payload234":{"stream":true,"heavy":false,"lane":0,"charged":false,"note":false,"snack":1,"tracking":0},"path341":"fixture","sequence341":pulse,"branch341":0}
  for branch in 6:
   var direction:=Vector3(cos(TAU*branch/6.),0.,sin(TAU*branch/6.))
   var beam: Dictionary=w.data_shot110(at+direction*(.2+pulse*.05),direction*10.,1.)
   w.inherit_split153(beam,split)
 w.skills110.build_chains110()
 check(w.skills110.chains110.size()==6,"72 samples produce six connected branches")
 for chain in w.skills110.chains110:check(chain.points.size()>2,"branch is a continuous polyline")
 w._clear_combat_shots()
 check(w.split_keys341.is_empty(),"beam grouping reset")
 for file in config_before:check(FileAccess.get_file_as_bytes(cfg_folder+file).hex_encode().sha256_text()==config_before[file],"config unchanged "+file)
 save339(true)
 print("PAPER341_DONE failures=",failures)
 Engine.time_scale=1.
 quit(0 if failures.is_empty() else 1)
