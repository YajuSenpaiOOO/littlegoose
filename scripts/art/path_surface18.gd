extends "res://scripts/art/home_route15.gd"
var profile = preload("res://scripts/world/path_profile18.gd").new()
var mesh_cache: Dictionary = {}

func height_at(x: float,z: float,enabled: bool) -> float:
	var base: float = super.height_at(x,z,enabled)
	if not enabled: return base
	return base-profile.depression(route_distance(Vector2(x,z)),Vector2(x,z).distance_to(main_route[0]))

func contains_soil(at: Vector2) -> bool:
	return route_distance(at)<.65

func terrain(enabled: bool) -> ArrayMesh:
	var signature := "%s/%s/%.4f"%[enabled,profile.enabled,profile.depth]
	if mesh_cache.has(signature): return mesh_cache[signature]
	# Quarter-metre triangles resolve the shallow shoulder without a vertical step.
	var c: Array[float] = [-90.,-50.,-40.]
	for i in 289: c.append(-36.+float(i)*.25)
	c.append_array([40.,50.,90.])
	var width := c.size()
	var heights := PackedFloat32Array()
	for z in width:
		for x in width: heights.append(height_at(c[x],c[z],enabled))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
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
	var mesh := st.commit()
	mesh_cache[signature] = mesh
	return mesh
