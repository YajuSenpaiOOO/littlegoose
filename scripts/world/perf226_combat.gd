extends SceneTree
class TimedWorld:
 extends "res://scripts/world/woodland_world226.gd"
 var process_us226=0
 var process_count226=0
 var physics_us226=0
 var physics_count226=0
 var air_camera226=true
 var disable_sword_shadows226=false
 var quiet_feedback226=false
 var no_hitstop226=false
 func on_legacy_contact(enemy: CharacterBody3D,contact: Vector3,direction: Vector3,juice: bool) -> void:
  if quiet_feedback226:notify_hit()
  else:super.on_legacy_contact(enemy,contact,direction,juice)
 func hitstop(duration: float,force := false) -> void:
  if not no_hitstop226:super.hitstop(duration,force)
 func air_camera_enabled149() -> bool:return air_camera226
 func _process(delta: float) -> void:
  var before=Time.get_ticks_usec();super._process(delta);process_us226+=Time.get_ticks_usec()-before;process_count226+=1
  if disable_sword_shadows226 and is_instance_valid(swords153):
   for shadow in actor_shadows:
    if is_instance_valid(shadow) and swords153.is_ancestor_of(shadow):shadow.enabled=false;shadow.hide();shadow.set_process(false);shadow.set_physics_process(false)
 func _physics_process(delta: float) -> void:
  var before=Time.get_ticks_usec();super._physics_process(delta);physics_us226+=Time.get_ticks_usec()-before;physics_count226+=1
var w: Node3D
var results: Array=[]
var timing226 := {}
var timing_last226 := 0
class Marker:
 extends Node
 var owner226
 var key226: int
 func _process(_delta: float) -> void:
  var now=Time.get_ticks_usec()
  if key226!=-1000:
   if not owner226.timing226.has(key226):owner226.timing226[key226]=[0,0]
   owner226.timing226[key226][0]+=now-owner226.timing_last226;owner226.timing226[key226][1]+=1
  owner226.timing_last226=now
func _initialize() -> void:call_deferred("run")
func sample(tag: String,seconds: float=4.) -> void:
 await create_timer(.5).timeout
 w.process_us226=0;w.process_count226=0;w.physics_us226=0;w.physics_count226=0
 timing226.clear()
 var start=Time.get_ticks_usec();var previous=start;var gaps: Array[float]=[];var cpu: Array[float]=[];var draws: Array[float]=[]
 while Time.get_ticks_usec()-start<seconds*1000000.:
  await process_frame
  var now=Time.get_ticks_usec();gaps.append(float(now-previous)/1000.);previous=now
  cpu.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.);draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
 gaps.sort();cpu.sort();draws.sort()
 var row={"tag":tag,"frames":gaps.size(),"fps":gaps.size()*1000000./maxf(1.,Time.get_ticks_usec()-start),"median_ms":gaps[gaps.size()/2],"p95_ms":gaps[int(gaps.size()*.95)],"process_ms":cpu[cpu.size()/2],"draws":draws[draws.size()/2],"world_process_ms":w.process_us226/1000./maxi(1,w.process_count226),"world_physics_ms":w.physics_us226/1000./maxi(1,w.physics_count226),"planes":w.paper_memories146.planes149.size(),"shots":w.shots.size(),"shadows":w.actor_shadows.size(),"resting_swords":w.swords153.resting153.size(),"flying_swords":w.swords153.flying153.size()}
 results.append(row);print("PERF226 ",JSON.stringify(row))
 var times={}
 for key in timing226:times[str(key)]=timing226[key][0]/1000./maxi(1,timing226[key][1])
 row["priority_times_ms"]=times;print("TIMINGS226 ",tag," ",times)
 row["render_cpu_ms"]=RenderingServer.viewport_get_measured_render_time_cpu(root.get_viewport_rid())
 row["render_gpu_ms"]=RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid())
 row["render_setup_ms"]=RenderingServer.get_frame_setup_time_cpu()
 print("RENDER226 ",tag," cpu=",row.render_cpu_ms," gpu=",row.render_gpu_ms," setup=",row.render_setup_ms)
