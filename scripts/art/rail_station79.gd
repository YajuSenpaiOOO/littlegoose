extends "res://scripts/art/rail_station75.gd"
var front_steps79: MeshInstance3D
var side_steps79: MeshInstance3D
var front_count79 := 0
var side_count79 := 0

func material79() -> ShaderMaterial:
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/stair_stone79.gdshader")
	material.set_shader_parameter("face_paint79",preload("res://assets/wall77/painted_moss_stone77.png"))
	material.set_shader_parameter("top_paint79",preload("res://assets/garden45/slate.png"))
	world.porch49.shade_material(material);return material

func finish79(st: SurfaceTool,label: String) -> MeshInstance3D:
	var node := MeshInstance3D.new();node.name=label;node.mesh=st.commit();node.material_override=material79();add_child(node);return node

func triangle79(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3) -> void:
	st.set_normal((b-a).cross(c-a).normalized())
	for p in [a,b,c]: st.add_vertex(p)

func bevel79(st: SurfaceTool,at: Vector3,size: Vector3) -> void:
	var half := Vector2(size.x,size.z)*.5
	var bevel := minf(.05,minf(half.x,half.y)*.2)
	var outline := PackedVector2Array([Vector2(-half.x+bevel,-half.y),Vector2(half.x-bevel,-half.y),Vector2(half.x,-half.y+bevel),Vector2(half.x,half.y-bevel),Vector2(half.x-bevel,half.y),Vector2(-half.x+bevel,half.y),Vector2(-half.x,half.y-bevel),Vector2(-half.x,-half.y+bevel)])
	var rings: Array[PackedVector3Array]=[]
	for layer in 3:
		var ring := PackedVector3Array()
		for p in outline:
			var inset := p
			if layer==2: inset=p-p.normalized()*bevel
			var y := -size.y*.5 if layer==0 else size.y*.5-(bevel if layer==1 else 0.)
			ring.append(at+Vector3(inset.x,y,inset.y))
		rings.append(ring)
	for layer in 2:
		for i in 8:
			var j := (i+1)%8
			triangle79(st,rings[layer][i],rings[layer+1][i],rings[layer+1][j])
			triangle79(st,rings[layer][i],rings[layer+1][j],rings[layer][j])
	for i in 8: triangle79(st,at+Vector3.UP*size.y*.5,rings[2][(i+1)%8],rings[2][i])

func _build_station73() -> void:
	super._build_station73()
	get_node("StationFrontSteps74").hide()
	var s: RefCounted=world.meadow
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in s.station_stair_count74():
		var at: Vector2=s.stair_start73()-Vector2(0,(i+.5)*s.station_stair_run74()/s.station_stair_count74())
		for j in 3:
			bevel79(st,Vector3(at.x+(j-1)*1.5,world.floor_height(at)-.045,at.y),Vector3(1.485,.19,s.station_stair_run74()/s.station_stair_count74()+.018))
		for side in [-1.,1.]:
			var h: float=world.floor_height(at)-s.MAIN72+.14
			bevel79(st,Vector3(at.x+side*2.6,s.MAIN72+h*.5,at.y),Vector3(.65,h,s.station_stair_run74()/s.station_stair_count74()+.018))
		front_count79+=1
	front_steps79=finish79(st,"PaintedFrontStoneSteps79")

func _build_side_steps75() -> void:
	var s: RefCounted=world.meadow
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 48:
		var x := lerpf(-8.,21.,(i+.5)/48.)
		if x>3.1 and x<6.5: continue
		var weight := smoothstep(-8.,-4.,x)*(1.-smoothstep(15.,21.,x))
		if weight<.01: continue
		var h: float=(s.MAIN72-s.LOW72)*weight+.035
		bevel79(st,Vector3(x,s.LOW72+h*.5,s.regional_front75(x)-.04),Vector3(29./48.+.012,h,.57))
	for i in 9:
		var at: Vector2=s.SIDE_FOOT75+Vector2(-(i+.5)*5.2/9.,0.)
		for side in [-.575,.575]:
			bevel79(st,Vector3(at.x,world.floor_height(at)-.045,at.y+side),Vector3(5.2/9.+.018,.2,1.135))
		var h: float=world.floor_height(at)-s.LOW72+.12
		bevel79(st,Vector3(at.x,s.LOW72+h*.5,at.y+1.35),Vector3(5.2/9.+.018,h,.4))
		side_count79+=1
	side_stairs75=finish79(st,"PaintedRetainingWallAndSideSteps79");side_steps79=side_stairs75
