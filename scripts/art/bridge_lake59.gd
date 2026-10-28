extends Node3D
const BRIDGES := ["A 手绘绳栏木桥","B 立体交叉栏木桥","C 石砌混合桥"]
const WATERS := ["A 绘本池水","B 清透浅水","C 静谧蓝湖"]
var world: Node3D
var bridge_style := 0
var water_style := 0
var variants: Array[Node3D] = []
var rect := Rect2()
var shore_material: ShaderMaterial
var paint_materials: Array[ShaderMaterial] = []
var submerged_trees: Array[Node3D] = []
var draw_pieces := 0

func _ready() -> void:
	name="BridgeLakeThreeStudies59"
	rect=world.meadow.bridge_rect
	for i in 3:
		var node := Node3D.new()
		node.name="BridgeVariant"+str(i)
		add_child(node)
		variants.append(node)
	_build_painted_wood()
	_build_solid_wood()
	_build_stone_hybrid()
	_build_shore()
	var water: ShaderMaterial=world.water_material19
	water.shader=preload("res://scripts/art/lake59.gdshader")
	water.set_shader_parameter("water_paint59",preload("res://assets/bridge59/painted_water.png"))
	water.set_shader_parameter("shore59",preload("res://assets/bridge59/shore_distance.png"))
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/bridge59/shore_distance.json"))
	var b: Array=data.bounds
	water.set_shader_parameter("bounds59",Vector4(b[0],b[1],b[2],b[3]))
	# Existing trees whose root cards overlap the walkable bridge are removed
	# equally in all three studies; do not clear the surrounding forest belt.
	for tree in world.trees:
		var p: Vector3=tree.root.position
		if not rect.grow(.35).has_point(Vector2(p.x,p.z)): continue
		submerged_trees.append(tree.root)
		tree.root.hide()
		for child in tree.root.get_children():
			if child is StaticBody3D: child.collision_layer=0
	set_pair(0)
	print("BRIDGE59_STUDIES_READY pieces=",draw_pieces," bridge_clearance=",submerged_trees.size())

func _paint(path: String,region: Rect2i) -> ShaderMaterial:
	var texture: Texture2D=load(path)
	var size := Vector2(texture.get_size())
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/bridge_paint59.gdshader")
	material.set_shader_parameter("paint",texture)
	material.set_shader_parameter("region59",Vector4(region.position.x/size.x,region.position.y/size.y,region.size.x/size.x,region.size.y/size.y))
	paint_materials.append(material)
	return material

func _card(parent: Node3D,at: Vector3,size: Vector2,material: ShaderMaterial) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := QuadMesh.new()
	mesh.size=size
	node.mesh=mesh
	node.position=at+Vector3.UP*size.y*.5
	node.material_override=material
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	parent.add_child(node)
	draw_pieces+=1
	return node

func _deck(parent: Node3D,material: ShaderMaterial,inset := 0.) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count := 6
	for i in count:
		var left := rect.position.x+rect.size.x*float(i)/count
		var right := rect.position.x+rect.size.x*float(i+1)/count
		for uv in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
			var x := lerpf(left,right,uv.x)
			var z := lerpf(rect.position.y,rect.end.y,uv.y)
			st.set_uv(Vector2(lerpf(inset,0.,uv.y)+uv.x*(1.-lerpf(inset,0.,uv.y)*2.),uv.y))
			st.set_normal(Vector3.UP)
			st.add_vertex(Vector3(x,world.meadow.bridge_height(x)+.016,z))
	var node := MeshInstance3D.new()
	node.mesh=st.commit()
	node.material_override=material
	parent.add_child(node)
	draw_pieces+=1

func _build_painted_wood() -> void:
	var path := "res://assets/bridge59/painted_wood_kit.png"
	var rail := _paint(path,Rect2i(105,64,1327,231))
	var deck := _paint(path,Rect2i(96,330,1344,431))
	var fascia := _paint(path,Rect2i(69,803,1397,154))
	_deck(variants[0],deck)
	var span := rect.size.x/6.
	for i in 6:
		var x := rect.position.x+span*(float(i)+.5)
		var floor_y: float=world.meadow.bridge_height(x)
		for z in [rect.position.y,rect.end.y]:
			_card(variants[0],Vector3(x,floor_y+.015,z),Vector2(span,1.05),rail)
			_card(variants[0],Vector3(x,floor_y-.38,z),Vector2(span,.40),fascia)

func _wood_material(seed: int,stone := false) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/bridge_wood59.gdshader")
	material.set_shader_parameter("wood59",preload("res://assets/garden45/slate.png") if stone else preload("res://assets/garden45/wood.png"))
	material.set_shader_parameter("tint59",Vector3(1.04,1.04,.98) if stone else Vector3(.82,.91,.96))
	material.set_shader_parameter("seed59",float(seed))
	return material

func _box_into(st: SurfaceTool,at: Vector3,size: Vector3,basis := Basis.IDENTITY) -> void:
	var box := BoxMesh.new()
	box.size=size
	st.append_from(box,0,Transform3D(basis,at))

func _beam_into(st: SurfaceTool,a: Vector3,b: Vector3,width: float) -> void:
	var direction := (b-a).normalized()
	_box_into(st,(a+b)*.5,Vector3(width,a.distance_to(b),width),Basis(Quaternion(Vector3.UP,direction)))

func _finish_solid(parent: Node3D,st: SurfaceTool,material: ShaderMaterial) -> void:
	var mesh := st.commit()
	var node := MeshInstance3D.new()
	node.mesh=mesh
	node.material_override=material
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	parent.add_child(node)
	draw_pieces+=1

