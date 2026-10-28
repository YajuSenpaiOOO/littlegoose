extends "res://scripts/world/woodland103_probe.gd"
func measure104(sample: Node3D,tag: String,walking := false,frames := 180) -> Dictionary:
 var times: Array[float]=[];var cpu: Array[float]=[];var physics: Array[float]=[];var gpu: Array[float]=[]
 var previous := Time.get_ticks_usec();var g: Vector2=sample.meadow.landmarks.grove
 for i in frames:
  if walking:
   var target := g+Vector2(3.,5.) if i<frames/2 else g+Vector2(-3.,6.)
   sample.hero.wish=(target-Vector2(sample.hero.position.x,sample.hero.position.z)).normalized()
  await process_frame
  var now := Time.get_ticks_usec();times.append(float(now-previous)/1000.);previous=now
  cpu.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.);physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.)
  if RenderingServer.has_method("viewport_get_measured_render_time_gpu"): gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid()))
 sample.hero.wish=Vector2.ZERO
 times.sort();cpu.sort();physics.sort();gpu.sort();var slow := 0
 for value in times:
  if value>33.3: slow+=1
 var result := {"median_ms":times[frames/2],"p95_ms":times[int(frames*.95)],"p99_ms":times[int(frames*.99)],"max_ms":times[-1],"over33":slow,"cpu_median_ms":cpu[frames/2],"cpu_p99_ms":cpu[int(frames*.99)],"physics_median_ms":physics[frames/2],"gpu_median_ms":gpu[frames/2] if gpu.size()>0 else -1.,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)}
 print("PROFILE104 ",tag," ",JSON.stringify(result));return result
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size)
 if RenderingServer.has_method("viewport_set_measure_render_time"): RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 var sample := Sample103.new();root.add_child(sample)
 while not sample.woodland_ready103: await physics_frame
 await settle72(30);sample.label.get_parent().hide();sample.frames66.panel.hide()
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample.details101.audio.set_enabled(false)
 var g: Vector2=sample.meadow.landmarks.grove;sample._teleport15(g+Vector2(.5,7.8));sample.hero.controls_enabled=true;await settle72(45)
 var data := {"window":str(root.size),"viewport":str(root.get_texture().get_size()),"renderer":RenderingServer.get_current_rendering_method()}
 data["vsync_static"]=await measure104(sample,"vsync_static")
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);await settle72(20)
 data["baseline_static"]=await measure104(sample,"baseline_static")
 sample.time55.focus_mode86=2;sample.time55.apply_look();await settle72(20)
 data["no_dof"]=await measure104(sample,"no_dof")
 sample.atmosphere41.focus_card.hide();await settle72(20)
 data["no_post"]=await measure104(sample,"no_post")
 sample.atmosphere41.focus_card.show();sample.time55.focus_mode86=0;sample.time55.apply_look()
 var shadow: bool=sample.sun.shadow_enabled;sample.sun.shadow_enabled=false;await settle72(20)
 data["no_native_shadow"]=await measure104(sample,"no_native_shadow")
 sample.sun.shadow_enabled=shadow
 for batch in sample.grass_batches: batch.node.hide()
 await settle72(20);data["no_grass"]=await measure104(sample,"no_grass")
 for batch in sample.grass_batches: batch.node.show()
 sample.forest87.set_process(false);sample.effect_scope95.set_process(false);await settle72(20)
 data["no_plant_cpu"]=await measure104(sample,"no_plant_cpu")
 sample.forest87.set_process(true);sample.effect_scope95.set_process(true)
 sample._teleport15(g+Vector2(.5,7.8));await settle72(20)
 data["walking_first"]=await measure104(sample,"walking_first",true,240)
 sample._teleport15(g+Vector2(.5,7.8));await settle72(20)
 data["walking_repeat"]=await measure104(sample,"walking_repeat",true,240)
 sample.permit99=true;sample.start_combat(true);await settle72(80)
 data["combat"]=await measure104(sample,"combat",false,240)
 sample.time55.focus_mode86=2;sample.time55.apply_look();await settle72(20)
 data["combat_no_dof"]=await measure104(sample,"combat_no_dof",false,240)
 var file := FileAccess.open("res://docs/woodland104-profile.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("PROFILE104_DONE ",JSON.stringify(data));quit()
