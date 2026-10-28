extends SceneTree
# Perf reproduction probe: measures real frame times, draw calls and node
# census at fixed spots. Shared base for perf204_probe / perf169_probe.
# Runs windowed with vsync off so the uncapped frame cost is visible.
var sample: Node3D
var report := {"meta": {}, "census": {}, "spots": []}

func world_script_perf() -> Script: return null
func out_path_perf() -> String: return "res://docs/perf-report.json"
func prefix_perf() -> String: return "perf"

func _initialize() -> void:
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 run.call_deferred()

func settle(frames := 12) -> void:
 for i in frames: await physics_frame

func ready_flag_perf() -> bool:
 var hero: Node = sample.get("hero")
 return hero != null and is_instance_valid(hero)

func hour(value: float) -> void:
 var time: Node = sample.get("time55")
 if time == null: return
 if time.has_method("preview_at"): time.preview_at(value)
 time.visual_hour=value
 if time.has_method("apply_look"): time.apply_look()
 await settle(150)

func measure(tag: String, min_frames := 120, min_seconds := 2.0) -> Dictionary:
 var entry := {"tag": tag}
 await settle(30)
 var process_acc := 0.;var physics_acc := 0.
 var draw_acc := 0;var draw_n := 0;var draw_max := 0;var prim_max := 0;var obj_max := 0
 var active3d_max := 0;var pairs3d_max := 0
 var t0 := Time.get_ticks_usec();var last := t0;var max_gap_us := 0;var long_frames := 0;var frames := 0
 while frames<min_frames or Time.get_ticks_usec()-t0<int(min_seconds*1000000.):
  await process_frame
  frames+=1
  var now := Time.get_ticks_usec();var gap := now-last;last=now
  if frames>5:
   max_gap_us=maxi(max_gap_us,gap)
   if gap>50000: long_frames+=1
  process_acc+=Performance.get_monitor(Performance.TIME_PROCESS)
  physics_acc+=Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
  var draw := int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
  draw_acc+=draw;draw_n+=1;draw_max=maxi(draw_max,draw)
  prim_max=maxi(prim_max,int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)))
  obj_max=maxi(obj_max,int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)))
  active3d_max=maxi(active3d_max,int(Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS)))
  pairs3d_max=maxi(pairs3d_max,int(Performance.get_monitor(Performance.PHYSICS_3D_COLLISION_PAIRS)))
 var total_us := Time.get_ticks_usec()-t0
 entry.frames=frames
 entry.avg_ms=float(total_us)/1000./float(frames)
 entry.fps=1000./entry.avg_ms
 entry.max_gap_ms=float(max_gap_us)/1000.
 entry.long_frames_over_50ms=long_frames
 entry.engine_fps=Engine.get_frames_per_second()
 entry.time_process_avg=process_acc/float(frames)
 entry.time_physics_avg=physics_acc/float(frames)
 entry.draw_avg=float(draw_acc)/float(draw_n)
 entry.draw_max=draw_max
 entry.primitives_max=prim_max
 entry.objects_max=obj_max
 entry.physics3d_active_max=active3d_max
 entry.physics3d_pairs_max=pairs3d_max
 report.spots.append(entry)
 print("PERF_SPOT ",JSON.stringify(entry))
 return entry

func shot_perf(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/"+prefix_perf()+"_"+tag+".png")

func census_perf() -> void:
 var c := {"nodes":0,"sprites":0,"sprites_visible":0,"sprite_shader_mats":0,"sprite_std_mats":0,"meshes":0,"mesh_shadow_casters":0,"omni":0,"omni_active":0,"omni_shadow":0,"spot":0,"spot_shadow":0,"spot_active":0,"directional":0,"particles":0,"collision_shapes3d":0,"collision_objects3d":0}
 var shaders := {}
 var stack: Array=[sample]
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  c.nodes+=1
  for child in node.get_children(): stack.push_back(child)
  if node is Sprite3D:
   c.sprites+=1
   if node.is_visible_in_tree(): c.sprites_visible+=1
   var mat: Material=node.material_override
   if mat is ShaderMaterial:
    c.sprite_shader_mats+=1
    var shader: Shader=mat.shader
    if not shaders.has(shader): shaders[shader]=0
    shaders[shader]+=1
   elif mat is StandardMaterial3D: c.sprite_std_mats+=1
  elif node is MeshInstance3D:
   c.meshes+=1
   if node.cast_shadow!=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF: c.mesh_shadow_casters+=1
  elif node is OmniLight3D:
   c.omni+=1
   if node.shadow_enabled: c.omni_shadow+=1
   if node.is_visible_in_tree() and node.light_energy>0.: c.omni_active+=1
  elif node is SpotLight3D:
   c.spot+=1
   if node.shadow_enabled: c.spot_shadow+=1
   if node.is_visible_in_tree() and node.light_energy>0.: c.spot_active+=1
  elif node is DirectionalLight3D: c.directional+=1
  elif node is GPUParticles3D or node is CPUParticles3D: c.particles+=1
  elif node is CollisionShape3D: c.collision_shapes3d+=1
  elif node is CollisionObject3D: c.collision_objects3d+=1
 var top: Array=[]
 for shader in shaders:
  var path: String=shader.resource_path
  if path.is_empty(): path="(runtime shader)"
  top.append({"shader":path,"count":shaders[shader]})
 top.sort_custom(func(a,b): return a.count>b.count)
 c.top_sprite_shaders=top.slice(0,8)
 var trees: Array=sample.get("trees")
 if trees!=null: c.trees_registered=trees.size()
 var whole: Object=sample.get("whole67")
 if whole!=null and is_instance_valid(whole): c.whole_fade_entries=whole.entries.size()
 var lighting: Object=sample.get("lighting191")
 if lighting!=null and is_instance_valid(lighting): c.forest_lamps191=lighting.lamps.size()
 report.census=c
 print("PERF_CENSUS ",JSON.stringify(c))

func spots_perf() -> void: pass

func run() -> void:
 root.size=Vector2i(1600,1000)
 report.meta={"godot":Engine.get_version_info().string,"adapter":RenderingServer.get_video_adapter_name(),"window":"1600x1000 vsync off","save":"isolated tmp"}
 sample=world_script_perf().new()
 sample.memory_save116="user://"+prefix_perf()+"_tmp.cfg"
 root.add_child(sample)
 while not ready_flag_perf(): await physics_frame
 sample.hero.controls_enabled=false
 await settle(900)
 census_perf()
 await spots_perf()
 FileAccess.open(out_path_perf(),FileAccess.WRITE).store_string(JSON.stringify(report," "))
 var saved := FileAccess.file_exists(ProjectSettings.globalize_path("user://"+prefix_perf()+"_tmp.cfg"))
 if saved: DirAccess.remove_absolute(ProjectSettings.globalize_path("user://"+prefix_perf()+"_tmp.cfg"))
 print(prefix_perf().to_upper()+"_DONE ",out_path_perf())
 quit(0)
