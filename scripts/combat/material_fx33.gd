extends "res://scripts/combat/sugar_fx32.gd"
var art_regions: Dictionary

func _ready() -> void:
	super._ready()
	art_regions=JSON.parse_string(FileAccess.get_file_as_string("res://assets/combat_material33/regions.json"))
	var card := QuadMesh.new()
	card.size=Vector2.ONE
	airborne.multimesh.mesh=card
	sugar.multimesh.mesh=card
	_register_sheet(airborne,"jelly_sheet_v1.png",MAX_DROPS)
	_register_sheet(ground,"jelly_sheet_v1.png",MAX_MARKS)
	_register_sheet(sugar,"sugar_sheet_v1.png",MAX_BITS)

func _register_sheet(batch: MultiMeshInstance3D,file: String,capacity: int) -> void:
	var texture: Texture2D=load("res://assets/combat_material33/"+file)
	var regions := PackedVector4Array()
	for region: Array in art_regions[file]:
		regions.append(Vector4(region[0]/float(texture.get_width()),region[1]/float(texture.get_height()),region[2]/float(texture.get_width()),region[3]/float(texture.get_height())))
	var ink := ShaderMaterial.new()
	ink.shader=preload("res://scripts/combat/material_art33.gdshader")
	ink.set_shader_parameter("sheet",texture)
	ink.set_shader_parameter("regions",regions)
	batch.material_override=ink
	batch.multimesh.instance_count=0
	batch.multimesh.use_custom_data=true
	batch.multimesh.instance_count=capacity
	batch.multimesh.visible_instance_count=0

func burst(at: Vector3,direction: Vector3,finishing: bool) -> void:
	var start := drops.size()
	super.burst(at,direction,finishing)
	for i in range(start,drops.size()): drops[i].variant=rng.randi_range(0,2)

func break_sugar(at: Vector3,direction: Vector3) -> void:
	var start := bits.size()
	super.break_sugar(at,direction)
	for i in range(start,bits.size()): bits[i].variant=rng.randi_range(0,2)+(0 if bits[i].main else 3)

func _sync() -> void:
	super._sync()
	if art_regions.is_empty(): return
	for i in drops.size():
		var drop: Dictionary=drops[i]
		var variant: int=drop.get("variant",0)
		var region: Array=art_regions["jelly_sheet_v1.png"][variant]
		var size: float=drop.size*1.55
		var basis: Basis=battle.camera.global_basis
		basis.x*=size; basis.y*=size*float(region[3])/float(region[2]); basis.z*=size
		airborne.multimesh.set_instance_transform(i,Transform3D(basis,drop.at))
		airborne.multimesh.set_instance_color(i,Color.WHITE)
		airborne.multimesh.set_instance_custom_data(i,Color(variant,0,0,0))
	for i in marks.size():
		var mark: Dictionary=marks[i]
		var variant := int(absf(mark.at.x*1000.+mark.at.z*357.))%3+3
		var fade: float=1.-smoothstep(mark.life*.55,mark.life,mark.age)
		ground.multimesh.set_instance_color(i,Color(1,1,1,.58*fade))
		ground.multimesh.set_instance_custom_data(i,Color(variant,0,0,0))

func _sync_sugar() -> void:
	super._sync_sugar()
	if art_regions.is_empty(): return
	for i in bits.size():
		var bit: Dictionary=bits[i]
		var variant: int=bit.get("variant",0)
		var region: Array=art_regions["sugar_sheet_v1.png"][variant]
		var transform := sugar.multimesh.get_instance_transform(i)
		transform.basis.y*=float(region[3])/float(region[2])
		sugar.multimesh.set_instance_transform(i,transform)
		sugar.multimesh.set_instance_custom_data(i,Color(variant,0,0,0))
		var alpha := sugar.multimesh.get_instance_color(i).a
		sugar.multimesh.set_instance_color(i,Color(1,1,1,alpha))
