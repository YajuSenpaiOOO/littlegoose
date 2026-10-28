extends "res://scripts/art/kitchen_garden44.gd"
var material_stage := 1
var shadows_enabled := true
var stone_materials: Array[ShaderMaterial]=[]
var shadow_targets: Array[GeometryInstance3D]=[]
var contacts: Array[MeshInstance3D]=[]
var wood_texture: Texture2D=preload("res://assets/garden45/wood.png")
var stone_texture: Texture2D=preload("res://assets/garden45/slate.png")

func _ready() -> void:
	super._ready()
	name="PaintedGarden45"
	for child in content.get_children():
		if child is MeshInstance3D and child.material_override is ShaderMaterial:
			var material: ShaderMaterial=child.material_override
			if material.shader==preload("res://scripts/art/garden_stone44.gdshader"):
				stone_materials.append(material)
	set_material_stage(1)
	_build_shadows()
	set_shadows(true)
	print("GARDEN45_READY shadow_targets=",shadow_targets.size()," contacts=",contacts.size())

func _beam(a: Vector3,b: Vector3,width: float,height: float,collides := false) -> MeshInstance3D:
	var node: MeshInstance3D=super._beam(a,b,width,height,collides)
	# Encode grain in each beam's own long axis before the static mesh is merged.
	_remap_wood(node,false)
	return node

func _post(at: Vector2,height: float) -> void:
	var before: int=wood_pieces.size()
	super._post(at,height)
	if wood_pieces.size()>before: _remap_wood(wood_pieces.back(),true,at)

func _remap_wood(node: MeshInstance3D,vertical: bool,at := Vector2.ZERO) -> void:
	var arrays: Array=node.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
	var uvs := PackedVector2Array()
	for i in vertices.size():
		var p: Vector3=vertices[i]
		var n: Vector3=normals[i].abs()
		if vertical:
			p-=_floor(at,-.025)
			if n.y>.8: uvs.append(Vector2(p.x,p.z)*3.+at)
			else: uvs.append(Vector2(p.y*1.2,(p.x if n.z>n.x else p.z)*3.)+at)
		elif n.z>.8:
			uvs.append(Vector2(p.x,p.y)*3.)
		else:
			uvs.append(Vector2(p.z*1.2,(p.x if n.y>n.x else p.y)*3.)+Vector2(node.position.x*.173,node.position.z*.231))
	arrays[Mesh.ARRAY_TEX_UV]=uvs
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	node.mesh=mesh

func set_material_stage(stage: int) -> void:
	material_stage=clampi(stage,0,2)
	wood_material.shader=preload("res://scripts/art/garden_wood45.gdshader") if material_stage>=1 else preload("res://scripts/art/garden_wood44.gdshader")
	if material_stage>=1: wood_material.set_shader_parameter("paint",wood_texture)
	for material in stone_materials:
		material.shader=preload("res://scripts/art/garden_stone45.gdshader") if material_stage>=2 else preload("res://scripts/art/garden_stone44.gdshader")
		if material_stage>=2: material.set_shader_parameter("paint",stone_texture)

func _contact(parent: Node3D,at: Vector2,size: Vector2,lift: float,strength: float) -> void:
	# Fit even the soft root darkening to terrain; no floating horizontal cards.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in 3:
		for x in 3:
			for offset in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var uv: Vector2=(Vector2(x,z)+offset)/3.
				var point: Vector2=at+(uv-Vector2(.5,.5))*size
				st.set_uv(uv)
				st.set_normal(Vector3.UP)
				st.add_vertex(parent.to_local(_floor(point,lift)))
	var node := MeshInstance3D.new()
	node.name="SoftRootContact45"
	node.mesh=st.commit()
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/garden_contact45.gdshader")
	material.set_shader_parameter("strength",strength)
	node.material_override=material
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	contacts.append(node)

func _build_shadows() -> void:
	for crop in crops:
		shadow_targets.append(crop.sprite)
		var size := .30 if crop.variant<2 else (.21 if crop.variant==2 else .29)
		_contact(content,crop.at,Vector2(size,size*.66),.032,.20)
	var decor: Node3D=world.atmosphere41.decor
	for plant in decor.planted:
		shadow_targets.append(plant.sprite)
		shadow_targets.append(plant.root.get_child(1))
		var at := Vector2(plant.root.position.x,plant.root.position.z)
		_contact(plant.root,at,Vector2(plant.height*.70,plant.height*.28),.014,.23)
	for batch in decor.flower_batches: shadow_targets.append(batch)
	for stone in decor.stones: shadow_targets.append(stone.sprite)

func set_shadows(value: bool) -> void:
	shadows_enabled=value
	for target in shadow_targets:
		target.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED if value else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for contact in contacts: contact.visible=value

func _process(delta: float) -> void:
	super._process(delta)
	if not enabled: return
	for crop in crops: crop.sprite.material_override.set_shader_parameter("walker",world.hero.position)
