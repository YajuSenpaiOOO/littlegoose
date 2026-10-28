extends "res://scripts/world/woodland104_probe.gd"
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
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 var sample := Sample104.new();root.add_child(sample)
 while not sample.woodland_ready104: await physics_frame
 await settle72(30);sample.label.get_parent().hide();sample.frames66.panel.hide();sample.details101.audio.set_enabled(false)
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 var g: Vector2=sample.meadow.landmarks.grove;var data := {}
 root.warp_mouse(Vector2(1280,747))
 for mode in [0,1,2,0,2]:
  sample.fast_aim104=mode>0;sample.set_shadow_quality104(mode<2);sample.set_grade104(mode==2)
  sample._teleport15(g+Vector2(.5,7.8));sample.hero.controls_enabled=true;await settle72(40)
  var tag := str(mode)+"_"+str(data.size())
  data[tag+"_static"]=await measure104(sample,tag+"_static")
  data[tag+"_walk"]=await measure104(sample,tag+"_walk",true,240)
 sample.permit99=true;sample.start_combat(true);await settle72(80)
 for mode in [0,2,0,2]:
  sample.fast_aim104=mode>0;sample.set_shadow_quality104(mode==0);sample.set_grade104(mode>0);await settle72(20)
  var tag := str(mode)+"_combat_"+str(data.size());data[tag]=await measure104(sample,tag,false,240)
 var file := FileAccess.open("res://docs/woodland104-ab.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("AB104_DONE");quit()
