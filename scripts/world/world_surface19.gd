extends "res://scripts/art/path_surface18.gd"
## Shared geography from the old plan; metres and prop sizes are independent.
var plan: Dictionary = {}
var landmarks: Dictionary = {}
var named_routes: Array[Dictionary] = []
var segments: Array[Dictionary] = []
var bins: Dictionary = {}
var chunks: Array[Dictionary] = []
var world_bounds := Rect2()
var water := PackedVector2Array()
var island := PackedVector2Array()
var clearings: Array[Dictionary] = []
var bridge_rect := Rect2()
var geo_scale := 1.3/24.
const CELL := 8.

func _init() -> void:
	super._init()
	plan = JSON.parse_string(FileAccess.get_file_as_string("res://docs/world-restart-layout.json"))
	geo_scale = float(plan.spacing_scale)/24.
	world_bounds = Rect2(from_plan(Vector2.ZERO),Vector2(2400,1600)*geo_scale)
	for key in plan.landmarks: landmarks[key] = from_plan(Vector2(plan.landmarks[key][0],plan.landmarks[key][1]))
	landmarks.home = Vector2(-4.7,-4.8)
	landmarks.landing = from_plan(Vector2(1540,1240))
	for p in plan.water: water.append(from_plan(Vector2(p[0],p[1])))
	for p in plan.island: island.append(from_plan(Vector2(minf(p[0],2400),p[1])))
	bridge_rect = Rect2(from_plan(Vector2(1490,740)),Vector2(400,80)*geo_scale)
	for c in plan.clearings:
		clearings.append({"at":from_plan(Vector2(c[0],c[1])),"radius":Vector2(c[2],c[3])*geo_scale})
	named_routes.clear()
	for source in plan.routes:
		var controls := PackedVector2Array()
		for p in source.points: controls.append(from_plan(Vector2(p[0],p[1])))
		var smooth := _smooth(controls)
		var radius := .77*float(source.width)/72.
		named_routes.append({"name":source.name,"points":smooth,"controls":controls,"radius":radius})
		if source.name=="home_to_junction":
			route = smooth
			main_route = controls
		for i in range(smooth.size()-1):
			var item := {"a":smooth[i],"b":smooth[i+1],"radius":radius,"route":source.name}
			var index := segments.size()
			segments.append(item)
			var lo: Vector2 = smooth[i].min(smooth[i+1])-Vector2.ONE*5.
			var hi: Vector2 = smooth[i].max(smooth[i+1])+Vector2.ONE*5.
			for z in range(floori(lo.y/CELL),floori(hi.y/CELL)+1):
				for x in range(floori(lo.x/CELL),floori(hi.x/CELL)+1):
					var key := Vector2i(x,z)
					if not bins.has(key): bins[key] = []
					bins[key].append(index)

func from_plan(at: Vector2) -> Vector2:
	return (at-Vector2(1110,1172))*geo_scale+Vector2(-4.7,-4.8)

