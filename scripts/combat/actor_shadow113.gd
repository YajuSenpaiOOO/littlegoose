extends "res://scripts/combat/actor_shadow105.gd"
var field_revision113 := -1
var gpu113 := false
func _physics_process(delta: float) -> void:
 if not battle.combat_budget105: super._physics_process(delta)
func _process(delta: float) -> void:
 var field: RefCounted=battle.shadow_field113
 var actor: Node3D=get_parent()
 var size := visual.texture.get_size() if is_instance_valid(visual) and visual.texture!=null else Vector2.ZERO
 var margin := maxf(16.,size.length()*visual.pixel_size*3.) if is_instance_valid(visual) else 16.
 if not battle.gpu_shadows113 or field.height_texture==null or not field.bounds.grow(-margin).has_point(Vector2(actor.global_position.x,actor.global_position.z)):
  if gpu113: ink.shader=preload("res://scripts/art/actor_shadow25.gdshader");gpu113=false;geometry_key105.clear()
  super._process(delta);return
 visible=enabled and is_instance_valid(visual) and visual.is_visible_in_tree() and battle.contact_enabled
 if not visible or visual.texture==null: return
 if not gpu113:
  gpu113=true;ink.shader=preload("res://scripts/art/actor_shadow113.gdshader");field_revision113=-1;last_texture=null;mesh=dynamic_mesh105
  custom_aabb=AABB(Vector3(-40,-20,-40),Vector3(80,40,80))
 if field_revision113!=field.revision: field.bind_shader(ink);field_revision113=field.revision
 var source: Texture2D=visual.texture
 if source!=last_texture:
  last_texture=source;var texture: Texture2D=source;var region := Vector4(0,0,1,1)
  if source is AtlasTexture:
   texture=source.atlas;var extent := texture.get_size();region=Vector4(source.region.position.x/extent.x,source.region.position.y/extent.y,source.region.size.x/extent.x,source.region.size.y/extent.y)
  ink.set_shader_parameter("silhouette",texture);ink.set_shader_parameter("region",region)
 var position: Vector3=actor.get_global_transform_interpolated().origin
 ink.set_shader_parameter("flipped",visual.flip_h);ink.set_shader_parameter("opacity",.27*visual.modulate.a*opacity_scale)
 ink.set_shader_parameter("visual_world113",visual.get_global_transform_interpolated());ink.set_shader_parameter("sprite_geometry113",Vector4(size.x,size.y,visual.offset.x,visual.offset.y))
 ink.set_shader_parameter("pixel_size113",visual.pixel_size);ink.set_shader_parameter("light_direction113",light_direction);ink.set_shader_parameter("actor_xz113",Vector2(position.x,position.z))
