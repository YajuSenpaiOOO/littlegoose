extends "res://scripts/world/paper_hill145_probe.gd"
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current145.new();s.memory_save116="user://hill145_shadow_tmp.cfg";root.add_child(s)
 while not s.hill_ready145: await physics_frame
 s.hill_visited136=true;disable_enemies(s);s.camera_distance=8.
 s.time55.preview_at(16.);s.time55.visual_hour=16.;s.time55.apply_look()
 var g: Vector2=s.meadow.landmarks.grove
 await shot145(s,g+s.picnic144.PICNIC144+Vector2(-2.,1.5),"shadow_compare_before")
 var projectors: Array=[]
 for sprite in [s.picnic144.basket144,s.picnic144.floor_lamp144,s.picnic144.branch_lamp144]:
  var p: MeshInstance3D=s.prop_shadows145.registered145[sprite.get_instance_id()];projectors.append(p)
  print("SHADOW145 visible=",p.visible," enabled=",p.enabled," contact=",s.contact_enabled," opacity=",p.ink.get_shader_parameter("opacity")," sun=",s.sun.shadow_opacity," ray=",-s.sun.global_basis.z)
 paused=true
 var on := await snapshot();on.save_png("res://docs/captures/world_restart/paper_hill145_shadow_on.png")
 for p in projectors: p.hide()
 var off := await snapshot();off.save_png("res://docs/captures/world_restart/paper_hill145_shadow_off.png")
 var pixels := 0
 for y in range(250,800):
  for x in range(650,1350):
   var a := on.get_pixel(x,y);var b := off.get_pixel(x,y)
   if absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)>.035: pixels+=1
 print("SHADOW145_RENDER_DIFFERENCE pixels=",pixels)
 paused=false
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));quit()
