extends "res://scripts/world/woodland_world99.gd"
var woodland_ready100 := false
var plane_moves100 := 0
var plane_before100 := 0
var root_shadow100: MeshInstance3D
var root_contact100: MeshInstance3D
func _swing_root_profile99() -> Dictionary:
	return {"foot":[1000,1230],"height":1230,"cutoff":.5,"root_ratio":.15}
func _park_script99() -> Script: return preload("res://scripts/art/nature_park100.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time100.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 100 · 树根贴地 / 树层错开 / 可碰摆动秋千")
func _plane_overlap100(a: Dictionary,b: Dictionary) -> bool:
	var sa: Sprite3D=a.visual;var sb: Sprite3D=b.visual
	if absf(sa.global_position.z-sb.global_position.z)>.12: return false
	var ax := sa.global_position.x+sa.offset.x*sa.pixel_size;var bx := sb.global_position.x+sb.offset.x*sb.pixel_size
	var half_a := sa.texture.get_width()*sa.pixel_size*.5;var half_b := sb.texture.get_width()*sb.pixel_size*.5
	var ay := sa.global_position.y+sa.offset.y*sa.pixel_size;var by := sb.global_position.y+sb.offset.y*sb.pixel_size
	var height_a := sa.texture.get_height()*sa.pixel_size*.5;var height_b := sb.texture.get_height()*sb.pixel_size*.5
	if minf(ay+height_a,by+height_b)-maxf(ay-height_a,by-height_b)<.5: return false
	return minf(ax+half_a,bx+half_b)-maxf(ax-half_a,bx-half_b)>.5
func _park_trees100() -> Array[Dictionary]:
	var result: Array[Dictionary]=[];var g: Vector2=meadow.landmarks.grove
	for tree in trees:
		if Vector2(tree.root.position.x,tree.root.position.z).distance_to(g)<30.: result.append(tree)
	return result
func plane_conflicts100() -> int:
	var nearby := _park_trees100();var count := 0
	for i in nearby.size():
		for j in range(i+1,nearby.size()):
			if _plane_overlap100(nearby[i],nearby[j]): count+=1
	return count
func _stagger_planes100() -> void:
	if meadow==null or meadow.landmarks.is_empty(): return
	var nearby := _park_trees100()
	for i in nearby.size():
		for j in range(i+1,nearby.size()):
			if not _plane_overlap100(nearby[i],nearby[j]): continue
			plane_before100+=1
			var moving: Dictionary=nearby[j] if not nearby[j].visual.has_meta("swing_oak99") else nearby[i]
			var old: Vector3=moving.root.position
			for dz in [.35,-.35,.65,-.65,.95,-.95]:
				var at := Vector2(old.x,old.z+float(dz))
				if meadow.normal_at(at.x,at.y,true).y<.95 or meadow.route_distance(at)<1.65: continue
				moving.root.position=Vector3(at.x,meadow.height_at(at.x,at.y,true),at.y)
				var clear := true
				for other in nearby:
					if other.root!=moving.root and _plane_overlap100(moving,other): clear=false;break
				if clear:
					plane_moves100+=1;print("TREE_PLANE100 ",old," -> ",moving.root.position);break
				moving.root.position=old
func _rebuild_root_pieces() -> void:
	_stagger_planes100()
	super._rebuild_root_pieces()
	if is_instance_valid(root_shadow100): root_shadow100.free()
	if is_instance_valid(root_contact100): root_contact100.free()
	for piece in root_pieces:
		if not piece.sprite.has_meta("swing_oak99"): continue
		root_shadow100=MeshInstance3D.new();root_shadow100.name="GroundedRootCaster100"
		root_shadow100.mesh=piece.node.mesh;root_shadow100.material_override=piece.node.material_override.duplicate()
		root_shadow100.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		piece.node.get_parent().add_child(root_shadow100)
		# A soft, alpha-shaped contact band grounds the wide roots even when the
		# directional light's shadow bias erases shadows only centimetres high.
		var arrays: Array=piece.node.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
		for i in vertices.size():
			var point: Vector3=piece.node.to_global(vertices[i])
			vertices[i].y=meadow.height_at(point.x,point.z,true)-piece.node.global_position.y+.006
		arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TANGENT]=null
		var mesh := ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		root_contact100=MeshInstance3D.new();root_contact100.name="SoftWideRootContact100";root_contact100.mesh=mesh
		root_contact100.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root_contact100.visibility_range_end=46.
		var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/root_contact100.gdshader")
		material.set_shader_parameter("paint",piece.sprite.texture);root_contact100.material_override=material
		piece.node.get_parent().add_child(root_contact100)
func _ready() -> void:
	super._ready()
	while not woodland_ready99: await get_tree().physics_frame
	woodland_ready100=true;_title35();time55.update_guide()
	print("WOODLAND100_READY plane_moves=",plane_moves100," remaining=",plane_conflicts100())
