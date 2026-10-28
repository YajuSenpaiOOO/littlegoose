extends RefCounted
## Offline world-space tint atlas: route cost is paid when baking, not per pixel.
var openings: Array[Dictionary] = []
var bounds := Rect2()
var points := PackedVector2Array()
var palette: Resource

func point_at(distance: float) -> Dictionary:
	var walked := 0.
	for i in points.size()-1:
		var length := points[i].distance_to(points[i+1])
		if distance<=walked+length or i==points.size()-2:
			return {"at":points[i].lerp(points[i+1],clampf((distance-walked)/maxf(length,.001),0.,1.)),"forward":(points[i+1]-points[i]).normalized()}
		walked+=length
	return {}

func prepare(route_points: PackedVector2Array,profile: Resource) -> void:
	points=route_points
	palette=profile
	openings.clear()
	var low := points[0]
	var high := points[0]
	var total := 0.
	for i in points.size():
		low=low.min(points[i]); high=high.max(points[i])
		if i>0: total+=points[i-1].distance_to(points[i])
	bounds=Rect2(low,high-low).grow(palette.corridor_radius+1.)
	var rng := RandomNumberGenerator.new()
	rng.seed=palette.seed_value
	var distance: float=palette.opening_spacing*.65
	while distance<total-1.:
		var pose := point_at(distance)
		var right := Vector2(-pose.forward.y,pose.forward.x)
		openings.append({"at":pose.at+right*rng.randf_range(-palette.lateral_jitter,palette.lateral_jitter),"forward":pose.forward,"radius":palette.opening_radius*rng.randf_range(.85,1.22),"distance":distance})
		distance+=palette.opening_spacing*rng.randf_range(.88,1.12)
	for accent in palette.accents:
		openings.append({"at":Vector2(accent.x,accent.y),"forward":Vector2.UP,"radius":Vector2(accent.z,accent.w),"distance":-1.})

func sample_at(at: Vector2) -> Color:
	var road_distance := INF
	for i in points.size()-1:
		var segment := points[i+1]-points[i]
		var t := clampf((at-points[i]).dot(segment)/maxf(segment.length_squared(),.0001),0.,1.)
		road_distance=minf(road_distance,at.distance_to(points[i]+segment*t))
	var weight := (1.-smoothstep(palette.corridor_radius*.48,palette.corridor_radius,road_distance))*smoothstep(9.,15.,at.distance_to(Vector2(-4.7,-2.8)))
	var light := 0.
	for opening in openings:
		var delta: Vector2=at-opening.at
		var forward: Vector2=opening.forward
		var right := Vector2(-forward.y,forward.x)
		var q: Vector2=Vector2(delta.dot(forward),delta.dot(right))/opening.radius
		var edge := 1.+.13*sin(at.x*1.7+at.y*.9)+.07*sin(at.y*2.3-at.x)
		light=maxf(light,exp(-q.length_squared()*1.4*edge))
	var tint: Vector3=palette.shade_multiplier.lerp(palette.sun_multiplier,smoothstep(.06,.72,light))
	return Color(tint.x/1.25,tint.y/1.25,tint.z/1.25,weight)

func bake() -> Image:
	var size: int=palette.map_resolution
	var image := Image.create(size,size,false,Image.FORMAT_RGBA8)
	for y in size:
		for x in size:
			image.set_pixel(x,y,sample_at(bounds.position+Vector2((x+.5)/size,(y+.5)/size)*bounds.size))
	return image
