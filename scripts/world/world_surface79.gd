extends "res://scripts/world/world_surface78.gd"
const OLD_EAST79 := 65.175
var ground_patches79: Array[Dictionary]=[]

func _init() -> void:
	super._init()
	# Extend the lake, not the cottage/forest/station layout. The old shoreline
	# touching the east world edge becomes open water and a separate far bank.
	world_bounds.size.x+=58.
	for i in water.size():
		if water[i].x>OLD_EAST79-.15: water[i].x=OLD_EAST79+40.+1.6*sin(water[i].y*.14)
	for i in island.size():
		var p := island[i]
		var weight := smoothstep(bridge_rect.end.x+1.,bridge_rect.end.x+6.,p.x)
		p.x+=maxf(0.,p.x-bridge_rect.end.x-1.)*.55
		p.y=lerpf(p.y,landmarks.shore.y+(p.y-landmarks.shore.y)*1.22,weight)
		island[i]=p
	water=shore_outline78(water);island=shore_outline78(island)
	shore_base73.water=water;shore_base73.island=island
	shore_bins78.clear()
	for polygon in [water,island]:
		for i in polygon.size():
			var a: Vector2=polygon[i];var b: Vector2=polygon[(i+1)%polygon.size()]
			var lo: Vector2=a.min(b)-Vector2.ONE*9.;var hi: Vector2=a.max(b)+Vector2.ONE*9.
			for z in range(floori(lo.y/8.),floori(hi.y/8.)+1):
				for x in range(floori(lo.x/8.),floori(hi.x/8.)+1):
					var key := Vector2i(x,z)
					if not shore_bins78.has(key): shore_bins78[key]=[]
					shore_bins78[key].append([a,b])
	landmarks.shore+=Vector2(6.,0.)
	for clearing in clearings:
		if clearing.at.distance_to(landmarks.shore-Vector2(6.,0.))<1.:
			clearing.at=landmarks.shore;clearing.radius=Vector2(20.,12.)
	var home: Dictionary=named_road77("home_to_junction")
	home.controls.insert(0,landmarks.home+Vector2(0.,.04))
	home.points=_smooth(home.controls);main_route=home.controls;route=home.points
	var shore: Dictionary=named_road77("junction_to_shore")
	shore.controls[-1]=landmarks.shore;shore.points=_smooth(shore.controls)
	_reindex_routes()
	road_endings77.clear()
	for spec in [["junction_to_grove",4.5],["junction_to_shore",4.0],["home_to_landing",1.4]]:
		var end: Vector2=named_road77(spec[0]).points[-1]
		road_endings77.append(Vector4(end.x,end.y,spec[1],0.))
	rail_alignment73.y=world_bounds.end.x
	rail_rect72.size.x=world_bounds.end.x-rail_rect72.position.x
	train_clearance72.size.x=world_bounds.end.x-train_clearance72.position.x
	# kind 0: worn yard earth; 1: woodland leaf/soil; 2: flower meadow base.
	ground_patches79=[
		{"area":Vector4(-4.5,-2.8,3.5,2.5),"kind":0},
		{"area":Vector4(1.6,-3.8,2.8,2.3),"kind":0},
		{"area":Vector4(-66.,-53.,5.,3.7),"kind":1},
		{"area":Vector4(-28.,-56.,4.8,3.5),"kind":1},
		{"area":Vector4(-22.,-23.,4.4,3.),"kind":1},
		{"area":Vector4(-11.,.9,2.8,1.8),"kind":2},
		{"area":Vector4(-35.,-29.,3.8,2.4),"kind":2},
		{"area":Vector4(landmarks.shore.x+6.,landmarks.shore.y+3.,4.,2.7),"kind":2}]

func ground_cover79(at: Vector2) -> Vector2:
	var kind := 0.;var amount := 0.
	for patch in ground_patches79:
		var a: Vector4=patch.area
		var d := ((at-Vector2(a.x,a.y))/Vector2(a.z,a.w)).length()
		var weight := 1.-smoothstep(.35,1.15,d)
		if weight>amount: amount=weight;kind=patch.kind
	return Vector2(kind,amount)

func lake_pieces79() -> Array[PackedVector2Array]:
	# Godot returns hole contours separately. A simple triangulator cannot
	# consume those as filled polygons. Split through the island first so
	# each subtraction is open to the split edge and has no inner hole.
	var split: float=landmarks.shore.x
	var bounds := world_bounds.grow(8.)
	var result: Array[PackedVector2Array]=[]
	for rect in [Rect2(bounds.position,Vector2(split-bounds.position.x,bounds.size.y)),Rect2(Vector2(split,bounds.position.y),Vector2(bounds.end.x-split,bounds.size.y))]:
		var cut := PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
		for half in Geometry2D.intersect_polygons(water,cut):
			for piece in Geometry2D.clip_polygons(half,island):
				var clean: PackedVector2Array=piece
				for pass_index in 3:
					var next := PackedVector2Array()
					for i in clean.size():
						var a := clean[(i+clean.size()-1)%clean.size()];var b := clean[i];var c := clean[(i+1)%clean.size()]
						if absf((b-a).cross(c-b))>.0001: next.append(b)
					if next.size()<3: break
					clean=next
				result.append(clean)
	return result

func height_at(x: float,z: float,enabled: bool) -> float:
	var h := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return h
	var at := Vector2(x,z)
	if is_water(at): return h
	# The distant shore is low forest, with a broad bank rather than another
	# sheer station-height wall. Preserve the full flat railway strip.
	if x>OLD_EAST79+20. and absf(z-rail_z73)>6.:
		var low := .45+.12*sin(x*.12+z*.08)
		h=lerpf(h,low,smoothstep(OLD_EAST79+20.,OLD_EAST79+29.,x))
	if x>20. and not bridge_rect.grow(3.).has_point(at) and at.distance_to(landmarks.landing)>4.:
		var distance := shore_distance78(at)
		if distance<4.5: h=lerpf(-.40,h,smoothstep(0.,4.5,distance))
	return h
