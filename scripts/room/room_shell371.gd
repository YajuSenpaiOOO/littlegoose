extends "res://scripts/room/room_shell369.gd"
var blanket_view370: SubViewport
var mask_camera370: Camera3D
var mask_mesh370: MeshInstance3D
var mask_throw370: MeshInstance3D
var strict370:=true
var mask_key371:=[]
var mask_updates371:=0
func build_furniture() -> void:
 super.build_furniture()
 pose_material369.shader=preload("res://scripts/room/sleep_pose370.gdshader")
 # A separate alpha mask hides only the actor wherever the real blanket projects.
 # Furniture geometry, its depth and the room depth buffer are never cut or rewritten.
 blanket_view370=SubViewport.new();blanket_view370.size=Vector2i(1440,900);blanket_view370.transparent_bg=true;blanket_view370.own_world_3d=true
 blanket_view370.render_target_update_mode=SubViewport.UPDATE_DISABLED;add_child(blanket_view370)
 var environment370:=WorldEnvironment.new();var env:=Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color.BLACK;env.ambient_light_energy=0.;environment370.environment=env;blanket_view370.add_child(environment370)
 mask_camera370=Camera3D.new();mask_camera370.current=true;blanket_view370.add_child(mask_camera370)
 mask_mesh370=MeshInstance3D.new();var white:=StandardMaterial3D.new();white.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;white.albedo_color=Color.WHITE;white.cull_mode=BaseMaterial3D.CULL_DISABLED;mask_mesh370.material_override=white;blanket_view370.add_child(mask_mesh370)
 mask_throw370=MeshInstance3D.new();mask_throw370.material_override=white;blanket_view370.add_child(mask_throw370)
 pose_material369.set_shader_parameter("blanket_mask",blanket_view370.get_texture())
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(blanket_view370):return
 var size370: Vector2i=DisplayServer.window_get_size()
 if blanket_view370.size!=size370:blanket_view370.size=size370
 var active: bool=strict370 and occupied368 and not old_pose369 and use_craft364 and show_duvet366
 pose_material369.set_shader_parameter("cover_mask",active)
 blanket_view370.render_target_update_mode=SubViewport.UPDATE_DISABLED
 mask_mesh370.visible=active;mask_throw370.visible=active and show_throw366
 if not active:mask_key371=[]
 if active:
  var key: Array=[world.camera.global_transform,duvet_mesh366.mesh,throw_mesh366.mesh,duvet_mesh366.global_transform,throw_mesh366.global_transform,show_throw366,size370,world.camera.fov]
  if key==mask_key371:return
  mask_key371=key;mask_updates371+=1
  blanket_view370.render_target_update_mode=SubViewport.UPDATE_ONCE
  mask_throw370.mesh=throw_mesh366.mesh;mask_throw370.global_transform=throw_mesh366.global_transform
  mask_mesh370.mesh=duvet_mesh366.mesh;mask_mesh370.global_transform=duvet_mesh366.global_transform
  mask_camera370.global_transform=world.camera.global_transform;mask_camera370.fov=world.camera.fov;mask_camera370.near=world.camera.near;mask_camera370.far=world.camera.far
