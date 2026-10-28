extends "res://scripts/art/forest_props90.gd"
var understory92 := 0
func _ready() -> void:
	super._ready()
	var g: Vector2=world.meadow.landmarks.grove
	var atlas := _textures87("woodland_plants87")
	for anchor in [Vector2(9.,16.),Vector2(24.,7.),Vector2(-21.,10.),Vector2(-20.,-11.),Vector2(22.,-5.)]:
		for i in 4:
			var at: Vector2=g+anchor+Vector2((i-1.5)*1.05,sin(i*2.1)*.8)
			if ((at-g)/Vector2(20.,15.)).length()<1.05 or world.meadow.route_distance(at)<1.8: continue
			if world.meadow.normal_at(at.x,at.y,true).y<.96: continue
			var seated := true
			for rock in rocks87:
				if absf(at.x-rock.at.x)<rock.width*.40 and absf(at.y-rock.at.y)<rock.width*.23: seated=false
			if not seated: continue
			var width := 2.1 if i%3==0 else 1.35
			var plant := _sprite87(atlas[1 if i%3==0 else 2],at,width,"GroupedUnderstory92_%02d"%understory92)
			plants87.append(plant);understory92+=1
	var contacts := SurfaceTool.new();contacts.begin(Mesh.PRIMITIVE_TRIANGLES)
	for rock in rocks87: _contact87(contacts,rock.at+Vector2(0,.1),rock.width*.86,rock.width*.35)
	for plant in plants87: _contact87(contacts,Vector2(plant.position.x,plant.position.z),.65,.34)
	get_node("SoftGroundContacts87").mesh=contacts.commit()
	print("UNDERSTORY92 plants=",understory92)
