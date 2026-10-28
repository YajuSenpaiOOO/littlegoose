extends RefCounted
## Continuous landscape and texture-free grass silhouettes for the controlled lab.
var noise := FastNoiseLite.new()

func _init() -> void:
	noise.seed = 20261016
	noise.frequency = .09
	noise.fractal_octaves = 2

func height_at(x: float,z: float,enabled: bool) -> float:
	if not enabled: return 0.
	var road := .18*sin(z*.19)+z*.012
	var hill := 1.45*exp(-((x+6.)*(x+6.)+z*z)/32.)
	hill += 1.9*exp(-((x-7.)*(x-7.)+(z+8.)*(z+8.))/43.)
	hill -= .48*exp(-((x-6.)*(x-6.)+(z-7.)*(z-7.))/25.)
	hill += noise.get_noise_2d(x,z)*.16
	# The worn path follows a shallow longitudinal grade; shoulders rise gradually.
	var shoulder := smoothstep(.85,4.3,absf(x-sin(z*.25)*.9))
	var boundary := 1.-smoothstep(19.,24.,maxf(absf(x),absf(z)))
	return (road+hill*shoulder)*boundary

func normal_at(x: float,z: float,enabled: bool) -> Vector3:
	var dx := (height_at(x+.04,z,enabled)-height_at(x-.04,z,enabled))/.08
	var dz := (height_at(x,z+.04,enabled)-height_at(x,z-.04,enabled))/.08
	return Vector3(-dx,1,-dz).normalized()

func terrain(enabled: bool) -> ArrayMesh:
	var coordinates: Array[float] = [-90.,-40.,-24.]
	for i in 101: coordinates.append(-20.+float(i)*.4)
	coordinates.append_array([24.,40.,90.])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(coordinates.size()-1):
		for x in range(coordinates.size()-1):
			var corners := [Vector2(coordinates[x],coordinates[z]),Vector2(coordinates[x+1],coordinates[z]),Vector2(coordinates[x+1],coordinates[z+1]),Vector2(coordinates[x],coordinates[z+1])]
			for index in [0,1,2,0,2,3]:
				var at: Vector2 = corners[index]
				st.set_normal(normal_at(at.x,at.y,enabled))
				st.set_uv(at/6.)
				st.add_vertex(Vector3(at.x,height_at(at.x,at.y,enabled),at.y))
	return st.commit()

func blades(kind: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count := 7 if kind==1 else (5 if kind==2 else 4)
	for leaf in count:
		var angle := float(leaf)*2.39996
		var right := Vector3(cos(angle),0,sin(angle))
		var lean := Vector3(-sin(angle),0,cos(angle))
		var spread := .23 if kind==1 else .15
		var base := right*sin(float(leaf)*3.1)*spread+lean*cos(float(leaf)*2.3)*spread
		var height := .12+float(leaf%3)*.027
		var bend := .10
		if kind==2:
			height = .32+float(leaf%3)*.07
			bend = .22
		if kind==3:
			height = .19+float(leaf%3)*.035
			bend = .16
		var rows: Array[Vector3] = []
		for row in 6:
			var t := float(row)/5.
			var center := base+Vector3.UP*(height*t-.035)+lean*bend*t*t
			var width := .024*sin(PI*pow(t,.75))+.013*(1.-t)
			if kind==2: width *= .85
			if kind==3: width = .066*sin(PI*t)+.016*(1.-t)
			rows.append(center-right*width)
			rows.append(center+right*width)
		for section in 5:
			var indices := [section*2,section*2+1,section*2+3,section*2,section*2+3,section*2+2]
			if section==4: indices = [8,9,10]
			for index in indices:
				st.set_normal(Vector3.UP)
				st.set_uv(Vector2(float(index%2),float(index/2)/5.))
				st.add_vertex(rows[index])
	return st.commit()
