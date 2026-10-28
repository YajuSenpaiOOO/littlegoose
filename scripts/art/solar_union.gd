extends Node2D
## Merge all blockers for ONE sun into a coverage mask, shade ground once.
var rig: Node2D
var mask: SubViewport
var casters: Node2D
var display: Sprite2D
var count := 0

func _ready() -> void:
	mask = SubViewport.new()
	mask.name = "SunCoverage"
	mask.disable_3d = true
	mask.world_2d = World2D.new()
	mask.transparent_bg = true
	mask.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	mask.size = Vector2i(get_viewport_rect().size)
	add_child(mask)
	casters = Node2D.new()
	mask.add_child(casters)
	display = Sprite2D.new()
	display.name = "ShadeGroundOnce"
	display.centered = false
	display.texture = mask.get_texture()
	display.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	display.z_index = -2
	var shade := ShaderMaterial.new()
	shade.shader = preload("res://scripts/art/solar_union.gdshader")
	display.material = shade
	add_child(display)

func register(projection: Node2D) -> void:
	projection.merge_mask = true
	projection.reparent(casters)
	var material := ShaderMaterial.new()
	if projection.get("image") is Sprite2D:
		material.shader = preload("res://scripts/art/solar_mask_sprite.gdshader")
		projection.image.material = material
	else:
		material.shader = preload("res://scripts/art/solar_mask_plane.gdshader")
		projection.material = material
		projection.queue_redraw()
	count += 1

func sync(enabled: bool) -> void:
	var view := get_viewport()
	var size := Vector2i(get_viewport_rect().size)
	if mask.size!=size: mask.size = size
	mask.canvas_transform = view.canvas_transform
	display.transform = view.canvas_transform.affine_inverse()
	display.visible = enabled and rig.current_opacity>0.001 and rig.current_energy>0.001
	display.material.set_shader_parameter("strength",rig.sample_shadow(1,1).opacity)
	display.material.set_shader_parameter("shadow_tint",rig.current_tint)
	mask.render_target_update_mode = SubViewport.UPDATE_ALWAYS if display.visible else SubViewport.UPDATE_DISABLED
