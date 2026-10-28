extends "res://scripts/world/paper_hill143_probe.gd"
func inspect143(node: Node,s: Node3D) -> void:
 if node is MeshInstance3D and node.mesh!=null and node.is_visible_in_tree():
  var at: Vector3=node.to_global(node.get_aabb().get_center());var p: Vector2=Vector2(at.x,at.z)-Vector2(s.meadow.landmarks.grove)
  if p.y< -31. and p.x< -5. and p.x> -40. and node.layers!=0:
   print("REAR143 ",node.get_path()," p=",p," size=",node.get_aabb().size," material=",node.material_override)
 if node is GeometryInstance3D and node.is_visible_in_tree() and node.layers!=0:
  var box: AABB=node.get_aabb();var rect := Rect2();var valid := false
  for i in 8:
   var pt: Vector3=node.to_global(box.get_endpoint(i))
   if s.camera.is_position_behind(pt): continue
   var screen: Vector2=s.camera.unproject_position(pt)
   if not valid: rect=Rect2(screen,Vector2.ZERO);valid=true
   else: rect=rect.expand(screen)
  if valid and rect.has_point(Vector2(1030,640)): print("PIXEL143 ",node.get_path()," material=",node.material_override," pos=",node.global_position)
 for child in node.get_children(): inspect143(child,s)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current143.new();s.memory_save116="user://hill143_visual_tmp.cfg";root.add_child(s)
 while not s.hill_ready143: await physics_frame
 s.hill_visited136=true;disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove
 s.time55.preview_at(18.);s.time55.visual_hour=18.;s.time55.apply_look()
 await shot143(s,g+Vector2(-31.,-17.),"dusk_edge")
 await shot143(s,g+s.VIEW141,"dusk_view")
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look()
 await shot143(s,g+s.VIEW141,"wind_view")
 inspect143(s,s)
 print("VISUAL143_DONE materials=",s.breeze143.clipped_materials143.size())
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));quit()
