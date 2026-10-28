extends Node3D
const LABELS := ["树林遮挡","打开视野","开口＋远景层次"]
var world: Node3D
var mode := 2
var backdrop: Node3D
var gap_trees: Array[Dictionary] = []
var hidden_ids: Dictionary = {}
var ridge_count := 0
var forest_batches := 0

func _ready() -> void:
	name="LookoutLayers53"
	for tree in world.trees:
		var p: Vector3=tree.root.position
		if p.z> -6.5 or p.z< -72.: continue
		var depth := -p.z-6.5
		var center := -13.-depth*.10
		var width := minf(8.,3.5+depth*.13)
		if absf(p.x-center)<width and p.x< -7.:
			gap_trees.append(tree)
			hidden_ids[tree.visual.get_instance_id()]=true
	backdrop=Node3D.new()
	backdrop.name="DistantRidgesAndForest_NoCollision"
	add_child(backdrop)
	_build_ridges()
	_build_forests()
	set_mode(2)
	print("LOOKOUT53_READY gap_trees=",gap_trees.size()," ridge_layers=",ridge_count," forest_batches=",forest_batches)

func _ridge(z: float,height: float,width: float,color: Color,phase: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := 80
	for i in n:
		var x0 := -22.-width*.5+width*float(i)/n
		var x1 := -22.-width*.5+width*float(i+1)/n
		var y0 := height+sin(x0*.07+phase)*2.+sin(x0*.13+phase*.7)*.8
		var y1 := height+sin(x1*.07+phase)*2.+sin(x1*.13+phase*.7)*.8
		for p in [Vector3(x0,-12.,z),Vector3(x0,y0,z),Vector3(x1,y1,z),Vector3(x0,-12.,z),Vector3(x1,y1,z),Vector3(x1,-12.,z)]: st.add_vertex(p)
	var ridge := MeshInstance3D.new()
	ridge.mesh=st.commit()
	ridge.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	material.disable_fog=true
	material.cull_mode=BaseMaterial3D.CULL_DISABLED
	material.albedo_color=color
	ridge.material_override=material
	backdrop.add_child(ridge)
	ridge_count+=1

func _build_ridges() -> void:
	_ridge(-105.,.1,170.,Color("a1b7b0"),2.4)
	_ridge(-82.,1.2,140.,Color("819f92"),.4)
	_ridge(-59.,1.5,110.,Color("617f6b"),3.2)

func _tree_mesh(texture: Texture2D) -> ArrayMesh:
	var image := texture.get_image()
	if image.is_compressed(): image.decompress()
	var used := image.get_used_rect()
	var foot := Vector2(used.get_center().x,used.end.y)
	var scale := 1./float(used.size.y)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for uv in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
		st.set_uv(uv)
		st.add_vertex(Vector3((uv.x*image.get_width()-foot.x)*scale,(foot.y-uv.y*image.get_height())*scale,0.))
	return st.commit()

func _build_forests() -> void:
	var texture: Texture2D=world.trees[0].visual.texture
	var mesh := _tree_mesh(texture)
	var specs := [
		{"z":-84.,"y":-2.,"width":90.,"height":3.4,"count":30,"color":Color("92aba0")},
		{"z":-59.,"y":-.2,"width":67.,"height":3.7,"count":26,"color":Color("708e79")},
		{"z":-38.,"y":0.,"width":37.,"height":3.8,"count":18,"color":Color("45664b")}
	]
	var rng := RandomNumberGenerator.new()
	rng.seed=530018
	for spec in specs:
		var batch := MultiMeshInstance3D.new()
		batch.name="DistantForestLayer%d"%forest_batches
		batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material := ShaderMaterial.new()
		material.shader=preload("res://scripts/art/distant_forest53.gdshader")
		material.set_shader_parameter("paint",texture)
		batch.material_override=material
		var multi := MultiMesh.new()
		multi.transform_format=MultiMesh.TRANSFORM_3D
		multi.use_colors=true
		multi.mesh=mesh
		multi.instance_count=spec.count
		for i in spec.count:
			var x: float=-19.-spec.width*.5+spec.width*float(i)/maxf(1.,spec.count-1)
			var height: float=spec.height*rng.randf_range(.85,1.2)
			var at := Vector3(x,spec.y+sin(x*.16)*.4,spec.z+rng.randf_range(-2.,2.))
			multi.set_instance_transform(i,Transform3D(Basis(Vector3.RIGHT,deg_to_rad(-25.)).scaled(Vector3.ONE*height),at))
			multi.set_instance_color(i,spec.color)
		batch.multimesh=multi
		backdrop.add_child(batch)
		forest_batches+=1

func set_mode(value: int) -> void:
	mode=clampi(value,0,2)
	backdrop.visible=mode==2
	for tree in gap_trees:
		tree.root.visible=mode==0
		for child in tree.root.get_children():
			if child is StaticBody3D: child.collision_layer=2 if mode==0 else 0
	for piece in world.root_pieces:
		if hidden_ids.has(piece.sprite.get_instance_id()): piece.node.visible=mode==0
	world._title35()
