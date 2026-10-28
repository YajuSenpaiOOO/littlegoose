extends "res://scripts/art/forest_props92.gd"
var finger_plants93 := 0
var finger_rocks93 := 0

func _finger_rock93(at: Vector2,width: float,variant: int) -> void:
	if world.meadow.route_distance(at)<width*.5+1.2: return
	var low := INF;var high := -INF
	for offset in [Vector2.ZERO,Vector2(-.42,0),Vector2(.42,0),Vector2(0,-.19),Vector2(0,.19)]:
		var h: float=world.floor_height(at+offset*width);low=minf(low,h);high=maxf(high,h)
	if high-low>.26: return
	var visual := _sprite87(_textures87("moss_boulders87")[variant],at,width,"FingerMossRock93")
	visual.position.y=low-.075;visual.rotation.x=deg_to_rad(-25.)
	var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0
	var shape := ConvexPolygonShape3D.new();var points := PackedVector3Array()
	var height: float=visual.texture.get_height()*visual.pixel_size
	for y in [low-.12,low+height*.82]:
		for i in 12:
			var angle := TAU*i/12.;points.append(Vector3(at.x+cos(angle)*width*.42,y,at.y+sin(angle)*width*.19))
	shape.points=points
	var collider := CollisionShape3D.new();collider.shape=shape;body.add_child(collider);add_child(body);bodies87.append(body)
	var shadow := preload("res://scripts/art/grounded_prop_shadow63.gd").new()
	shadow.world=world;shadow.visual=visual;add_child(shadow);shadow.update_shadow()
	rocks87.append({"at":at,"width":width,"visual":visual,"body":body,"shadow":shadow,"fade":1.})
	finger_rocks93+=1

func _ready() -> void:
	super._ready()
	var g: Vector2=world.meadow.landmarks.grove
	for spec in [Vector4(-6.8,-1.,3.4,2),Vector4(-13.,2.5,2.5,1),Vector4(6.8,-7.5,3.2,0),Vector4(15.,-7.5,2.4,2)]:
		_finger_rock93(g+Vector2(spec.x,spec.y),spec.z,int(spec.w))
	var atlas := _textures87("woodland_plants87")
	for side in 2:
		for i in 22:
			var t := float(i)/21.
			var at := g+Vector2(lerpf(-20.,-7.,t),lerpf(9.,-2.,t)+sin(i*2.4)*1.7) if side==0 else g+Vector2(lerpf(21.,7.,t),-9.+sin(i*2.4)*1.6)
			if world.meadow.route_distance(at)<1.9 or world.meadow.normal_at(at.x,at.y,true).y<.96: continue
			var blocked := false
			for rock in rocks87:
				if absf(at.x-rock.at.x)<rock.width*.4 and absf(at.y-rock.at.y)<rock.width*.23: blocked=true
			if blocked: continue
			var plant := _sprite87(atlas[1 if i%4==0 else 2],at,1.9 if i%4==0 else 1.3,"FingerUnderstory93")
			plants87.append(plant);finger_plants93+=1
	var contacts := SurfaceTool.new();contacts.begin(Mesh.PRIMITIVE_TRIANGLES)
	for rock in rocks87: _contact87(contacts,rock.at+Vector2(0,.1),rock.width*.86,rock.width*.35)
	for plant in plants87: _contact87(contacts,Vector2(plant.position.x,plant.position.z),.65,.34)
	get_node("SoftGroundContacts87").mesh=contacts.commit()
	print("FINGERS93 plants=",finger_plants93," rocks=",finger_rocks93)
