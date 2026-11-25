extends Node3D
var world: Node3D
var enabled := true
var beds: Array[Rect2]=[Rect2(-.575,-5.225,1.05,1.55),Rect2(-.575,-7.575,1.05,1.55),Rect2(1.325,-7.35,1.05,2.)]
var garden_bounds := Rect2(-.95,-8.,4.05,5.25)
var soil_material: ShaderMaterial
var wood_material: ShaderMaterial
var bodies: Array[StaticBody3D]=[]
var crops: Array[Dictionary]=[]
var paving: Array[Vector2]=[]
var grass_cutouts: Array[Dictionary]=[]
var moved_plants: Array[Dictionary]=[]
var moved_flowers: Array[Dictionary]=[]
var crop_textures: Array[Texture2D]=[]
var crop_profiles: Array=[]
var content: Node3D
var sync_left := 0.
var post_keys := {}
var wood_pieces: Array[MeshInstance3D]=[]

func _ready() -> void:
	name="KitchenGarden44"
	soil_material=ShaderMaterial.new()
	soil_material.shader=preload("res://scripts/art/garden_soil44.gdshader")
	wood_material=ShaderMaterial.new()
	wood_material.shader=preload("res://scripts/art/garden_wood44.gdshader")
	content=Node3D.new()
	add_child(content)
	_load_crops()
	_build_beds()
	_build_fences()
	_merge_wood()
	_build_paving()
	_prepare_cutouts()
	_prepare_plant_moves()
	set_enabled(true)
	print("GARDEN44_READY crops=",crops.size()," grass_cutouts=",grass_cutouts.size())

func _load_crops() -> void:
	crop_profiles=JSON.parse_string(FileAccess.get_file_as_string("res://assets/garden44/profiles.json"))
	var source: Image=preload("res://assets/garden44/vegetables.png").get_image()
	if source.is_compressed(): source.decompress()
	for profile in crop_profiles:
		var cell: Array=profile.cell
		var image := source.get_region(Rect2i(cell[0],cell[1],cell[2],cell[3]))
		image.generate_mipmaps()
		crop_textures.append(ImageTexture.create_from_image(image))

func _floor(at: Vector2,lift := .0) -> Vector3:
	return Vector3(at.x,world.floor_height(at)+lift,at.y)

func _flat_patch(rect: Rect2,material: Material,lift: float) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count_x := maxi(1,ceili(rect.size.x/.25))
	var count_z := maxi(1,ceili(rect.size.y/.25))
	for z in count_z:
		for x in count_x:
			for delta in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var at: Vector2=rect.position+(Vector2(x,z)+delta)/Vector2(count_x,count_z)*rect.size
				st.set_normal(world.floor_normal(at))
				st.set_uv(at)
				st.add_vertex(_floor(at,lift))
	var node := MeshInstance3D.new()
	node.mesh=st.commit()
	node.material_override=material
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	content.add_child(node)
	return node

func _body(at: Vector3,size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position=at
	body.collision_layer=2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size=size
	shape.shape=box
	body.add_child(shape)
	content.add_child(body)
	bodies.append(body)
	return body

func _beam(a: Vector3,b: Vector3,width: float,height: float,collides := false) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size=Vector3(width,height,a.distance_to(b))
	node.mesh=mesh
	node.material_override=wood_material
	node.position=(a+b)*.5
	content.add_child(node)
	node.look_at(b)
	wood_pieces.append(node)
	if collides:
		var body := _body(node.position,mesh.size)
		body.basis=node.basis
	return node

func _post(at: Vector2,height: float) -> void:
	# Narrow bevelled posts keep a soft silhouette; real geometry casts its own shadow.
	var key := Vector2i((at*100.).round())
	if post_keys.has(key): return
	post_keys[key]=true
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var base := _floor(at,-.025)
	var rings := [Vector2(.065,0.),Vector2(.062,height-.07),Vector2(.042,height)]
	for ring in range(2):
		for side in 4:
			var corners := [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]
			var a := base+Vector3(corners[side].x*rings[ring].x,rings[ring].y,corners[side].y*rings[ring].x)
			var b := base+Vector3(corners[(side+1)%4].x*rings[ring].x,rings[ring].y,corners[(side+1)%4].y*rings[ring].x)
			var c := base+Vector3(corners[(side+1)%4].x*rings[ring+1].x,rings[ring+1].y,corners[(side+1)%4].y*rings[ring+1].x)
			var d := base+Vector3(corners[side].x*rings[ring+1].x,rings[ring+1].y,corners[side].y*rings[ring+1].x)
			st.set_normal((b-a).cross(c-a).normalized())
			var vertices := [a,c,b,a,d,c]
			var uvs := [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]
			for index in 6:
				st.set_uv(uvs[index])
				st.add_vertex(vertices[index])
	st.set_normal(Vector3.UP)
	for corner in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,-1),Vector2(1,1),Vector2(-1,1)]:
		st.set_uv((corner+Vector2.ONE)*.5)
		st.add_vertex(base+Vector3(corner.x*.042,height,corner.y*.042))
	st.index()
	var node := MeshInstance3D.new()
	node.mesh=st.commit()
	node.material_override=wood_material
	content.add_child(node)
	wood_pieces.append(node)
	_body(_floor(at,height*.5),Vector3(.13,height,.13))

