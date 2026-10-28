extends "res://scripts/world/station85_probe.gd"
func measure86(sample: Node3D) -> Dictionary:
 var values: Array[float]=[]
 var cpu: Array[float]=[]
 var physics: Array[float]=[]
 for i in 24: await process_frame
 var last := Time.get_ticks_usec()
 for i in 120:
  await process_frame
  var now := Time.get_ticks_usec();values.append((now-last)/1000.);last=now
  cpu.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.)
  physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.)
 values.sort();cpu.sort();physics.sort()
 return {"median":values[60],"p95":values[114],"cpu":cpu[60],"physics":physics[60],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size)
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED);Engine.max_fps=0
 var sample := Sample85.new();root.add_child(sample)
 while not is_instance_valid(sample.station81): await physics_frame
 await settle72(25)
 for x in [3.2,4.8,7.,10.]:
  var at := await press85(sample,Vector2(x,-49.),Vector2.DOWN)
  print("NORTH_WALL86 ",x," ",at," floor=",sample.floor_height(Vector2(at.x,at.z)))
 sample.hero.controls_enabled=false;sample._teleport15(Vector2(8.4,-42.9));await settle72(30)
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 var results := {}
 results.baseline=await measure86(sample)
 sample.time55.noon_enabled85=false;sample.time55.apply_look();results.no_noon=await measure86(sample)
 sample.time55.noon_enabled85=true;sample.time55.apply_look()
 var focus: ShaderMaterial=sample.atmosphere41.focus_material
 focus.set_shader_parameter("radius_pixels",0.);results.no_dof=await measure86(sample)
 focus.set_shader_parameter("radius_pixels",6.2)
 sample.sun.shadow_enabled=false;results.no_sun_shadows=await measure86(sample);sample.sun.shadow_enabled=true
 for batch in sample.grass_batches: batch.node.hide()
 results.no_grass=await measure86(sample)
 for batch in sample.grass_batches: batch.node.show()
 sample.rail72.get_node("FrontWallCollision85").process_mode=Node.PROCESS_MODE_DISABLED
 sample.rail72.get_node("MossWallCollision85").process_mode=Node.PROCESS_MODE_DISABLED
 for name in ["FrontWallCollision85","MossWallCollision85"]:
  for shape in sample.rail72.get_node(name).get_children(): shape.disabled=true
 results.no_wall_collision=await measure86(sample)
 var file := FileAccess.open("res://docs/diagnostic86.json",FileAccess.WRITE);file.store_string(JSON.stringify(results,"\t"))
 print("DIAGNOSTIC86 ",JSON.stringify(results));quit()
