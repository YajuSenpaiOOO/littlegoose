extends "res://scripts/world/combat110_probe.gd"
class Instrumented:
 extends Battle110
 var costs := {}
 var skip_tracking := false
 var silent_hits := false
 func record_cost(key: String,start: int) -> void:
  var item: Vector3=costs.get(key,Vector3.ZERO);var dt := Time.get_ticks_usec()-start;item.x+=dt;item.y+=1;item.z=maxf(item.z,dt);costs[key]=item
 func _step_shots(delta: float) -> void:
  var t := Time.get_ticks_usec();super._step_shots(delta);record_cost("step_shots",t)
 func _steer_shot(shot: Dictionary,delta: float) -> void:
  if skip_tracking: return
  var t := Time.get_ticks_usec();super._steer_shot(shot,delta);record_cost("homing",t)
 func _trace_shot(shot: Dictionary,a: Vector3,b: Vector3) -> Dictionary:
  var t := Time.get_ticks_usec();var result := super._trace_shot(shot,a,b);record_cost("native_trace",t);return result
 func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
  if silent_hits:
   if hit.collider.has_meta("enemy"): hit.collider.get_meta("enemy").hp-=damage_for_shot(shot)
   return
  var t := Time.get_ticks_usec();super._apply_shot_hit(shot,hit);record_cost("hit_and_feedback",t)
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._physics_process(delta);record_cost("world_physics",t)
 func _process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._process(delta);record_cost("world_render",t)
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var s := Instrumented.new();root.add_child(s)
 while not s.woodland_ready110: await physics_frame
 s.permit=true;s.start_combat()
 for enemy in s.enemies:
  if is_instance_valid(enemy): s.remove_child(enemy);enemy.queue_free()
 s.enemies.clear();s._spawn_wave110(5)
 for enemy in s.enemies: enemy.hp=1000000.;enemy.max_hp110=1000000.
 for id in ["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","flashlight"]: s.buffs.apply(id)
 s._apply_owned_buffs();s._teleport15(s.meadow.landmarks.grove+Vector2(0,2));s.hero.controls_enabled=true;s.shooting=true
 root.warp_mouse(s.camera.unproject_position(s.enemies[0].position+Vector3.UP*.8));await settle72(100)
 for mode in ["all","no_tracking","no_hit_fx","no_art"]:
  s.skip_tracking=mode!="all";s.silent_hits=mode in ["no_hit_fx","no_art"]
  if mode=="no_art": s.skills110.set_process(false);s.skills110.hide()
  s.costs.clear();var previous := Time.get_ticks_usec();var times: Array[float]=[]
  for i in 140:
   await process_frame;var now := Time.get_ticks_usec();times.append((now-previous)/1000.);previous=now
  times.sort();print("COMPONENT110 ",mode," median=",times[70]," shots=",s.shots.size()," costs=",s.costs)
 quit()
