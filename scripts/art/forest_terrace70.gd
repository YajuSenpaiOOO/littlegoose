extends Node3D
## Static batched rock faces / masonry / stair treads. One smooth terrain collider
## carries the stairs; separate edge obstacles stop walking through the cliffs.
var world: Node3D
var rng := RandomNumberGenerator.new()
var rock_mesh: MeshInstance3D
var wall_mesh: MeshInstance3D
var blockers70: Array[StaticBody3D]=[]
var boulders70: Array[StaticBody3D]=[]
var stair_count70 := 14
var rock: SurfaceTool
var wall: SurfaceTool
var moss: SurfaceTool
var center := Vector2.ZERO

func _ready() -> void:
	name="LayeredForestTerrace70"
	center=world.meadow.landmarks.grove
	rng.seed=700019
	rock=SurfaceTool.new(); rock.begin(Mesh.PRIMITIVE_TRIANGLES)
	wall=SurfaceTool.new(); wall.begin(Mesh.PRIMITIVE_TRIANGLES)
	moss=SurfaceTool.new(); moss.begin(Mesh.PRIMITIVE_TRIANGLES)
	_build_edges()
	_build_stairs()
	_build_ramp_edges()
	for spec in [Vector4(-10,3,2.5,1.9),Vector4(6,3.8,2.,1.5),Vector4(-9,-5,3.,2.7),Vector4(5,-5.7,2.2,2.2),Vector4(11,8.5,2.7,2.4),Vector4(-8.5,12,2.4,1.8),Vector4(15,-4,2.2,2.4)]:
		_boulder(Vector2(spec.x,spec.y),spec.z,spec.w)
	rock_mesh=_finish(rock,"FacetedCliffAndBoulders70",Color(.78,.85,.94))
	wall_mesh=_finish(wall,"BrokenRetainingWallAndStairs70",Color(.95,.94,.87))
	var node := MeshInstance3D.new()
	moss.generate_normals()
	node.name="MossOnRockLedges70"; node.mesh=moss.commit()
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo=true; material.albedo_color=Color(.36,.43,.19); material.roughness=1.
	node.material_override=material; add_child(node)

func _finish(st: SurfaceTool,label: String,tint: Color) -> MeshInstance3D:
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name=label; node.mesh=st.commit()
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/terrace_stone70.gdshader")
	material.set_shader_parameter("paint",preload("res://assets/garden45/slate.png"))
	material.set_shader_parameter("tint",Vector3(tint.r,tint.g,tint.b))
	node.material_override=material; add_child(node)
	world.porch49.shade_material(material)
	return node

func _box(st: SurfaceTool,at: Vector3,size: Vector3,angle: float=0.) -> void:
	var mesh := BoxMesh.new(); mesh.size=size
	var arrays := mesh.get_mesh_arrays()
	var basis := Basis(Vector3.UP,angle)
	# Expand indices: mixing append_from(indexed boxes) with unindexed rock
	# triangles otherwise silently omits the latter from the committed mesh.
	for index in arrays[Mesh.ARRAY_INDEX]:
		st.set_color(Color.WHITE)
		st.set_uv(arrays[Mesh.ARRAY_TEX_UV][index])
		st.set_normal(basis*arrays[Mesh.ARRAY_NORMAL][index])
		st.add_vertex(at+basis*arrays[Mesh.ARRAY_VERTEX][index])

func _obstacle(at: Vector3,size: Vector3,angle: float=0.) -> StaticBody3D:
	var body := StaticBody3D.new(); body.collision_layer=2; body.collision_mask=0
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size=size
	collision.shape=shape; body.add_child(collision); add_child(body)
	body.position=at; body.rotation.y=angle
	blockers70.append(body)
	return body

func _stone(at: Vector3,size: Vector3,seed_color: float) -> void:
	# Flat shaded irregular three-ring rock, retaining a physical side and top.
	var rings: Array[PackedVector3Array]=[]
	for layer in 3:
		var ring := PackedVector3Array()
		for i in 7:
			var a := TAU*float(i)/7.
			var radius := rng.randf_range(.86,1.08)*(1. if layer==1 else .76)
			ring.append(at+Vector3(cos(a)*size.x*.5*radius,(float(layer)*.5-.5)*size.y,sin(a)*size.z*.5*radius))
		rings.append(ring)
	for layer in 2:
		for i in 7:
			var j := (i+1)%7
			for v in [rings[layer][i],rings[layer+1][j],rings[layer][j],rings[layer][i],rings[layer+1][i],rings[layer+1][j]]:
				rock.set_color(Color(seed_color,seed_color,seed_color)); rock.add_vertex(v)
	for i in 7:
		for v in [at+Vector3(0,size.y*.5,0),rings[2][(i+1)%7],rings[2][i]]:
			rock.set_color(Color(seed_color*1.08,seed_color*1.08,seed_color*1.08)); rock.add_vertex(v)
	# Broken moss patches sit inside the top face, not around the entire outline.
	for i in range(0,7,2):
		for v in [at+Vector3(0,size.y*.5+.012,0),rings[2][(i+1)%7]+Vector3.UP*.015,rings[2][i]+Vector3.UP*.015]:
			moss.set_color(Color.WHITE); moss.add_vertex(v)

