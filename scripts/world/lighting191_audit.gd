extends "res://scripts/world/forest180_probe.gd"
var results := {}
func record(s: Node3D,tag: String) -> void:
 var hero: Node3D=s.hero
 hero.controls_enabled=false;hero.set_physics_process(false);hero.facing="down";hero.body_clock=0.;hero.render_pose()
 await settle(20)
 var v: Sprite3D=hero.visual
 var p: Vector3=v.global_position
 var origin: Vector2=s.camera.unproject_position(p)
 var x: Vector2=s.camera.unproject_position(p+v.global_basis.x)-origin
 var y: Vector2=s.camera.unproject_position(p+v.global_basis.y)-origin
 results[tag]={"hero_script":hero.get_script().resource_path,"texture":v.texture.resource_path,"texture_size":str(v.texture.get_size()),"pixel_size":v.pixel_size,"scale":str(v.scale),"rotation_degrees":str(v.rotation_degrees),"camera_rotation":str(s.camera.rotation_degrees),"projected_y_over_x":y.length()/x.length(),"shaded":v.shaded,"modulate":str(v.modulate)}
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/audit191_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 for version in [169,191]:
  var script: Script=load("res://scripts/world/woodland_world%d.gd"%version)
  var s: Node3D=script.new();s.memory_save116="user://lighting191_audit_%d.cfg"%version;root.add_child(s)
  if version==191:
   while not is_instance_valid(s.lighting191): await physics_frame
  else:
   while not s.hill_ready146: await physics_frame
  s._teleport15(Vector2(-4.7,-2.6));s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look();await settle(180)
  await record(s,str(version)+"_home_day")
  if version==191:
   s.lighting191.enabled=false;await settle(180)
   await record(s,"191_lights_off")
   s.hero.visual.rotation.x=0.
   var v: Sprite3D=s.hero.visual;var p: Vector3=v.global_position;var origin: Vector2=s.camera.unproject_position(p)
   results["191_rotation_restored"]={"projected_y_over_x":(s.camera.unproject_position(p+v.global_basis.y)-origin).length()/(s.camera.unproject_position(p+v.global_basis.x)-origin).length()}
   await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/captures/world_restart/audit191_rotation_restored.png")
  DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));s.queue_free();await settle(30)
 FileAccess.open("res://docs/lighting191-audit.json",FileAccess.WRITE).store_string(JSON.stringify(results," "))
 print("LIGHTING191_AUDIT ",JSON.stringify(results));quit()
