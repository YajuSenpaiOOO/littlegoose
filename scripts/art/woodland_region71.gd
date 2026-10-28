extends "res://scripts/art/forest_terrace70.gd"
var ridge71: Sprite3D
var front_faces71: Array[MeshInstance3D]=[]

func _ready() -> void:
	name="ContinuousWoodlandUpland71"
	center=world.meadow.landmarks.grove
	rng.seed=710019
	rock=SurfaceTool.new(); rock.begin(Mesh.PRIMITIVE_TRIANGLES)
	wall=SurfaceTool.new(); wall.begin(Mesh.PRIMITIVE_TRIANGLES)
	moss=SurfaceTool.new(); moss.begin(Mesh.PRIMITIVE_TRIANGLES)
	_build_front71()
	_build_stairs()
	# Only a few exposed stones at the foot and forest edge, not a ring marking
	# the arena. The old cylindrical perimeter and eastern raised causeway vanish.
	for spec in [Vector4(-13,10,1.8,1.1),Vector4(9,11,1.6,.85),Vector4(-13,-3,2.,1.5)]:
		_boulder(Vector2(spec.x,spec.y),spec.z,spec.w)
	rock_mesh=_finish(rock,"SparseFootAndWoodlandRocks71",Color(.86,.91,.94))
	wall_mesh=_finish(wall,"StairAndShortOldWall71",Color(.95,.94,.87))
	_build_ridge71()

func _build_front71() -> void:
	# A single long escarpment at the FRONT of the whole woodland region. No
	# rear or side wall surrounds the clearing. Five broad painted spans follow
	# the front contour, interrupted only by the real staircase.
	for span in [Vector2(-28,-16),Vector2(-16,-5.55),Vector2(-.45,10),Vector2(10,17)]:
		var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var lip := SurfaceTool.new(); lip.begin(Mesh.PRIMITIVE_TRIANGLES)
		var count := ceili((span.y-span.x)/.6)
		for i in count:
			for uv in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var t: float=(float(i)+uv.x)/count
				var x := lerpf(span.x,span.y,t)
				var z: float=world.meadow.front71(x)+.35
				var upper: float=world.floor_height(center+Vector2(x,z-.85))+.035
				var at := center+Vector2(x,z)
				st.set_normal(Vector3(0,.12,1).normalized()); st.set_uv(Vector2(t,uv.y))
				st.add_vertex(Vector3(at.x,lerpf(upper,.09,uv.y),at.y))
				lip.set_normal(Vector3.UP); lip.set_uv(Vector2(t,uv.y))
				lip.add_vertex(Vector3(at.x,upper+.009,at.y-uv.y*.85))
		var node := MeshInstance3D.new(); node.name="PaintedForestBank71"
		node.mesh=st.commit()
		var material := ShaderMaterial.new(); material.shader=preload("res://scripts/art/painted_escarpment71.gdshader")
		material.set_shader_parameter("paint",preload("res://assets/forest_region71/mossy_escarpment.png"))
		node.material_override=material; add_child(node); world.porch49.shade_material(material)
		front_faces71.append(node)
		var cap := MeshInstance3D.new(); cap.name="JoinedGrassLip71"; cap.mesh=lip.commit()
		var cap_material := ShaderMaterial.new(); cap_material.shader=preload("res://scripts/art/forest_lip71.gdshader")
		cap_material.set_shader_parameter("paint",world.ground_templates[3].get_shader_parameter("paint"))
		cap.material_override=cap_material; add_child(cap); world.porch49.shade_material(cap_material)
		for i in count:
			var x := lerpf(span.x,span.y,(float(i)+.5)/count)
			var z: float=world.meadow.front71(x)
			var upper: float=world.floor_height(center+Vector2(x,z-.85))
			var at := center+Vector2(x,z)
			_obstacle(Vector3(at.x,upper*.5+.35,at.y),Vector3((span.y-span.x)/count+.1,upper+.9,.7))
	# Two short masonry remnants sit in the soil, breaking the natural bank;
	# they do not fence the playable space.
	for x in [-10.,-8.9,3.4,4.5,5.6]:
		var z: float=world.meadow.front71(x)-.3
		var at := center+Vector2(x,z)
		var h: float=world.floor_height(at)
		for row in 2: _box(wall,Vector3(at.x,h+.11+row*.24,at.y),Vector3(1.06,.22,.55))

func _build_ridge71() -> void:
	var texture: Texture2D=preload("res://assets/forest_region71/wooded_ridge.png")
	ridge71=Sprite3D.new(); ridge71.name="PaintedRockyFoothills71"
	ridge71.texture=texture; ridge71.pixel_size=46./texture.get_width()
	ridge71.offset=Vector2(0.,texture.get_height()*.5-32.)
	ridge71.position=Vector3(center.x-2.,world.floor_height(center+Vector2(-2,-14.5))-.3,center.y-14.5)
	ridge71.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := ShaderMaterial.new(); material.shader=preload("res://scripts/art/forest_cutout17.gdshader")
	material.set_shader_parameter("paint",texture); material.set_shader_parameter("tint",Vector3(.84,.90,.97))
	ridge71.material_override=material; add_child(ridge71); world.porch49.shade_material(material)
	# The back tree belt is foreground to the painting, on rising REAL ground.
	# A terrain/backdrop transition is inaccessible, not a vertical paper wall
	# that actors can walk through.
	_obstacle(Vector3(center.x-1.,5.,center.y-14),Vector3(47.,8.,.8))
