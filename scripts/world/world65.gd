extends "res://scripts/world/world64.gd"
var contact_stamp65 := -1000000
var contact_pose65 := Transform3D.IDENTITY
var contact_terrain65 := false
var contact_enabled65 := false
var contact_fov65 := 0.
var blend_cache65: Dictionary={}

func _landmark_script() -> Script:
	return preload("res://scripts/art/root_collision65.gd")

func _bridge_script() -> Script:
	return preload("res://scripts/art/bridge_lake65.gd")

func _time_script() -> Script:
	return preload("res://scripts/world/world_time65.gd")

func _update_prop_contacts() -> void:
	if world_ready and is_instance_valid(camera):
		var now := Time.get_ticks_usec()
		var unchanged: bool=terrain_enabled==contact_terrain65 and contact_enabled==contact_enabled65 and is_equal_approx(camera.fov,contact_fov65)
		var near_pose: bool=camera.global_position.distance_to(contact_pose65.origin)<.3 and camera.global_basis.is_equal_approx(contact_pose65.basis)
		if unchanged and near_pose and now-contact_stamp65<50000: return
		contact_stamp65=now
		contact_pose65=camera.global_transform
		contact_terrain65=terrain_enabled
		contact_enabled65=contact_enabled
		contact_fov65=camera.fov
	super._update_prop_contacts()

func _update_tree_blending() -> void:
	if not is_instance_valid(porch49) or not porch49.is_node_ready():
		super._update_tree_blending()
		return
	for piece in root_pieces:
		var sprite: Sprite3D=piece.sprite
		var fade: float=sprite.material_override.get_shader_parameter("fade")
		var wind: bool=woodland_life.tree_ids.has(sprite.get_instance_id())
		var state: int=(1 if fade<.999 else 0)+(2 if wind else 0)
		var key := sprite.get_instance_id()
		var saved: Array=blend_cache65.get(key,[])
		if saved.size()==3 and saved[0]==state and saved[1]==sprite.material_override.shader and saved[2]==piece.node.material_override.shader: continue
		var shader: Shader
		if wind:
			shader=preload("res://scripts/art/forest_wind_fade46.gdshader") if fade<.999 else preload("res://scripts/art/forest_wind46.gdshader")
		else:
			shader=preload("res://scripts/art/world_tree19.gdshader") if fade<.999 else preload("res://scripts/art/forest_cutout17.gdshader")
		porch49.shade_material(sprite.material_override,shader)
		porch49.shade_material(piece.node.material_override,shader)
		blend_cache65[key]=[state,sprite.material_override.shader,piece.node.material_override.shader]

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 银柳与流水65 · 根部碰撞 / 行走优化")
