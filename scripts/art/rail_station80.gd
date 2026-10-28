extends "res://scripts/art/rail_station79.gd"
var front_steps80: MeshInstance3D
var side_steps80: MeshInstance3D
var profiles80: Array[PackedVector2Array]=[]

func quad80(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3,normal: Vector3) -> void:
	st.set_normal(normal)
	for vertex in [a,b,c,a,c,d]: st.add_vertex(vertex)

func flight80(foot: Vector2,direction: Vector2,run: float,width: float,count: int,bottom: float,label: String) -> MeshInstance3D:
	var profile := PackedVector2Array([Vector2(0,bottom)])
	for i in count:
		var mid: Vector2=foot+direction*(i+.5)*run/count
		var top: float=world.floor_height(mid)+.055
		profile.append(Vector2(float(i)*run/count,top))
		profile.append(Vector2(float(i+1)*run/count,top))
	profile.append(Vector2(run,bottom));profiles80.append(profile)
	var crosswise := Vector2(-direction.y,direction.x)
	var sides: Array[PackedVector3Array]=[]
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var indices := Geometry2D.triangulate_polygon(profile)
	for sign_value in [-1.,1.]:
		var ring := PackedVector3Array()
		for p in profile:
			var at: Vector2=foot+direction*p.x+crosswise*width*.5*sign_value
			ring.append(Vector3(at.x,p.y,at.y))
		sides.append(ring)
		for index in indices:
			st.set_normal(Vector3(crosswise.x*sign_value,0,crosswise.y*sign_value));st.add_vertex(ring[index])
	for i in profile.size():
		var j := (i+1)%profile.size();var edge := profile[j]-profile[i]
		var outward := Vector2(-edge.y,edge.x).normalized()
		var normal := Vector3(direction.x*outward.x,outward.y,direction.y*outward.x)
		quad80(st,sides[0][i],sides[0][j],sides[1][j],sides[1][i],normal)
	return finish79(st,label)

func _build_station73() -> void:
	super._build_station73();front_steps79.hide()
	var s: RefCounted=world.meadow
	front_steps80=flight80(s.stair_start73(),Vector2.UP,s.station_stair_run74(),4.5,7,s.MAIN72-.16,"ClosedFrontStoneFlight80")
	var arrays: Array=front_steps79.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
	var curb := SurfaceTool.new();curb.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0,vertices.size(),3):
		var center := (vertices[i]+vertices[i+1]+vertices[i+2])/3.
		if absf(center.x-s.landmarks.station.x)<2.25: continue
		for j in 3: curb.set_normal(normals[i+j]);curb.add_vertex(vertices[i+j])
	finish79(curb,"FrontOutsideStoneCurbs80")
	# Paving also follows the smooth ramp near its top; only its rendering is
	# cut away under this closed stair body. Physics stays on the same ramp.
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/station_brick80.gdshader")
	var foot: Vector2=s.stair_start73()
	material.set_shader_parameter("front_cut80",Vector4(foot.x-2.25,foot.y-s.station_stair_run74(),foot.x+2.25,foot.y))
	station_mesh73.material_override=material;world.porch49.shade_material(material)

func _build_side_steps75() -> void:
	super._build_side_steps75()
	var s: RefCounted=world.meadow
	# Keep the old outside curb and wall, replacing only thin tread pieces.
	var arrays: Array=side_steps79.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
	var wall := SurfaceTool.new();wall.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0,vertices.size(),3):
		var center := (vertices[i]+vertices[i+1]+vertices[i+2])/3.
		if center.z>s.SIDE_FOOT75.y-1.16 and center.z<s.SIDE_FOOT75.y+1.16: continue
		for j in 3: wall.set_normal(normals[i+j]);wall.add_vertex(vertices[i+j])
	side_steps79.hide();finish79(wall,"RetainingWallAndOutsideCurb80")
	side_steps80=flight80(s.SIDE_FOOT75,Vector2.LEFT,5.2,2.3,9,s.LOW72-.16,"ClosedSideStoneFlight80")
