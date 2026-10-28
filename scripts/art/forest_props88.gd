extends "res://scripts/art/forest_props87.gd"
var reseated88 := 0
var omitted88 := 0

func _support88(at: Vector2,width: float) -> bool:
	var g: Vector2=world.meadow.landmarks.grove
	var low := INF;var high := -INF
	for offset in [Vector2.ZERO,Vector2(-.43,0),Vector2(.43,0),Vector2(0,-.21),Vector2(0,.21)]:
		var p: Vector2=at+offset*width
		if ((p-g)/Vector2(20.,15.)).length()<1.04: return false
		var y: float=world.floor_height(p);low=minf(low,y);high=maxf(high,y)
	return high-low<.24 and world.meadow.route_distance(at)>width*.5+1.15

func _rock87(at: Vector2,width: float,variant: int,contacts: SurfaceTool) -> void:
	var found := false;var target := at
	for distance in [0.,.75,1.5,2.25,3.,4.,5.]:
		for side in [0.,-1.5,1.5,-3.,3.]:
			var candidate: Vector2=at+Vector2(side,distance)
			if not _support88(candidate,width): continue
			target=candidate;found=true;break
		if found: break
	if not found: omitted88+=1;return
	var previous := rocks87.size()
	super._rock87(target,width,variant,contacts)
	if rocks87.size()==previous: return
	if target.distance_to(at)>.1: reseated88+=1
	# The paint already includes the elevated camera view. Face that camera
	# plane instead of foreshortening the painted slab a second time.
	var visual: Sprite3D=rocks87[-1].visual
	visual.rotation.x=deg_to_rad(-25.)
	rocks87[-1].shadow.cache_key=[];rocks87[-1].shadow.update_shadow()

func _sprite87(texture: Texture2D,at: Vector2,width: float,label: String) -> Sprite3D:
	if label.begins_with("FernAndShrub"):
		var atlas := _textures87("woodland_plants87")
		if texture==atlas[1]: texture=atlas[2]
		width=minf(width,1.05)
	var sprite := super._sprite87(texture,at,width,label)
	if label.begins_with("LowClearingFlowers"): sprite.set_meta("omit88",true)
	return sprite

func _ready() -> void:
	super._ready()
	var keep: Array[Sprite3D]=[]
	for plant in plants87:
		var at := Vector2(plant.position.x,plant.position.z)
		var width: float=plant.texture.get_width()*plant.pixel_size
		var low: float=world.floor_height(at+Vector2(-width*.35,0))
		var high: float=world.floor_height(at+Vector2(width*.35,0))
		var slope: Vector3=world.meadow.normal_at(at.x,at.y,true)
		if plant.has_meta("omit88") or slope.y<.95 or absf(high-low)>.16:
			remove_child(plant);plant.queue_free()
		else: keep.append(plant)
	plants87=keep
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for rock in rocks87: _contact87(st,rock.at+Vector2(0,.1),rock.width*.86,rock.width*.35)
	for plant in plants87: _contact87(st,Vector2(plant.position.x,plant.position.z),.55,.32)
	get_node("SoftGroundContacts87").mesh=st.commit()
	print("FOREST88_READY rocks=",rocks87.size()," plants=",plants87.size()," reseated=",reseated88," omitted=",omitted88)
