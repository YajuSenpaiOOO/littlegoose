extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var viewport:=SubViewport.new();viewport.size=Vector2i(1536,1024);viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
 var n:=Node3D.new();viewport.add_child(n)
 var e:=WorldEnvironment.new();var env:=Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color("b58b5e");e.environment=env;n.add_child(e)
 var source=preload("res://scripts/room/bed_mesh364.gd")
 for mesh in [source.board364(),source.trim364(source.outline364())]:
  var obj:=MeshInstance3D.new();obj.mesh=mesh
  var m:=StandardMaterial3D.new();m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;m.cull_mode=BaseMaterial3D.CULL_DISABLED;m.albedo_color=Color("b88750") if mesh==null else Color("d7b482")
  if n.get_child_count()>1:m.albedo_color=Color("8f623d")
  obj.material_override=m;n.add_child(obj)
 var c:=Camera3D.new();c.projection=Camera3D.PROJECTION_ORTHOGONAL;c.size=1.7333333;c.position=Vector3(0.,1.345,4.);c.current=true;n.add_child(c)
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 viewport.get_texture().get_image().save_png("res://assets/room364/headboard_uv_guide.png")
 quit()
