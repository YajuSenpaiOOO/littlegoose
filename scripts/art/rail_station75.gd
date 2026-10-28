extends "res://scripts/art/rail_station74.gd"
var side_stairs75: MeshInstance3D

func _ready() -> void:
	name="StationDepthAndSideSteps75"
	var surface: RefCounted=world.meadow
	var y: float=surface.rail_level73()
	var z: float=surface.rail_z73
	rail_span73=surface.rail_alignment73
	sleeper_count72=ceili((rail_span73.y-rail_span73.x)/1.2)
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-.85,.85]: box72(st,Vector3((rail_span73.x+rail_span73.y)*.5,y+.18,z+side),Vector3(rail_span73.y-rail_span73.x,.14,.09))
	for i in sleeper_count72:
		var sx: float=minf(rail_span73.x+(i+.5)*1.2,rail_span73.y-.1)
		box72(st,Vector3(sx,y+.055,z),Vector3(.18,.10,3.0))
	rail_mesh72=solid72(st,Color(.25,.27,.26),"RailStopsAtWorldBounds75")
	var frame := SurfaceTool.new();frame.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-2.45,2.45]: box72(frame,Vector3(surface.portal_x73,y+1.65,z+side),Vector3(1.5,3.3,.65))
	box72(frame,Vector3(surface.portal_x73,y+3.45,z),Vector3(1.8,.4,5.55))
	portal72=solid72(frame,Color(.42,.43,.40),"TunnelPlaceholder75")
	var dark := SurfaceTool.new();dark.begin(Mesh.PRIMITIVE_TRIANGLES)
	box72(dark,Vector3(surface.portal_x73-.35,y+1.5,z),Vector3(.06,3.,4.25))
	solid72(dark,Color(.08,.10,.09),"TunnelDepth75")
	_build_station73()
	_build_side_steps75()

func _build_side_steps75() -> void:
	var s: RefCounted=world.meadow
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# The road wall has a top-landing notch; it does not encircle another pad.
	for i in 48:
		var x: float=lerpf(-8.,21.,float(i)/48.)
		var end_x: float=lerpf(-8.,21.,float(i+1)/48.)
		if x>3.1 and x<6.5: continue
		var weight := smoothstep(-8.,-4.,x)*(1.-smoothstep(15.,21.,x))
		for v in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
			var vx: float=lerpf(x,end_x,v.x)
			var vz: float=s.regional_front75(vx)+.22
			st.set_normal(Vector3(0,0,1));st.add_vertex(Vector3(vx,lerpf(s.LOW72-.03,s.LOW72+(s.MAIN72-s.LOW72)*weight+.035,v.y),vz))
	# BoxMesh appends indexed geometry. Index the hand-built wall first, or its
	# triangles become unreferenced when the stair boxes add an index buffer.
	st.index()
	for i in 9:
		var at: Vector2=s.SIDE_FOOT75+Vector2(-(i+.5)*5.2/9.,0.)
		box72(st,Vector3(at.x,world.floor_height(at)-.045,at.y),Vector3(5.2/9.+.02,.2,2.3))
		# A low outside curb gives the exposed stair edge thickness.
		var curb_h: float=world.floor_height(at)-s.LOW72+.12
		box72(st,Vector3(at.x,s.LOW72+curb_h*.5,at.y+1.35),Vector3(5.2/9.+.02,curb_h,.4))
	side_stairs75=MeshInstance3D.new();side_stairs75.name="MossRetainingWallAndSideSteps75";side_stairs75.mesh=st.commit()
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/moss_stone75.gdshader")
	side_stairs75.material_override=material;add_child(side_stairs75);world.porch49.shade_material(material)