func _build_solid_wood() -> void:
	var deck := SurfaceTool.new()
	deck.begin(Mesh.PRIMITIVE_TRIANGLES)
	var boards := 66
	var width := rect.size.x/boards
	for i in boards:
		var x := rect.position.x+width*(i+.5)
		_box_into(deck,Vector3(x,world.meadow.bridge_height(x)-.105,rect.get_center().y),Vector3(width-.018,.23,rect.size.y+.12))
	_finish_solid(variants[1],deck,_wood_material(1))
	var rails := SurfaceTool.new()
	rails.begin(Mesh.PRIMITIVE_TRIANGLES)
	var caps := SurfaceTool.new()
	caps.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in [rect.position.y,rect.end.y]:
		for i in 13:
			var x := lerpf(rect.position.x,rect.end.x,float(i)/12.)
			var y: float=world.meadow.bridge_height(x)
			_box_into(rails,Vector3(x,y+.52,z),Vector3(.20,1.10,.20))
			_box_into(caps,Vector3(x,y+1.09,z),Vector3(.29,.13,.29))
			if i==12: continue
			var end := lerpf(rect.position.x,rect.end.x,float(i+1)/12.)
			var end_y: float=world.meadow.bridge_height(end)
			_beam_into(rails,Vector3(x,y+.94,z),Vector3(end,end_y+.94,z),.14)
			_beam_into(rails,Vector3(x+.12,y+.22,z),Vector3(end-.12,end_y+.82,z),.095)
			_beam_into(rails,Vector3(x+.12,y+.82,z),Vector3(end-.12,end_y+.22,z),.095)
	_finish_solid(variants[1],rails,_wood_material(2))
	_finish_solid(variants[1],caps,_wood_material(3))

func _build_stone_hybrid() -> void:
	var path := "res://assets/bridge59/painted_stone_kit.png"
	var parapet := _paint(path,Rect2i(172,49,1193,177))
	var deck := _paint(path,Rect2i(114,270,1314,315))
	var arch := _paint(path,Rect2i(115,626,1306,350))
	_deck(variants[2],deck,.095)
	for z in [rect.position.y,rect.end.y]:
		for i in 6:
			var span := rect.size.x/6.
			var x := rect.position.x+(i+.5)*span
			_card(variants[2],Vector3(x,world.meadow.bridge_height(x)+.015,z),Vector2(span,.72),parapet)
		for i in 3:
			var span := rect.size.x/3.
			var x := rect.position.x+(i+.5)*span
			_card(variants[2],Vector3(x,world.meadow.bridge_height(x)-1.05,z),Vector2(span,1.07),arch)
	var caps := SurfaceTool.new()
	caps.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in [rect.position.y,rect.end.y]:
		for i in 30:
			var x := rect.position.x+(i+.5)*rect.size.x/30.
			_box_into(caps,Vector3(x,world.meadow.bridge_height(x)+.74,z),Vector3(rect.size.x/30.-.018,.10,.32))
	_finish_solid(variants[2],caps,_wood_material(4,true))

func _shore_water_height() -> float:
	return -.255

func _build_shore() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for polygon in [world.meadow.water,world.meadow.island]:
		for i in polygon.size():
			var a: Vector2=polygon[i]
			var b: Vector2=polygon[(i+1)%polygon.size()]
			var tangent := (b-a).normalized()
			var inward := Vector2(-tangent.y,tangent.x)
			if not world.meadow.is_water((a+b)*.5+inward*.3): inward=-inward
			var steps := maxi(1,ceili(a.distance_to(b)/.55))
			for part in steps:
				var p := a.lerp(b,float(part)/steps)
				var q := a.lerp(b,float(part+1)/steps)
				# Keep the established bridge ramps and deck approach clear.
				if rect.grow(.3).has_point((p+q)*.5): continue
				for band in 6:
					for raw in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
						var uv := Vector2(raw.x,(float(band)+raw.y)/6.)
						var pos := p.lerp(q,uv.x)+inward*lerpf(-.8,.5,uv.y)
						var land := p.lerp(q,uv.x)-inward*.8
						# Cover the old coarse grass cliff before sloping into water.
						var h: float=lerpf(world.floor_height(land)+.035,_shore_water_height(),smoothstep(.62,1.,uv.y))
						st.set_normal(Vector3.UP)
						st.set_uv(uv)
						st.add_vertex(Vector3(pos.x,h,pos.y))
	var node := MeshInstance3D.new()
	node.name="SoftEarthStoneBanks59"
	node.mesh=st.commit()
	shore_material=ShaderMaterial.new()
	shore_material.shader=preload("res://scripts/art/lakeshore59.gdshader")
	node.material_override=shore_material
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)

func set_pair(style: int) -> void:
	set_bridge(style)
	set_water(style)

func set_bridge(style: int) -> void:
	bridge_style=clampi(style,0,2)
	for i in variants.size(): variants[i].visible=i==bridge_style
	world._title35()

func set_water(style: int) -> void:
	water_style=posmod(style,3)
	world.water_material19.set_shader_parameter("water_style59",water_style)
	shore_material.set_shader_parameter("style59",water_style)
	world._title35()

func _process(_delta: float) -> void:
	if not is_instance_valid(world.time55): return
	var hour: float=world.time55.visual_hour
	world.water_material19.set_shader_parameter("night59",smoothstep(18.5,21.,hour))
	world.water_material19.set_shader_parameter("sunset59",smoothstep(15.,18.,hour)*(1.-smoothstep(18.5,20.,hour)))
