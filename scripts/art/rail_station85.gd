extends "res://scripts/art/rail_station84.gd"
var wall_faces85 := 0
func _outside_stair_begin83() -> int:
	# Leave the first tread's outer edge open as the side-approach mouth. This
	# matches the existing winding road instead of putting a wall across it.
	return 1


func _brick85(node: MeshInstance3D,cut := false) -> void:
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/station_brick85.gdshader")
	material.set_shader_parameter("cut_enabled85",cut)
	if cut:
		var foot: Vector2=world.meadow.stair_start73()
		material.set_shader_parameter("front_cut80",Vector4(foot.x-2.25,foot.y-world.meadow.station_stair_run74(),foot.x+2.25,foot.y))
	world.porch49.shade_material(material);node.material_override=material

func finish79(st: SurfaceTool,label: String) -> MeshInstance3D:
	var node := super.finish79(st,label)
	if label in ["ClosedFrontStoneFlight80","FrontOutsideStoneCurbs80","PaintedFrontStoneSteps79"]: _brick85(node)
	return node

func _build_station73() -> void:
	super._build_station73()
	_brick85(station_mesh73,true)
	# Only vertical boundary faces collide. Keep the smooth terrain ramp as the
	# walkable floor so closed visual treads do not introduce stair-step snagging.
	_walls85([station_mesh73,get_node("FrontOutsideStoneCurbs80"),front_steps80],"FrontWallCollision85")

func _build_side_steps75() -> void:
	super._build_side_steps75()
	_walls85([get_node("RetainedMossWall83"),get_node("MossStairLandingAndReturns83"),side_steps80],"MossWallCollision85")

func _walls85(nodes: Array,label: String) -> void:
	var faces := PackedVector3Array()
	for node: MeshInstance3D in nodes:
		for surface in node.mesh.get_surface_count():
			var arrays: Array=node.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
			var indices := PackedInt32Array()
			if arrays[Mesh.ARRAY_INDEX]!=null: indices=arrays[Mesh.ARRAY_INDEX]
			var count := indices.size() if not indices.is_empty() else vertices.size()
			for i in range(0,count,3):
				var a := indices[i] if not indices.is_empty() else i
				# Tread risers are crossed by the existing physical ramp. Only
				# flight side faces belong in the lateral barrier.
				if absf(normals[a].y)>.25: continue
				if node==front_steps80 and absf(normals[a].x)<.9: continue
				if node==side_steps80 and absf(normals[a].z)<.9: continue
				for j in 3:
					var index := indices[i+j] if not indices.is_empty() else i+j
					faces.append(node.transform*vertices[index])
	var shape := ConcavePolygonShape3D.new();shape.set_faces(faces);shape.backface_collision=true
	var body := StaticBody3D.new();body.name=label;body.collision_layer=2;body.collision_mask=0
	var collision := CollisionShape3D.new();collision.shape=shape;body.add_child(collision);add_child(body)
	wall_faces85+=faces.size()/3