func _smooth(points: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array([points[0]])
	for i in range(1,points.size()-1):
		var corner := points[i]
		var incoming := corner-points[i-1]
		var outgoing := points[i+1]-corner
		var r := minf(1.35,minf(incoming.length(),outgoing.length())*.22)
		var a := corner-incoming.normalized()*r
		var b := corner+outgoing.normalized()*r
		result.append(a)
		for step in range(1,4):
			var t := float(step)/3.
			result.append(a*(1.-t)*(1.-t)+corner*2.*t*(1.-t)+b*t*t)
	result.append(points[-1])
	return result

func route_distance(at: Vector2) -> float:
	var result := 100.
	for index in bins.get(Vector2i(floori(at.x/CELL),floori(at.y/CELL)),[]):
		var s: Dictionary = segments[index]
		var v: Vector2 = s.b-s.a
		var t := clampf((at-s.a).dot(v)/maxf(v.length_squared(),.001),0.,1.)
		result = minf(result,at.distance_to(s.a+v*t)*.77/s.radius)
	return result

func is_water(at: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(at,water) and not Geometry2D.is_point_in_polygon(at,island)

func contains_soil(at: Vector2) -> bool:
	return not bridge_rect.has_point(at) and not station_paving_rect().has_point(at) and not is_water(at) and route_distance(at)<.65

func station_paving_rect() -> Rect2:
	return Rect2(landmarks.station+Vector2(-8,-4.8),Vector2(16,6))

func is_open_ground(at: Vector2) -> bool:
	for c in clearings:
		if ((at-c.at)/c.radius).length()<1.: return true
	return at.distance_to(landmarks.junction)<5.3

func height_at(x: float,z: float,enabled: bool) -> float:
	if not enabled: return 0.
	var at := Vector2(x,z)
	if is_water(at): return -1.35
	var d := route_distance(at)
	var h := .12+.085*sin(z*.085)+noise.get_noise_2d(x,z)*.065
	var banks := .58*exp(-((x+22.)*(x+22.)+(z+28.)*(z+28.))/160.)
	banks += .7*exp(-((x-18.)*(x-18.)+(z+34.)*(z+34.))/200.)
	h += banks*smoothstep(1.15,4.,d)
	h = lerpf(h,.12,1.-smoothstep(3.9,6.5,at.distance_to(Vector2(-4.7,-6.7))))
	h = lerpf(h,.20,1.-smoothstep(6.,9.,at.distance_to(landmarks.station)))
	var station_factor := smoothstep(3.5,5.5,at.distance_to(landmarks.station+Vector2(0,-1.8)))
	return h-profile.depression(d,at.distance_to(landmarks.home))*station_factor

func walk_height(at: Vector2,enabled: bool) -> float:
	return bridge_height(at.x) if bridge_rect.has_point(at) else height_at(at.x,at.y,enabled)

func bridge_height(x: float) -> float:
	var a := height_at(bridge_rect.position.x-.2,bridge_rect.get_center().y,true)
	var b := height_at(bridge_rect.end.x+.2,bridge_rect.get_center().y,true)
	var y := lerpf(a,.24,smoothstep(0.,1.3,x-bridge_rect.position.x))
	return lerpf(y,b,smoothstep(0.,1.3,x-bridge_rect.end.x+1.3))

func chunk_segments(rect: Rect2) -> Array[int]:
	var result: Array[int] = []
	for i in segments.size():
		var s: Dictionary = segments[i]
		var box := Rect2(s.a.min(s.b),s.a.max(s.b)-s.a.min(s.b)).grow(s.radius+1.)
		if rect.intersects(box,true): result.append(i)
	return result

func terrain(enabled: bool) -> ArrayMesh:
	var signature := "%s/%s/%.4f"%[enabled,profile.enabled,profile.depth]
	if mesh_cache.has(signature): return mesh_cache[signature]
	var mesh := ArrayMesh.new()
	chunks.clear()
	var bounds := world_bounds.grow(6.)
	for iz in ceili(bounds.size.y/16.):
		for ix in ceili(bounds.size.x/16.):
			var origin := bounds.position+Vector2(ix,iz)*16.
			var size := (bounds.end-origin).min(Vector2(16,16))
			var rect := Rect2(origin,size)
			var ids := chunk_segments(rect)
			var divisions := _terrain_divisions19(rect,ids)
			var w := divisions+1
			var heights := PackedFloat32Array()
			for z in w:
				for x in w:
					var at := origin+Vector2(float(x)/divisions,float(z)/divisions)*size
					heights.append(height_at(at.x,at.y,enabled))
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			for z in w:
				for x in w:
					var at := origin+Vector2(float(x)/divisions,float(z)/divisions)*size
					var left := maxi(0,x-1)
					var right := mini(w-1,x+1)
					var front := maxi(0,z-1)
					var back := mini(w-1,z+1)
					var dx := (heights[z*w+right]-heights[z*w+left])/((right-left)*size.x/divisions)
					var dz := (heights[back*w+x]-heights[front*w+x])/((back-front)*size.y/divisions)
					st.set_normal(Vector3(-dx,1,-dz).normalized())
					st.set_uv(at/6.)
					st.add_vertex(Vector3(at.x,heights[z*w+x],at.y))
			for z in divisions:
				for x in divisions:
					var a := z*w+x
					for index in [a,a+1,a+w+1,a,a+w+1,a+w]: st.add_index(index)
			st.commit(mesh)
			chunks.append({"rect":rect,"segments":ids})
	mesh_cache[signature] = mesh
	return mesh

func _terrain_divisions19(_rect: Rect2,ids: Array[int]) -> int:
	return 40 if not ids.is_empty() else 20
