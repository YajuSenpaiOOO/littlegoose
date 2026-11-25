extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world375.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.companion373) or not w.companion373.ready373:await physics_frame
 var c=w.companion373;c.hold373();w.hero.set_physics_process(false);w.hero.set_process(false)
 var phase: float=c.gait375
 for i in 120:await physics_frame
 var stopped: bool=is_equal_approx(c.gait375,phase)
 w.hero.global_position=Vector3(-3.,.05,2.8);w.hero.reset_physics_interpolation();c.resume373()
 var start: float=c.walked375;var motion:=0;var changes:=0;var last: Texture2D=null
 for i in 500:
  var before: Vector3=c.global_position
  await physics_frame
  if Vector2(c.global_position.x-before.x,c.global_position.z-before.z).length()>.0005:
   motion+=1
   if c.visual.texture!=last:changes+=1;last=c.visual.texture
  if c.global_position.distance_to(w.hero.global_position)<1.:break
 var walked: float=c.walked375-start
 var expected: float=fposmod(phase+walked/(4.1/1.05),1.)
 var ok: bool=stopped and walked>2. and absf(expected-c.gait375)<.0001 and changes<=int(ceil(walked*4./c.CYCLE_DISTANCE375))+2
 var report={"pass":ok,"stopped_phase_stable":stopped,"meters":walked,"walk_physics_frames":motion,"new_frame_changes":changes,"old_8hz_estimate":float(motion)/60.*8.,"expected_phase":expected,"actual_phase":c.gait375,"frames_per_meter":4./c.CYCLE_DISTANCE375,"hero_frames_per_meter":4.*1.05/4.1}
 var file:=FileAccess.open("res://docs/room375-pace-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
 print("PACE375 ",report);quit(0 if ok else 1)
