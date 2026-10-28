extends RefCounted
## Tree density sets the baseline; independent clearings can override dense shade.
const CELL := 8.
var bins: Dictionary = {}
var openings: Array[Dictionary] = []
var regions: Array[Dictionary] = []
var bounds := Rect2()
var config: Dictionary
var tree_count := 0
var source_trees: Array = []

func prepare(trees: Array,meadow: RefCounted,settings: Dictionary) -> void:
	config=settings
	bounds=meadow.world_bounds
	bins.clear(); openings.clear(); regions.clear(); source_trees.clear()
	tree_count=trees.size()
	for tree in trees:
		var at := Vector2(tree.root.global_position.x,tree.root.global_position.z)
		var radius: float=clampf(tree.height*float(config.crown_radius_scale),1.4,5.5)
		var entry := Vector3(at.x,at.y,radius)
		source_trees.append([at.x,at.y,tree.height])
		var lo := Vector2i(((at-Vector2.ONE*radius*2.5)/CELL).floor())
		var hi := Vector2i(((at+Vector2.ONE*radius*2.5)/CELL).floor())
		for y in range(lo.y,hi.y+1):
			for x in range(lo.x,hi.x+1):
				var key := Vector2i(x,y)
				if not bins.has(key): bins[key]=[]
				bins[key].append(entry)
	for spec in config.regions:
		for route in meadow.named_routes:
			if route.name!=spec.route: continue
			var style: Dictionary=config.presets[spec.preset]
			var palette: Resource=load("res://assets/lighting50/warm_woodland.tres").duplicate()
			palette.opening_spacing=style.spacing
			palette.opening_radius=Vector2(style.radius[0],style.radius[1])
			palette.corridor_radius=style.corridor
			palette.seed_value+=regions.size()*937
			var baker=preload("res://scripts/art/route_light_baker50.gd").new()
			baker.prepare(route.points,palette)
			regions.append({"route":spec.route,"preset":spec.preset,"style":style,"points":route.points})
			for opening in baker.openings:
				opening.region=spec.route
				opening.preset=spec.preset
				openings.append(opening)
	# Optional landmark accents share the field without individual lamps.
	for accent in config.get("accents",[]):
		var at := Vector2(accent.at[0],accent.at[1])
		var radius := Vector2(accent.radius[0],accent.radius[1])
		var direction: Array=accent.get("forward",[0.,-1.])
		var forward := Vector2(direction[0],direction[1]).normalized()
		if forward.length_squared()<.001: forward=Vector2.UP
		openings.append({"at":at,"radius":radius.max(Vector2.ONE*.1),"forward":forward,"region":"authored","preset":"local"})

func density_at(at: Vector2) -> float:
	var total := 0.
	for tree in bins.get(Vector2i((at/CELL).floor()),[]):
		var delta := at-Vector2(tree.x,tree.y)
		var q: float=delta.length_squared()/(tree.z*tree.z)
		if q<6.25: total+=exp(-q*1.1)
	return smoothstep(.03,float(config.density_full_cover),total)

func light_at(at: Vector2) -> float:
	var light := 0.
	for opening in openings:
		var delta: Vector2=at-opening.at
		var forward: Vector2=opening.forward
		var q: Vector2=Vector2(delta.dot(forward),delta.dot(Vector2(-forward.y,forward.x)))/opening.radius
		if q.length_squared()>7.: continue
		var edge := 1.+.13*sin(at.x*1.7+at.y*.9)+.07*sin(at.y*2.3-at.x)
		light=maxf(light,exp(-q.length_squared()*1.4*edge))
	return smoothstep(.06,.72,light)

func style_at(at: Vector2) -> Dictionary:
	var closest := INF
	var selected: Dictionary=config.presets.forest
	for region in regions:
		var points: PackedVector2Array=region.points
		for i in points.size()-1:
			var v := points[i+1]-points[i]
			var t := clampf((at-points[i]).dot(v)/maxf(v.length_squared(),.0001),0.,1.)
			var d := at.distance_squared_to(points[i]+v*t)
			if d<closest: closest=d; selected=region.style
	return selected

func tint_at(at: Vector2,with_openings: bool=true) -> Color:
	var style := style_at(at)
	var density := density_at(at)
	var shade := Vector3(style.shade[0],style.shade[1],style.shade[2])
	var sun := Vector3(style.sun[0],style.sun[1],style.sun[2])
	var tint := Vector3(.96,1.,.96).lerp(shade,density*.93)
	# Bright islands override the density baseline, including in dense forest.
	if with_openings: tint=tint.lerp(sun,light_at(at))
	var weight := smoothstep(9.,15.,at.distance_to(Vector2(-4.7,-2.8)))
	return Color(tint.x/1.25,tint.y/1.25,tint.z/1.25,weight)

func bake() -> Array[Image]:
	var width: int=config.resolution[0]
	var height: int=config.resolution[1]
	var density_map := Image.create(width,height,false,Image.FORMAT_RGBA8)
	var final_map := Image.create(width,height,false,Image.FORMAT_RGBA8)
	for y in height:
		for x in width:
			var at := bounds.position+Vector2((x+.5)/width,(y+.5)/height)*bounds.size
			var base := tint_at(at,false)
			density_map.set_pixel(x,y,base)
			var style := style_at(at)
			var sun := Color(float(style.sun[0])/1.25,float(style.sun[1])/1.25,float(style.sun[2])/1.25,base.a)
			final_map.set_pixel(x,y,base.lerp(sun,light_at(at)))
	return [density_map,final_map]
