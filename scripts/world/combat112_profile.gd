extends "res://scripts/world/combat111_compare.gd"
class Profile112:
 extends Battle111
 var physics_us := 0
 var render_us := 0
 var shot_us := 0
 var physics_steps := 0
 func _physics_process(delta: float) -> void:
  var started := Time.get_ticks_usec();super._physics_process(delta);physics_us+=Time.get_ticks_usec()-started;physics_steps+=1
 func _process(delta: float) -> void:
  var started := Time.get_ticks_usec();super._process(delta);render_us+=Time.get_ticks_usec()-started
 func _step_shots(delta: float) -> void:
  var started := Time.get_ticks_usec();super._step_shots(delta);shot_us+=Time.get_ticks_usec()-started
func measure112(s: Node3D,tag: String) -> Dictionary:
 await settle72(30)
 s.physics_us=0;s.render_us=0;s.shot_us=0;s.physics_steps=0
 var times: Array[float]=[];var gpu: Array[float]=[];var render_cpu: Array[float]=[];var processes: Array[float]=[];var physics: Array[float]=[]
 var previous := Time.get_ticks_usec();var peak := 0
 for i in 240:
  if s.process_mode!=Node.PROCESS_MODE_DISABLED:
   root.warp_mouse(s.camera.unproject_position(s.enemies[0].position+Vector3.UP*.8))
  await process_frame
  var now := Time.get_ticks_usec();times.append((now-previous)/1000.);previous=now;peak=maxi(peak,s.shots.size())
  gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid()))
  render_cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(root.get_viewport_rid()))
  processes.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000.)
  physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000.)
 times.sort();gpu.sort();render_cpu.sort();processes.sort();physics.sort()
 var data := {"median_ms":times[120],"p95_ms":times[228],"gpu_ms":gpu[120],"render_cpu_ms":render_cpu[120],"process_ms":processes[120],"physics_ms":physics[120],"world_process_ms_per_frame":s.render_us/240000.,"world_physics_ms_per_frame":s.physics_us/240000.,"shots_ms_per_frame":s.shot_us/240000.,"physics_steps":s.physics_steps,"peak_shots":peak,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}
 print("PROFILE112 ",tag," ",JSON.stringify(data));return data
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(),true)
 var s := Profile112.new();await setup(s,"woodland_ready111")
 var data := {}
 s.shooting=false;data.normal_high=await measure112(s,"normal_high")
 build(s,["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"])
 data.six_high=await measure112(s,"six_high")
 root.size=Vector2i(1280,747);DisplayServer.window_set_size(root.size)
 data.six_half=await measure112(s,"six_half")
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size)
 s.shooting=false;s._clear_combat_shots();s.skills110.reset110();await settle72(10)
 s.process_mode=Node.PROCESS_MODE_DISABLED
 data.frozen_high=await measure112(s,"frozen_high")
 root.size=Vector2i(1280,747);DisplayServer.window_set_size(root.size)
 data.frozen_half=await measure112(s,"frozen_half")
 var file := FileAccess.open("res://docs/combat112-profile.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));quit()
