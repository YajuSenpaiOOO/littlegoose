extends "res://scripts/art/cached_actor_shadow68.gd"
var axis69 := Vector2.DOWN
var footprint_area69 := 0.

func _physics_process(_delta: float) -> void:
	visible=enabled and opacity_scale>.001 and is_instance_valid(visual) and visual.is_visible_in_tree() and battle.contact_enabled
	if not visible: return
	ink.set_shader_parameter("opacity",.27*visual.modulate.a*opacity_scale)
	ink.set_shader_parameter("flipped",visual.flip_h)
	var source: Texture2D=visual.texture
	if source==null: return
	var pose := [source,visual.global_transform,visual.offset,visual.pixel_size,light_direction]
	if pose==last_pose68: return
	var now := Time.get_ticks_usec()
	if source==last_texture and now-last_build68<50000 and not last_pose68.is_empty() and visual.global_position.distance_to(last_pose68[1].origin)<2.: return
	var texture: Texture2D=source
	var region := Vector4(0,0,1,1)
	if source is AtlasTexture:
		texture=source.atlas
		var atlas_size := texture.get_size()
		region=Vector4(source.region.position.x/atlas_size.x,source.region.position.y/atlas_size.y,source.region.size.x/atlas_size.x,source.region.size.y/atlas_size.y)
	ink.set_shader_parameter("silhouette",texture); ink.set_shader_parameter("region",region)
	var away := Vector2(light_direction.x,light_direction.z)/maxf(.1,-light_direction.y)
	if away.length()>.08: axis69=away.normalized()
	var side := Vector2(axis69.y,-axis69.x)
	var slope := clampf(away.length(),.32,1.45)
	var size := source.get_size()
	var origin: Vector3=get_parent().global_position
	var points: Array[Vector3]=[]
	for y in 3:
		for x in 3:
			var uv := Vector2(x,y)*.5
			var width: float=(uv.x*size.x-size.x*.5+visual.offset.x)*visual.pixel_size
			var height: float=maxf(0.,(size.y*.5-uv.y*size.y+visual.offset.y)*visual.pixel_size)
			var at := Vector2(origin.x,origin.z)+side*width+axis69*height*slope
			points.append(to_local(Vector3(at.x,battle.floor_height(at)+.024,at.y)))
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for y in 2:
		for x in 2:
			for offset in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
				var index: Vector2i=Vector2i(x,y)+offset
				st.set_uv(Vector2(index)*.5); st.add_vertex(points[index.y*3+index.x])
	mesh=st.commit()
	footprint_area69=Vector2(points[2].x-points[0].x,points[2].z-points[0].z).length()*Vector2(points[6].x-points[0].x,points[6].z-points[0].z).length()
	last_texture=source; last_pose68=pose; last_build68=now; rebuilds68+=1
