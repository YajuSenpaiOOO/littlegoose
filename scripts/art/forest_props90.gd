extends "res://scripts/art/forest_props88.gd"
var terrace_plants90 := 0

func _ready() -> void:
	super._ready()
	var g: Vector2=world.meadow.landmarks.grove
	var atlas := _textures87("woodland_plants87")
	# Groups follow the two outcrop feet and western shoulder, never the field rim.
	for anchor in [g+Vector2(-21.,-8.),g+Vector2(-22.,2.),Vector2(-64.,-60.),Vector2(-43.,-59.),Vector2(-55.,-68.),Vector2(-72.,-38.)]:
		for i in 5:
			var at: Vector2=anchor+Vector2((i-2)*.72,sin(i*2.3)*.7)
			if world.meadow.route_distance(at)<2. or ((at-g)/Vector2(20.,15.)).length()<1.12: continue
			if world.meadow.normal_at(at.x,at.y,true).y<.93: continue
			var height: float=world.floor_height(at)
			if absf(world.floor_height(at+Vector2(.5,0))-height)>.18 or absf(world.floor_height(at+Vector2(-.5,0))-height)>.18: continue
			var plant := _sprite87(atlas[2],at,1.15+float(i%3)*.18,"TerraceFern90_%02d"%terrace_plants90)
			plants87.append(plant);terrace_plants90+=1
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for rock in rocks87: _contact87(st,rock.at+Vector2(0,.1),rock.width*.86,rock.width*.35)
	for plant in plants87: _contact87(st,Vector2(plant.position.x,plant.position.z),.65,.34)
	get_node("SoftGroundContacts87").mesh=st.commit()
	print("TERRACE90_PLANTS ",terrace_plants90)
