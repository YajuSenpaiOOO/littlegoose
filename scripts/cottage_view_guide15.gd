extends "res://scripts/forest_styles14.gd"
## Temporary engine-rendered perspective reference, not production art.
func _ready() -> void:
	super._ready()
	house_art.hide()
	var surface := StandardMaterial3D.new()
	surface.albedo_color = Color("d6c7a7")
	surface.roughness = 1.
	var wall := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(6.3,2.9,3.8)
	wall.mesh = box
	wall.position = Vector3(0,1.45,-1.9)
	wall.material_override = surface
	cottage_root.add_child(wall)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var a := Vector3(-3.5,2.9,.15)
	var b := Vector3(0,4.9,.15)
	var c := Vector3(3.5,2.9,.15)
	var back := Vector3(0,0,-4.1)
	for triangle in [[a,b,c],[a+back,c+back,b+back],[a,a+back,b],[b,a+back,b+back],[b,b+back,c],[c,b+back,c+back]]:
		st.set_normal((triangle[2]-triangle[0]).cross(triangle[1]-triangle[0]).normalized())
		for point in triangle: st.add_vertex(point)
	var roof := MeshInstance3D.new()
	roof.mesh = st.commit()
	roof.material_override = _material(Color("a9543b"))
	cottage_root.add_child(roof)
	var front := SurfaceTool.new()
	front.begin(Mesh.PRIMITIVE_TRIANGLES)
	for point in [a,b,c]:
		front.set_normal(Vector3.BACK)
		front.add_vertex(point+Vector3(0,0,.012))
	var gable := MeshInstance3D.new()
	gable.mesh = front.commit()
	gable.material_override = surface
	cottage_root.add_child(gable)
	var door := _box(cottage_root.position+Vector3(0,1.0,.03),Vector3(1.05,2.,.08),Color("75523a"),false)
	door.name = "GuideDoor"
	for x in [-1.9,1.9]: _box(cottage_root.position+Vector3(x,1.55,.04),Vector3(.95,.95,.09),Color("e5c476"),false)
	if "--guide-close" in OS.get_cmdline_user_args():
		hero.position = Vector3(-4.7,.2,-2.6)
		hero.reset_physics_interpolation()
		_update_camera(0,true)
