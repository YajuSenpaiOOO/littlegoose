extends "res://scripts/art/forest_props96.gd"
const PARK99=preload("res://scripts/world/park_layout99.gd")
func _flower_specs94() -> Array:
	return [Vector4(-5.1,-4.5,5.,3.),Vector4(-5.5,8.,4.8,2.2),Vector4(8.4,-3.,2.5,4.),Vector4(0,7.5,4.,1.7),Vector4(-2.7,3.2,2.5,1.2),Vector4(4.5,.7,1.6,2.1)]
func _flower_attempts94() -> int: return 750
func _flower_height94(rng: RandomNumberGenerator) -> float: return rng.randf_range(.18,.36)
func _flower_support94(at: Vector2) -> bool:
	if not super._flower_support94(at): return false
	var p: Vector2=at-Vector2(world.meadow.landmarks.grove)
	if PARK99.path_distance99(p)<1.5 or PARK99.on_stairs99(p): return false
	return ((p-Vector2(-.85,0))/Vector2(3.9,2.7)).length()>.88

func _ready() -> void:
	super._ready()
	var g: Vector2=world.meadow.landmarks.grove
	var keep_rocks: Array[Dictionary]=[]
	for rock in rocks87:
		var p: Vector2=rock.at-g
		var clear: bool=PARK99.path_distance99(p)>rock.width*.43+1.25 and ((p-PARK99.DECK)/Vector2(4.5,4.)).length()>1.
		if clear: keep_rocks.append(rock)
		else:
			rock.body.collision_layer=0;bodies87.erase(rock.body)
			rock.body.queue_free();rock.shadow.queue_free();rock.visual.queue_free()
	rocks87=keep_rocks
	var keep_plants: Array[Sprite3D]=[]
	for plant in plants87:
		var p: Vector2=Vector2(plant.position.x,plant.position.z)-g
		if PARK99.path_distance99(p)<1.35 or ((p-PARK99.DECK)/Vector2(4.2,3.6)).length()<1.05 or PARK99.on_stairs99(p):
			plant.queue_free()
		else: keep_plants.append(plant)
	plants87=keep_plants
	var keep_reactive: Array[Dictionary]=[]
	for plant in plants94:
		if plants87.has(plant.visual): keep_reactive.append(plant)
	plants94=keep_reactive
	var atlas := _textures87("woodland_plants87")
	for i in 40:
		if sin(i*1.71)>.75: continue
		var angle := TAU*float(i)/40.+sin(i*7.3)*.045
		var offset := PARK99.loop_point99(angle)+Vector2(cos(angle),sin(angle))*(2.2+.45*sin(i*4.7))
		var at: Vector2=g+offset
		if world.meadow.is_water(at) or world.meadow.normal_at(at.x,at.y,true).y<.96: continue
		if world.meadow.route_distance(at)<1.1 or ((offset-PARK99.DECK)/Vector2(5.,4.)).length()<1.: continue
		if offset.distance_to(PARK99.BENCH)<2.2 or offset.distance_to(PARK99.SWING)<1.8: continue
		if absf(offset.x-PARK99.LOG.x)<4. and absf(offset.y-PARK99.LOG.y)<2.4: continue
		var plant := _sprite87(atlas[2 if i%4 else 1],at,1.15 if i%4 else 1.65,"ParkBorderFern99")
		plant.material_override=_plant_material94(plant.texture);plant.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		plants87.append(plant);plants94.append({"visual":plant,"push":Vector3.ZERO,"radius":1.05})
	for anchor in [Vector2(-1,-8.1),Vector2(4.8,-7.9)]:
		for i in 4:
			var at: Vector2=g+anchor+Vector2((i-1.5)*.85,sin(i*2.4)*.35)
			if PARK99.path_distance99(at-g)<1.6 or world.meadow.normal_at(at.x,at.y,true).y<.965: continue
			var plant := _sprite87(atlas[1 if i%3==0 else 2],at,2.2 if i%3==0 else 1.4,"RearLeafBank99")
			plant.material_override=_plant_material94(plant.texture);plant.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			plants87.append(plant);plants94.append({"visual":plant,"push":Vector3.ZERO,"radius":1.15})
	# Clustered pockets, with gaps at the paths, replace the old empty outer lawn.
	for anchor in [Vector2(-7.4,3.8),Vector2(-8.1,6.3),Vector2(-6.,8.8),Vector2(-1.8,-7.4),Vector2(4.7,-7.1),Vector2(8.4,.2),Vector2(8.5,5.1),Vector2(1.5,8.4)]:
		for i in 4:
			var at: Vector2=g+anchor+Vector2(sin(i*2.5+anchor.x)*1.1,cos(i*1.9)*.7)
			if PARK99.path_distance99(at-g)<1.65 or PARK99.on_stairs99(at-g): continue
			if world.meadow.normal_at(at.x,at.y,true).y<.94: continue
			if (at-g).distance_to(PARK99.LOG)<3.8 or (at-g).distance_to(PARK99.BENCH)<2.1: continue
			var plant := _sprite87(atlas[1 if i%3==0 else 2],at,1.65 if i%3==0 else 1.1,"PocketLeafBank99")
			plant.material_override=_plant_material94(plant.texture);plant.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			plants87.append(plant);plants94.append({"visual":plant,"push":Vector3.ZERO,"radius":1.0})
	var contacts := SurfaceTool.new();contacts.begin(Mesh.PRIMITIVE_TRIANGLES)
	for rock in rocks87: _contact87(contacts,rock.at+Vector2(0,.1),rock.width*.86,rock.width*.35)
	for plant in plants87: _contact87(contacts,Vector2(plant.position.x,plant.position.z),.65,.34)
	get_node("SoftGroundContacts87").mesh=contacts.commit()
	print("PARK99_CLEAR_PATH rocks=",rocks87.size()," plants=",plants87.size())
	# Leaf banks climb the shoulders, leaving the irregular tread faces exposed.
	for offset in [Vector2(-9.7,1.5),Vector2(-9.6,.2),Vector2(-9.7,-1.6),Vector2(-9.7,-3.2),Vector2(-6.,-1.6),Vector2(-5.9,-3.4),Vector2(-10.5,-6.1),Vector2(-9.,-7.),Vector2(-7.1,-6.7)]:
		var at: Vector2=g+(PARK99.from_stair99(offset) if offset.y> -5. else offset)
		var plant := _sprite87(atlas[2],at,.75+.2*sin(offset.y*3.),"StepShoulderFern99")
		plant.material_override=_plant_material94(plant.texture);plant.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		plants87.append(plant);plants94.append({"visual":plant,"push":Vector3.ZERO,"radius":.85})