func _merge_wood() -> void:
	# Merge static visible rails/posts into one draw while retaining their separate
	# physical shapes. This avoids making a small fence dozens of draw calls.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for piece in wood_pieces:
		st.append_from(piece.mesh,0,piece.transform)
		piece.queue_free()
	var merged := MeshInstance3D.new()
	merged.name="CombinedGardenTimber"
	merged.mesh=st.commit()
	merged.material_override=wood_material
	content.add_child(merged)
	wood_pieces.clear()

func _fence(a: Vector2,b: Vector2) -> void:
	var count := maxi(1,ceili(a.distance_to(b)/1.1))
	for i in range(count+1):
		_post(a.lerp(b,float(i)/count),.61+sin(i*2.4)*.035)
	for i in count:
		var from := a.lerp(b,float(i)/count)
		var to := a.lerp(b,float(i+1)/count)
		for y in [.22,.45]: _beam(_floor(from,y),_floor(to,y),.075,.075)
		var mid := (from+to)*.5
		var direction := to-from
		var body := _body(_floor(mid,.31),Vector3(.10,.62,direction.length()))
		body.look_at(body.position+Vector3(direction.x,0,direction.y))

func _build_beds() -> void:
	for i in beds.size():
		var rect := beds[i]
		_flat_patch(rect,soil_material,.026)
		_body(_floor(rect.get_center(),.20),Vector3(rect.size.x,.4,rect.size.y))
		var corners := [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]
		for side in 4: _beam(_floor(corners[side],.07),_floor(corners[(side+1)%4],.07),.065,.105)
		var rows := 3 if i!=2 else 4
		for row in rows:
			for column in 2:
				var at: Vector2=rect.position+Vector2((column+.5)*rect.size.x/2.,(row+.5)*rect.size.y/rows)
				var variant := (row+column)%2 if i==0 else (2 if i==1 else 3)
				_add_crop(at,variant,.30 if i==0 else (.36 if i==1 else .72))

func _add_crop(at: Vector2,index: int,height: float) -> void:
	var profile: Dictionary=crop_profiles[index]
	var sprite: Sprite3D=world._sprite(crop_textures[index],Vector2(profile.foot[0],profile.foot[1]),height,float(profile.height))
	sprite.billboard=BaseMaterial3D.BILLBOARD_DISABLED
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/decor_plant42.gdshader")
	material.set_shader_parameter("paint",crop_textures[index])
	material.set_shader_parameter("flex",.006 if index!=3 else .012)
	sprite.material_override=material
	sprite.position=_floor(at,.025)
	content.add_child(sprite)
	crops.append({"sprite":sprite,"at":at,"variant":index})

func _build_fences() -> void:
	# The southeast edge follows the road. Leave a 1.1m opening into the aisle.
	for segment in [[Vector2(-.95,-7.9),Vector2(-.95,-3.55)],[Vector2(-.95,-7.9),Vector2(3.0,-7.9)],[Vector2(3.0,-7.9),Vector2(3.0,-5.1)],[Vector2(3.0,-5.1),Vector2(1.55,-3.55)],[Vector2(-.95,-3.55),Vector2(.55,-3.55)]]:
		_fence(segment[0],segment[1])
	# Open courtyard frame: both the front opening and existing east road remain passable.
	_fence(Vector2(-6.1,.12),Vector2(-5.5,.12))
	_fence(Vector2(-3.25,.12),Vector2(-1.5,.12))

