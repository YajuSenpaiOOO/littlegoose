extends "res://scripts/art/station_kit82.gd"
var layout83: Node3D
var beds83: Array[Node3D]=[]
var fences83: Array[Node3D]=[]
var layout_path83 := "res://scenes/world/station_layout83.tscn"

func anchor83(label: String) -> Vector3:
	return layout83.get_node(label).position

func move83(node: Node3D,label: String) -> void:
	node.position=anchor83(label)

func bed83(label: String) -> void:
	var root := module81(label,anchor83(label));beds83.append(root)
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# A shallow open bed with low painted stone kerbs, not a solid stone block.
	for x in [-.65,.65]: world.rail72.bevel79(st,Vector3(x,.16,0),Vector3(.20,.32,5.4))
	for z in [-2.6,2.6]: world.rail72.bevel79(st,Vector3(0,.16,z),Vector3(1.3,.32,.20))
	var stone := MeshInstance3D.new();stone.mesh=st.commit();stone.material_override=world.rail72.material79();root.add_child(stone)
	var soil := MeshInstance3D.new();var surface := PlaneMesh.new();surface.size=Vector2(1.08,5.0)
	soil.mesh=surface;soil.position.y=.10
	var moss := StandardMaterial3D.new();moss.albedo_color=Color("536042");moss.roughness=1.;soil.material_override=moss;root.add_child(soil)
	body81(root,"BedCollision83",Vector3(0,.2,0),Vector3(1.5,.4,5.4))
	var decor: Node3D=world.atmosphere41.decor
	var rng := RandomNumberGenerator.new();rng.seed=8301 if label.begins_with("West") else 8302
	for variant in 4:
		var batch := MultiMeshInstance3D.new();batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D;multi.mesh=decor._mesh("flowers",variant);multi.instance_count=10
		for i in 10:
			var basis := Basis(Vector3.RIGHT,deg_to_rad(-25.)).scaled(Vector3.ONE*rng.randf_range(.38,.58))
			multi.set_instance_transform(i,Transform3D(basis,Vector3(rng.randf_range(-.42,.42),.12,rng.randf_range(-2.35,2.35))))
		batch.multimesh=multi;batch.material_override=decor._material("flowers",variant);world.porch49.shade_material(batch.material_override);root.add_child(batch)
		decor.flower_batches.append(batch)
	contact82(root,Vector3(0,.012,0),Vector2(1.65,5.6),.17)

func fence83(label: String) -> void:
	var root := module81(label,anchor83(label));fences83.append(root)
	var wood := frame_material82(Vector4(220./1916.,448./821.,46./1916.,170./821.))
	for x in [-2.7,0.,2.7]:
		timber82(root,Vector3(x,.43,0),Vector3(.17,.86,.17),wood)
	for y in [.32,.67]: timber82(root,Vector3(0,y,0),Vector3(5.4,.12,.12),wood)
	body81(root,"FenceCollision83",Vector3(0,.4,0),Vector3(5.6,.8,.22))
	contact82(root,Vector3(0,.012,0),Vector2(5.7,.6),.15)

func _ready() -> void:
	super._ready()
	layout83=load(layout_path83).instantiate();add_child(layout83)
	move83(hall81,"Hall");move83(dressing82[0],"Board");move83(dressing82[1],"Cart");move83(dressing82[2],"Crates")
	move83(dressing82[3],"WestFlowers");move83(dressing82[4],"EastFlowers")
	for prop in world.props15:
		if prop.id=="bench" and prop.root.position.distance_to(global_position)<25.:
			prop.root.position=global_position+anchor83("WestBench" if prop.root.position.x<global_position.x else "EastBench")
	bed83("WestBed");bed83("EastBed");fence83("WestFence");fence83("EastFence")
	print("STATION83_SETBACK_AND_QUIET_BORDER_READY")
