extends "res://scripts/world/combat111_probe.gd"
class Cost:
 extends Battle111
 var no_shadow := false
 var no_steer := false
 var totals := Vector3.ZERO
 var physics_count := 0
 func _draw_projectile_shadows105() -> void:
  if no_shadow:
   if is_instance_valid(shadow_batch110): shadow_batch110.multimesh.visible_instance_count=0
   return
  super._draw_projectile_shadows105()
 func _steer_shot(shot: Dictionary,delta: float) -> void:
  if not no_steer: super._steer_shot(shot,delta)
 func _step_shots(delta: float) -> void:
  var time := Time.get_ticks_usec();super._step_shots(delta);totals.x+=Time.get_ticks_usec()-time
 func _physics_process(delta: float) -> void:
  var time := Time.get_ticks_usec();super._physics_process(delta);totals.y+=Time.get_ticks_usec()-time;physics_count+=1
 func _process(delta: float) -> void:
  var time := Time.get_ticks_usec();super._process(delta);totals.z+=Time.get_ticks_usec()-time
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var s := Cost.new();root.add_child(s)
 while not s.woodland_ready111: await physics_frame
 s.permit=true;s.start_combat()
 for enemy in s.enemies:
  if is_instance_valid(enemy): s.remove_child(enemy);enemy.queue_free()
 s.enemies.clear();s._spawn_wave110(5)
 for enemy in s.enemies: enemy.hp=1000000.;enemy.max_hp110=1000000.
 for id in ["forest_fireboy","three_player","distract","distract","eye_exercise","eye_exercise","snack","snack","music_class","music_class","music_class"]: s.buffs.apply(id)
 s._apply_owned_buffs();s._teleport15(s.meadow.landmarks.grove+Vector2(0,2));s.hero.controls_enabled=true;s.shooting=true;s.fire_needs_release=false
 root.warp_mouse(s.camera.unproject_position(s.enemies[0].position+Vector3.UP*.8));await settle72(80)
 for mode in ["full","no_shadows","no_tracking"]:
  s.no_shadow=mode!="full";s.no_steer=mode=="no_tracking"
  s.totals=Vector3.ZERO;s.physics_count=0
  var previous := Time.get_ticks_usec();var times: Array[float]=[]
  for i in 180:
   await process_frame;var now := Time.get_ticks_usec();times.append((now-previous)/1000.);previous=now
  times.sort();print("COST111 ",mode," median=",times[90]," shots=",s.shots.size()," physics=",s.physics_count," us=",s.totals)
 quit()