func _stone(at: Vector2,size: Vector2,seed_value: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed=int(seed_value*173)+440044
	var points: Array[Vector2]=[]
	for i in 7:
		var angle := TAU*i/7.+rng.randf_range(-.12,.12)
		points.append(at+Vector2(cos(angle),sin(angle))*size*.5*rng.randf_range(.85,1.12))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rise := .037+rng.randf_range(0.,.009)
	for i in 7:
		for j in 3:
			var p: Vector2=at if j==0 else at+(points[(i+j-1)%7]-at)*.84
			st.set_normal(world.floor_normal(p))
			st.set_uv((p-at)/size*2.)
			st.add_vertex(_floor(p,rise))
		var a := _floor(points[i],.009)
		var b := _floor(points[(i+1)%7],.009)
		var c := _floor(at+(points[(i+1)%7]-at)*.84,rise)
		var d := _floor(at+(points[i]-at)*.84,rise)
		st.set_normal((c-a).cross(b-a).normalized())
		for point in [a,b,c,a,c,d]:
			st.set_uv(Vector2(1,1))
			st.add_vertex(point)
	var stone := MeshInstance3D.new()
	stone.mesh=st.commit()
	stone.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/garden_stone44.gdshader")
	material.set_shader_parameter("seed",seed_value)
	stone.material_override=material
	content.add_child(stone)
	paving.append(at)

func _build_paving() -> void:
	_build_door_paving()
	for i in 8:
		var at := Vector2(.9+sin(i*.65)*.08,-2.65-i*.62)
		_stone(at,Vector2(.45,.43),float(i+30))
	for at in [Vector2(.26,-5.55),Vector2(1.44,-5.0),Vector2(2.3,-4.65)]: _stone(at,Vector2(.41,.43),50.+at.x)

func _build_door_paving() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed=440047
	for row in 8:
		for col in 3:
			if row>4 and col==0: continue
			var at := Vector2(-4.70+(col-1)*.44+rng.randf_range(-.06,.06),-4.15+row*.57)
			_stone(at,Vector2(rng.randf_range(.37,.46),rng.randf_range(.47,.58)),float(row*3+col))

func _occupied(at: Vector2) -> bool:
	for bed in beds:
		if bed.grow(.10).has_point(at): return true
	if garden_bounds.has_point(at):
		if absf(at.x-.9)<.40 and at.y> -7.6 and at.y< -2.7: return true
		if at.distance_to(Vector2(.25,-5.55))<.5: return true
	for stone in paving:
		if ((at-stone)/Vector2(.24,.28)).length()<1.: return true
	return false

func _prepare_cutouts() -> void:
	for batch in world.grass_batches:
		for i in batch.points.size():
			var point: Transform3D=batch.points[i]
			if not _occupied(Vector2(point.origin.x,point.origin.z)): continue
			var original: Transform3D=batch.node.multimesh.get_instance_transform(i)
			var hidden := original
			hidden.origin.y-=2.
			grass_cutouts.append({"batch":batch,"index":i,"before":original,"hidden":hidden})

func _prepare_plant_moves() -> void:
	var decor: Node3D=world.atmosphere41.decor
	var destinations: Array[Vector2]=[Vector2(-1.2,-7.),Vector2(3.1,-9.1)]
	for plant in decor.planted:
		var at := Vector2(plant.root.position.x,plant.root.position.z)
		if not garden_bounds.grow(.3).has_point(at): continue
		var next: Vector2=destinations[moved_plants.size()%destinations.size()]
		moved_plants.append({"plant":plant,"before":plant.root.position,"after":_floor(next),"index":decor.textures.shrubs.find(plant.sprite.texture)})
	for batch in decor.flower_batches:
		for i in batch.multimesh.instance_count:
			var original: Transform3D=batch.multimesh.get_instance_transform(i)
			if not garden_bounds.grow(.1).has_point(Vector2(original.origin.x,original.origin.z)): continue
			var next := original
			next.origin=_floor(Vector2(-1.2,-3.7-float(moved_flowers.size())*.6),-.018)
			moved_flowers.append({"batch":batch,"index":i,"before":original,"after":next})

func _move_plants(value: bool) -> void:
	var decor: Node3D=world.atmosphere41.decor
	for entry in moved_plants:
		var plant: Dictionary=entry.plant
		plant.root.position=entry.after if value else entry.before
		var profile: Dictionary=decor.profiles.shrubs[entry.index]
		var result: Dictionary=world.grounding.root_skirt(plant.sprite.texture,profile,plant.height,plant.root.position,world.meadow,world.terrain_enabled,.035)
		plant.sprite.position.y=-float(result.drop)
		plant.sprite.material_override.set_shader_parameter("root_cut_y",result.cut)
		plant.root.get_child(1).mesh=result.mesh
	for entry in moved_flowers: entry.batch.multimesh.set_instance_transform(entry.index,entry.after if value else entry.before)

func sync_grass_cutouts() -> void:
	if not enabled: return
	for entry in grass_cutouts: entry.batch.node.multimesh.set_instance_transform(entry.index,entry.hidden)

func set_enabled(value: bool) -> void:
	enabled=value
	content.visible=value
	for body in bodies: body.collision_layer=2 if value else 0
	for entry in grass_cutouts: entry.batch.node.multimesh.set_instance_transform(entry.index,entry.hidden if value else entry.before)
	_move_plants(value)

func _process(delta: float) -> void:
	if not enabled: return
	for crop in crops: crop.sprite.material_override.set_shader_parameter("clock",world.clock)
	# Legacy material/terrain comparison keys may rewrite the grass buffers.
	sync_left-=delta
	if sync_left<=0.:
		sync_left=.25
		sync_grass_cutouts()
