extends "res://scripts/art/forest_landscape13.gd"
var route := PackedVector2Array()
var main_route := PackedVector2Array()
func _init() -> void:
	super._init()
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://docs/world-restart-layout.json"))
	for candidate in layout.routes:
		if candidate.name!="home_to_junction": continue
		for p in candidate.points: main_route.append((Vector2(p[0],p[1])-Vector2(1110,1172))/24.+Vector2(-4.7,-4.8))
	route.append(main_route[0])
	for i in range(1,main_route.size()-1):
		var corner := main_route[i]
		var incoming := corner-main_route[i-1]
		var outgoing := main_route[i+1]-corner
		var radius := minf(1.1,minf(incoming.length(),outgoing.length())*.22)
		var a := corner-incoming.normalized()*radius
		var b := corner+outgoing.normalized()*radius
		route.append(a)
		for step in range(1,4):
			var t := float(step)/3.
			route.append(a*(1.-t)*(1.-t)+corner*2.*t*(1.-t)+b*t*t)
	route.append(main_route[-1])

func route_distance(at: Vector2) -> float:
	var result := 1000.
	for i in range(route.size()-1):
		var a := route[i]
		var v := route[i+1]-a
		var t := clampf((at-a).dot(v)/maxf(v.length_squared(),.001),0.,1.)
		result = minf(result,at.distance_to(a+v*t))
	return result

func height_at(x: float,z: float,enabled: bool) -> float:
	if not enabled: return 0.
	var floor_height := super.height_at(x,z,true)
	var road_height := .12+.13*sin((z+4.8)*.12)
	var d := route_distance(Vector2(x,z))
	return lerpf(road_height,floor_height,smoothstep(.85,3.2,d))

func terrain(enabled: bool) -> ArrayMesh:
	var c: Array[float] = [-90.,-50.,-40.]
	for i in 145: c.append(-36.+float(i)*.5)
	c.append_array([40.,50.,90.])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var heights := PackedFloat32Array()
	var width := c.size()
	for z in width:
		for x in width: heights.append(height_at(c[x],c[z],enabled))
	for z in width:
		for x in width:
			var left := maxi(0,x-1)
			var right := mini(width-1,x+1)
			var front := maxi(0,z-1)
			var back := mini(width-1,z+1)
			var dx := (heights[z*width+right]-heights[z*width+left])/(c[right]-c[left])
			var dz := (heights[back*width+x]-heights[front*width+x])/(c[back]-c[front])
			st.set_normal(Vector3(-dx,1,-dz).normalized())
			st.set_uv(Vector2(c[x],c[z])/6.)
			st.add_vertex(Vector3(c[x],heights[z*width+x],c[z]))
	for z in range(width-1):
		for x in range(width-1):
			var a := z*width+x
			for index in [a,a+1,a+width+1,a,a+width+1,a+width]: st.add_index(index)
	return st.commit()
