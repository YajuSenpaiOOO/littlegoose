extends "res://scripts/world/woodland106_probe.gd"
func sample106(sample: Node3D,tag: String,centre: Vector2,walking := false,frames := 360) -> Dictionary:
 var t := Time.get_ticks_usec();var times: Array[float]=[];var d: Node3D=sample.details101;var updates: int=d.leaf_updates102;var events: int=d.audio.rustle_events102;var near := 0
 for i in frames:
  if walking:
   var target := centre+Vector2(0,.65 if i%90<45 else -.65)
   sample.hero.wish=(target-Vector2(sample.hero.position.x,sample.hero.position.z)).limit_length(1.)
   if Vector2(sample.hero.position.x,sample.hero.position.z).distance_to(centre)<.6: near+=1
  await process_frame
  var now := Time.get_ticks_usec();times.append((now-t)/1000.);t=now
 sample.hero.wish=Vector2.ZERO;times.sort()
 var data := {"median_ms":times[frames/2],"p95_ms":times[int(frames*.95)],"max_ms":times[-1],"leaf_updates":d.leaf_updates102-updates,"rustle_events":d.audio.rustle_events102-events,"near_pile_frames":near,"active_lights":sample.lamps106.active106,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
 print("PROFILE106 ",tag," ",JSON.stringify(data));return data
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var sample := Sample106.new();root.add_child(sample)
 while not sample.woodland_ready106: await physics_frame
 await settle72(30);var d: Node3D=sample.details101;var g: Vector2=sample.meadow.landmarks.grove
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 var originals: Array=d.leaf_states102.duplicate(true);var centre: Vector2=g+d.leaf_states102[24].at
 sample._teleport15(centre+Vector2(0,.65));sample.hero.controls_enabled=true;await settle72(20)
 var data := {};d.reactive_reference106=true;data.reactive_muted=await sample106(sample,"reactive_muted",centre,true)
 d.reactive_reference106=false;d.leaf_states102=originals
 for leaf in d.leaf_states102: d._leaf_pose102(leaf)
 sample._teleport15(centre+Vector2(0,.65));sample.hero.controls_enabled=true;await settle72(20)
 data.static_muted=await sample106(sample,"static_muted",centre,true)
 sample.hero.controls_enabled=false;sample._teleport15(g+sample.PARK99.BENCH+Vector2(-1,2.8));sample.time55.preview_at(20.);sample.time55.visual_hour=20.;sample.time55.apply_look();await settle72(30)
 for enabled in [false,true,false]:
  sample.lamps106.enabled106=enabled;sample.lamps106.update106();await settle72(15)
  var tag := "lamps_"+str(enabled)+"_"+str(data.size());data[tag]=await sample106(sample,tag,centre,false,240)
 var file := FileAccess.open("res://docs/woodland106-profile.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("PROFILE106_DONE");quit()
