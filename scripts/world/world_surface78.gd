extends "res://scripts/world/world_surface77.gd"
var shore_bins78: Dictionary={}

func _init() -> void:
	super._init()
	water=shore_outline78(water)
	island=shore_outline78(island)
	shore_base73.water=water;shore_base73.island=island
	for polygon in [water,island]:
		for i in polygon.size():
			var a: Vector2=polygon[i];var b: Vector2=polygon[(i+1)%polygon.size()]
			var low: Vector2=a.min(b)-Vector2.ONE*9.
			var high: Vector2=a.max(b)+Vector2.ONE*9.
			for z in range(floori(low.y/8.),floori(high.y/8.)+1):
				for x in range(floori(low.x/8.),floori(high.x/8.)+1):
					var key := Vector2i(x,z)
					if not shore_bins78.has(key): shore_bins78[key]=[]
					shore_bins78[key].append([a,b])
	mesh_cache.clear()

func shore_outline78(polygon: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	for i in polygon.size():
		var a := polygon[i];var b := polygon[(i+1)%polygon.size()]
		var normal := Vector2(-(b-a).y,(b-a).x).normalized()
		var count := maxi(1,ceili(a.distance_to(b)/3.))
		for j in count:
			var t := float(j)/count
			var at := a.lerp(b,t)
			# Keep train/map edges and both approved bridge landings unchanged.
			var safe := smoothstep(0.,4.,world_bounds.end.x-at.x)
			safe*=smoothstep(2.5,6.,at.distance_to(bridge_rect.get_center())-bridge_rect.size.x*.5)
			if bridge_rect.grow(4.).has_point(at): safe=0.
			safe*=smoothstep(4.,7.,at.distance_to(landmarks.landing))
			var bend := 1.7*sin(at.x*.27+at.y*.19)+.65*sin(at.x*.63-at.y*.38)
			result.append(at+normal*bend*safe*sin(PI*t))
	return result

func shore_distance78(at: Vector2) -> float:
	var nearest := 100.
	for edge in shore_bins78.get(Vector2i(floori(at.x/8.),floori(at.y/8.)),[]):
		nearest=minf(nearest,at.distance_to(Geometry2D.get_closest_point_to_segment(at,edge[0],edge[1])))
	return nearest

func upper_front73(x: float) -> float:
	return super.upper_front73(x)-4.5*exp(-pow((x+64.)/6.,2.))+3.8*exp(-pow((x+47.)/5.,2.))-3.2*exp(-pow((x+32.)/5.,2.))

func regional_front75(x: float) -> float:
	var west := 1.-smoothstep(-35.,-25.,x)
	return super.regional_front75(x)+west*(2.4*exp(-pow((x+67.)/6.,2.))-2.2*exp(-pow((x+51.)/5.,2.)))

func height_at(x: float,z: float,enabled: bool) -> float:
	var h := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty(): return h
	var at := Vector2(x,z)
	if is_water(at): return h
	if x< -28. and absf(z-rail_z73)>5.5:
		var front := upper_front73(x)
		var wide := 1.-smoothstep(-3.8,3.8,z-front)
		var exposure := maxf(exp(-pow((x+68.)/4.5,2.)),maxf(exp(-pow((x+47.)/4.5,2.)),exp(-pow((x+29.)/3.5,2.))))
		var shoulder := lerpf(5.2,.95,exposure)
		var narrow := 1.-smoothstep(-shoulder,shoulder,z-front)
		var protect := smoothstep(1.8,3.5,route_distance(at))
		h+=(UPPER72-MAIN72)*(narrow-wide)*(1.-smoothstep(-28.,-13.,x))*protect
	if x>15. and not bridge_rect.grow(3.).has_point(at) and at.distance_to(landmarks.landing)>4.:
		var distance := shore_distance78(at)
		if distance<2.: h=lerpf(-.40,h,smoothstep(0.,2.,distance))
	return h

func is_open_ground(at: Vector2) -> bool:
	if at.x< -28. and absf(at.y-upper_front73(at.x))<3.8: return true
	if at.x>15. and shore_distance78(at)<2.: return true
	# Deliberate windows onto rear rock faces, outside the battle/root buffer.
	for spec in [Vector3(-64.,-63.,4.2),Vector3(-42.,-61.,4.),Vector3(-29.,-59.,3.6)]:
		if at.distance_to(Vector2(spec.x,spec.y))<spec.z: return true
	return super.is_open_ground(at)

func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
	if rect.intersects(Rect2(Vector2(-76,-80),Vector2(49,22))): return 48
	return super._terrain_divisions19(rect,ids)