func _build_edges() -> void:
	var polygon: PackedVector2Array=world.meadow.outline70
	for i in polygon.size():
		var a := polygon[i]; var b := polygon[(i+1)%polygon.size()]
		var pieces := ceili(a.distance_to(b)/1.65)
		var angle := -atan2((b-a).y,(b-a).x)
		for j in pieces:
			var p := a.lerp(b,(float(j)+.5)/pieces)
			# Open both the stairs and the east exit, including collision clearance.
			if (p.y>5.8 and absf(p.x+3.)<2.65) or (p.x>8.5 and absf(p.y)<3.): continue
			var at := center+p
			# A continuous dark core hides terrain seams; uneven full-height rock
			# columns break the silhouette instead of three identical brick rows.
			_box(rock,Vector3(at.x,1.32,at.y),Vector3(a.distance_to(b)/pieces+.08,2.64,.72),angle)
			var height := rng.randf_range(2.55,2.9)
			_stone(Vector3(at.x,height*.5-.08,at.y),Vector3(2.08,height,1.5),rng.randf_range(.86,1.05))
			if j%3==0:
				_stone(Vector3(at.x+.25,.38,at.y+.45),Vector3(1.2,.85,1.05),.9)
			_obstacle(Vector3(at.x,1.75,at.y),Vector3(a.distance_to(b)/pieces+.15,3.6,.65),angle)
			# Intermittent old retaining masonry on the near face, not a full fence.
			if p.y>3.5 and j%4!=0:
				for course in 2:
					_box(wall,Vector3(at.x,2.64+course*.27,at.y),Vector3(1.13,.24,.62),angle)
				_box(wall,Vector3(at.x,3.08,at.y),Vector3(1.24,.13,.76),angle)

func _build_stairs() -> void:
	for i in stair_count70:
		var z := 14.-(float(i)+.5)*7.7/stair_count70
		var at := center+Vector2(-3,z)
		var y: float=world.floor_height(at)
		# Visual risers only; the shared ramp below remains the walkable collider.
		_box(wall,Vector3(at.x,y+.025,at.y),Vector3(3.5,.20,7.7/stair_count70+.015))
	for x in [-5.05,-.95]:
		for i in 7:
			var at := center+Vector2(x,13.5-i*1.05)
			var y: float=world.floor_height(center+Vector2(-3,13.5-i*1.05))
			_box(wall,Vector3(at.x,y*.5+.18,at.y),Vector3(.72,y+.52,1.08))
			_obstacle(Vector3(at.x,y+.45,at.y),Vector3(.72,1.,1.04))

func _boulder(p: Vector2,width: float,height: float) -> void:
	var at := center+p
	var base: float=world.floor_height(at)-.16
	_stone(Vector3(at.x,base+height*.42,at.y),Vector3(width,height,width*.76),rng.randf_range(.88,1.04))
	var body := _obstacle(Vector3(at.x,base+height*.4,at.y),Vector3(width*.64,height,width*.52))
	body.name="BoulderCollision70"; boulders70.append(body)

func _build_ramp_edges() -> void:
	# Carry the east descent on rock shoulders instead of stretching vertical
	# grass down its sides. Obstacles protect only the steep side edges.
	for z in [-2.45,2.45]:
		for i in 10:
			var x := 9.4+float(i)*.94
			var h: float=world.floor_height(center+Vector2(x,0))
			if h<.3: continue
			var at := center+Vector2(x,z)
			_stone(Vector3(at.x,h*.5,at.y),Vector3(1.3,h+.12,1.1),rng.randf_range(.89,1.02))
			_obstacle(Vector3(at.x,h*.5+.35,at.y),Vector3(1.04,h+.9,.58))
	for x in [-5.6,-.4]:
		var at := center+Vector2(x,6.95)
		_stone(Vector3(at.x,1.3,at.y),Vector3(.85,2.7,1.2),.94)
