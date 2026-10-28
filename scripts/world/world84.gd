extends "res://scripts/world/world83.gd"
var started84 := Time.get_ticks_usec()
var grass_hit84 := false
var grass_pose_hit84 := false
var ground_shader84: Shader
func _rail_script72() -> Script: return preload("res://scripts/art/rail_station84.gd")
func _station_kit_script81() -> Script: return preload("res://scripts/art/station_kit84.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 84 · 启动缓存 / 小站接地 / 手绘石阶")
func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	if ground_shader84==null:
		ground_shader84=Shader.new()
		var code: String=preload("res://scripts/art/world_ground80.gdshader").code
		code=code.replace("shader_type spatial;","shader_type spatial;\nuniform sampler2D retaining_paint84 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;")
		var repair := """
 if(world.x>2.4 && world.x<13. && world.z> -49.2 && world.z< -43.8){
  vec2 stone_uv84=abs(normal76.x)>.6?world.zy:world.xy;
  vec3 repair84=texture(retaining_paint84,stone_uv84/2.8).rgb*.85;
  col=mix(col,repair84,1.-smoothstep(.45,.87,normal76.y));
 }
"""
		ground_shader84.code=code.replace(" ALBEDO=albedo_view ?",repair+" ALBEDO=albedo_view ?")
	for material in ground_materials:
		material.shader=ground_shader84;material.set_shader_parameter("retaining_paint84",preload("res://assets/wall77/painted_moss_stone77.png"))
		if is_instance_valid(porch49): porch49.shade_material(material,ground_shader84)
func _build_lab_floor() -> void:
	super._build_lab_floor();meadow=preload("res://scripts/world/world_surface84.gd").new()
func _rebuild_root_pieces() -> void:
	if grounding.get_script()!=preload("res://scripts/art/grounding84.gd"): grounding=preload("res://scripts/art/grounding84.gd").new()
	super._rebuild_root_pieces()
func _refresh_planting() -> void:
	var cache := preload("res://scripts/art/startup_cache84.gd")
	if not cache.enabled84(): super._refresh_planting();return
	var key := cache.signature84("grass")+str([meadow.get_script().resource_path,terrain_enabled,meadow.profile.enabled,meadow.profile.depth])
	var path := cache.path84("grass_pose",key).replace(".res",".bin")
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path,FileAccess.READ);var data: Array=file.get_var()
		var valid := data.size()==grass_batches.size()
		if valid:
			for i in data.size(): valid=valid and data[i].size()==grass_batches[i].points.size() and (data[i].is_empty() or data[i][0] is Transform3D)
		if valid:
			for i in data.size():
				for j in data[i].size(): grass_batches[i].node.multimesh.set_instance_transform(j,data[i][j])
			grass_pose_hit84=true;return
	var data: Array=[]
	# Save CPU transforms, not renderer buffers (the headless renderer has none).
	for batch in grass_batches:
		var poses: Array[Transform3D]=[]
		for i in batch.points.size():
			var original: Transform3D=batch.points[i];var at := original.origin
			var normal: Vector3=meadow.normal_at(at.x,at.z,terrain_enabled)
			var right := Vector3.RIGHT.slide(normal).normalized()
			var frame := Basis(right,normal,right.cross(normal))
			var pos: Vector3=Vector3(at.x,meadow.height_at(at.x,at.z,terrain_enabled),at.z)-batch.node.position
			var pose := Transform3D(frame*original.basis,pos)
			poses.append(pose);batch.node.multimesh.set_instance_transform(i,pose)
		data.append(poses)
	var file := FileAccess.open(path,FileAccess.WRITE);file.store_var(data)
func _build_lab_grass() -> void:
	var cache := preload("res://scripts/art/startup_cache84.gd")
	var key := cache.signature84("grass")+str(meadow.get_script().resource_path)
	var path := cache.path84("grass",key).replace(".res",".bin")
	if cache.enabled84() and FileAccess.file_exists(path):
		var file := FileAccess.open(path,FileAccess.READ);var data: Array=file.get_var()
		cross_mesh=_cross_mesh();blade_mesh=_blade_mesh()
		for kind in range(1,4): meadow_meshes.append(meadow.blades(kind))
		for entry in data:
			var node := MultiMeshInstance3D.new();node.name=entry.name;node.position=entry.position
			node.visibility_range_end=46.;node.extra_cull_margin=.65;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D;multi.use_custom_data=true;multi.mesh=meadow_meshes[2];multi.instance_count=entry.points.size()
			node.multimesh=multi
			for i in entry.points.size(): multi.set_instance_transform(i,entry.points[i]);multi.set_instance_custom_data(i,entry.colors[i])
			add_child(node);grass_batches.append({"node":node,"points":entry.points})
		grass=grass_batches[0].node;planting.assign(grass_batches[0].points);grass_hit84=true;return
	super._build_lab_grass()
	# Custom colours are supplied by the real renderer. A headless run may use
	# an existing bake but must not create one from its dummy GPU readback.
	if not cache.enabled84() or DisplayServer.get_name()=="headless": return
	var data: Array=[]
	for batch in grass_batches:
		var colors: Array[Color]=[]
		for i in batch.points.size(): colors.append(batch.node.multimesh.get_instance_custom_data(i))
		data.append({"name":batch.node.name,"position":batch.node.position,"points":batch.points,"colors":colors})
	var file := FileAccess.open(path,FileAccess.WRITE);file.store_var(data)
func _ready() -> void:
	super._ready()
	while not is_instance_valid(station81): await get_tree().physics_frame
	for i in 12: await get_tree().physics_frame
	var data := {"seconds":(Time.get_ticks_usec()-started84)/1000000.,"terrain_cache":meadow.terrain_hit84,"grass_cache":grass_hit84,"grass_pose_cache":grass_pose_hit84,"root_hits":grounding.hits84,"root_misses":grounding.misses84}
	var file := FileAccess.open("res://docs/startup84-latest.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("WORLD84_READY ",JSON.stringify(data))
	if "--startup84-check" in OS.get_cmdline_user_args(): get_tree().quit()