func run() -> void:
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 w=TimedWorld.new();root.add_child(w);current_scene=w
 while not w.ready226:await process_frame
 for priority in [-1000,1,79,81,89,91,99,101,109,111,200]:
  var marker=Marker.new();marker.process_priority=priority;marker.key226=priority;marker.owner226=self;root.add_child(marker)
 if "--timing-diagnose" in OS.get_cmdline_user_args():
  w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
  await sample("idle_priority_timing",4.)
  w.auto114=true
  await sample("attack_priority_timing",6.)
  FileAccess.open("res://docs/perf226-priorities.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"));quit();return
 if "--fixed-combat" in OS.get_cmdline_user_args():
  w.start_battle225(false);w.auto114=false;w.invulnerability=10000.;w.cat220.hp=100000.;w.cat220.max_hp110=100000.
  await sample("fixed_manual_idle_live_cat_pig",6.)
  w.auto114=true
  await sample("fixed_live_cat_pig_aircraft_sword",14.)
  FileAccess.open("res://docs/perf226-fixed-combat.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"));quit();return
 if "--fx-diagnose" in OS.get_cmdline_user_args():
  w.start_battle225(false);w.auto114=true;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
  await sample("all_feedback_on",6.)
  w.quiet_feedback226=true
  await sample("impact_break_audio_off",4.)
  w.no_hitstop226=true;w.stop_until=0.;Engine.time_scale=1.
  await sample("hitstop_off",4.)
  w.paper_memories146.art146.hide();w.paper_memories146.hud146.hide()
  await sample("paper_ground_marks_off",4.)
  w.swords153.hide()
  await sample("swords_hidden_while_firing",4.)
  FileAccess.open("res://docs/perf226-fx-diagnose.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"));quit();return
 if "--camera-diagnose" in OS.get_cmdline_user_args():
  w.start_battle225(false);w.auto114=true;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
  await sample("aircraft_wide_camera",6.)
  w.air_camera226=false
  await sample("aircraft_normal_camera",6.)
  w.disable_sword_shadows226=true
  await sample("aircraft_normal_camera_sword_shadows_off",6.)
  FileAccess.open("res://docs/perf226-camera-diagnose.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"));quit();return
 if "--sword-diagnose" in OS.get_cmdline_user_args():
  w.start_battle225(false);w.auto114=true;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false);w.cat220.hp=100000.;w.cat220.max_hp110=100000.
  await sample("user_sword_build",8.)
  for shadow in w.actor_shadows:
   if is_instance_valid(shadow) and w.swords153.is_ancestor_of(shadow):shadow.enabled=false;shadow.hide();shadow.set_process(false);shadow.set_physics_process(false)
  # Stop births so this A/B keeps the same objects; retain live landed visuals.
  w.auto114=false
  await sample("sword_shadows_off",2.)
  w.swords153.hide()
  await sample("sword_visuals_off",2.)
  FileAccess.open("res://docs/perf226-sword-diagnose.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"));quit();return
 await sample("door")
 w.start_battle225(false);w.auto114=false;w.pigs_enabled220=false;w.invulnerability=10000.;w.cat220.set_physics_process(false)
 await sample("battle_idle")
 w.encounter_hud.set_process(false)
 await sample("battle_hud_update_off")
 w.guide206.hide();w.encounter_hud.hide()
 await sample("battle_text_hidden")
 w.encounter_hud.set_process(true);w.guide206.show();w.auto114=true;w.cat220.hp=100000.;w.cat220.max_hp110=100000.
 await sample("battle_aircraft",8.)
 w.encounter_hud.set_process(false)
 await sample("aircraft_hud_update_off")
 w.auto114=false;w._clear_combat_shots();w.levels226={"three_player":1,"eye_exercise":1};w.apply_levels226();w.auto114=true
 await sample("direct_hud_update_off",6.)
 FileAccess.open("res://docs/perf226-combat.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"))
 quit()
