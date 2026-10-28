extends Node3D
var world: Node3D
var flower_count79 := 0
var ridge_material79: ShaderMaterial
var last_hour79 := -1.

func _ready() -> void:
	name="GroundCoverAndDistantRidge79"
	var decor: Node3D=world.atmosphere41.decor
	var rng := RandomNumberGenerator.new();rng.seed=790043
	for variant in 4:
		var poses: Array[Transform3D]=[]
		for patch in world.meadow.ground_patches79:
			if patch.kind!=2: continue
			var area: Vector4=patch.area
			for i in 16:
				var at := Vector2(area.x,area.y)+Vector2(rng.randf_range(-1.,1.)*area.z,rng.randf_range(-1.,1.)*area.w)*.85
				if world.meadow.is_water(at) or world.meadow.route_distance(at)<1.1 or world.meadow.ground_cover79(at).y<.18: continue
				var height := rng.randf_range(.27,.47)
				var basis := Basis(Vector3.RIGHT,deg_to_rad(-25.)).scaled(Vector3.ONE*height)
				poses.append(Transform3D(basis,Vector3(at.x,world.floor_height(at)-.012,at.y)))
		var batch := MultiMeshInstance3D.new();batch.name="FlowerMeadow79_%d"%variant
		batch.visibility_range_end=42.;batch.extra_cull_margin=.5
		batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D;multi.mesh=decor._mesh("flowers",variant)
		multi.instance_count=poses.size()
		for i in poses.size(): multi.set_instance_transform(i,poses[i])
		batch.multimesh=multi;batch.material_override=decor._material("flowers",variant)
		world.porch49.shade_material(batch.material_override)
		add_child(batch);decor.flower_batches.append(batch);flower_count79+=poses.size()
	build_ridge79()

func build_ridge79() -> void:
	# A low-contrast silhouette behind the far forest, not a traversable mountain
	# or a rock card pasted on the foreground terrace.
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var line := PackedVector3Array()
	for i in 25:
		var x := 28.+i*4.6
		var height := (5.+7.*exp(-pow((x-63.)/17.,2.))+5.*exp(-pow((x-107.)/14.,2.))+.65*sin(x*.27))*sin(PI*i/24.)
		line.append(Vector3(x,height,-100.-.7*sin(x*.08)))
	for i in range(1,line.size()):
		var a := line[i-1];var b := line[i]
		for p in [Vector3(a.x,-1.,a.z),a,b,Vector3(a.x,-1.,a.z),b,Vector3(b.x,-1.,b.z)]:
			st.set_normal(Vector3(0,0,1));st.add_vertex(p)
	var ridge := MeshInstance3D.new();ridge.name="QuietFarMountainSilhouette79";ridge.mesh=st.commit()
	ridge.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ridge_material79=ShaderMaterial.new();ridge_material79.shader=preload("res://scripts/art/distant_ridge79.gdshader")
	ridge.material_override=ridge_material79;add_child(ridge)

func _process(_delta: float) -> void:
	if not is_instance_valid(world.time55): return
	var hour: float=world.time55.visual_hour
	if absf(hour-last_hour79)<.02: return
	last_hour79=hour
	ridge_material79.set_shader_parameter("night79",1.-smoothstep(5.,7.,hour) if hour<12. else smoothstep(18.5,21.,hour))
