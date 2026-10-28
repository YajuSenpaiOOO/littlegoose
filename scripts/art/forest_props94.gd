extends "res://scripts/art/forest_props93.gd"
var reactive94 := true
var plants94: Array[Dictionary]=[]
var flower_batches94: Array[MultiMeshInstance3D]=[]
var flower_points94: Array[Vector2]=[]
var colonies94: Array[int]=[]

func _flower_specs94() -> Array:
	return [Vector4(-4.7,-4.8,3.8,2.1),Vector4(4.3,-9.7,3.2,1.5),Vector4(-13.5,4.,2.9,1.6),Vector4(9.,8.,2.8,1.8)]
func _flower_attempts94() -> int: return 100
func _flower_height94(rng: RandomNumberGenerator) -> float: return rng.randf_range(.38,.66)
func _flower_gap94(local: Vector2) -> bool: return sin(local.x*2.1+local.y*1.5)>.83
func _flower_variant94(spec: Vector4,rng: RandomNumberGenerator) -> int:
	return 0 if rng.randf()<.66 else (1 if spec.x<6. else 2)
func _plant_active94(_visual: Sprite3D) -> bool: return true

func _plant_material94(texture: Texture2D) -> ShaderMaterial:
	var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/woodland_plant94.gdshader")
	material.set_shader_parameter("paint",texture);world.porch49.shade_material(material)
	return material

func _flower_mesh94(texture: Texture2D,profile: Dictionary) -> ArrayMesh:
	var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for uv in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
		st.set_uv(uv);st.set_normal(Vector3(0,.85,.53).normalized())
		st.add_vertex(Vector3((uv.x*texture.get_width()-profile.foot[0])/profile.height,(profile.foot[1]-uv.y*texture.get_height())/profile.height,0))
	return st.commit()

func _flower_support94(at: Vector2) -> bool:
	if world.meadow.route_distance(at)<1.25 or world.meadow.is_water(at) or world.meadow.normal_at(at.x,at.y,true).y<.965: return false
	for rock in rocks87:
		if absf(at.x-rock.at.x)<rock.width*.46+.2 and absf(at.y-rock.at.y)<rock.width*.24+.2: return false
	for tree in world.trees:
		if Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)<.95: return false
	return true

func _build_flowers94() -> void:
	var source: Image=preload("res://assets/vegetation43/flower_stems.png").get_image()
	if source.is_compressed(): source.decompress()
	var profiles: Array=JSON.parse_string(FileAccess.get_file_as_string("res://assets/vegetation43/profiles.json"))
	var rng := RandomNumberGenerator.new();rng.seed=940094
	var points: Array[Array]=[[],[],[],[]]
	var g: Vector2=world.meadow.landmarks.grove
	# Separate stem instances; the ground and existing grass remain separate.
	# Main drifts echo the tree fingers, with a smaller warm patch by the entry.
	for spec in _flower_specs94():
		var count := 0
		for i in _flower_attempts94():
			var angle := rng.randf()*TAU
			var radius := sqrt(rng.randf())
			var local := Vector2(cos(angle)*spec.z,sin(angle)*spec.w)*radius
			var at := g+Vector2(spec.x,spec.y)+local
			if not _flower_support94(at): continue
			# Feather the edge, leave small bare pockets rather than a solid disk.
			if rng.randf()>lerpf(.88,.22,smoothstep(.45,1.,radius)): continue
			if _flower_gap94(local): continue
			var variant := _flower_variant94(spec,rng)
			points[variant].append({"at":at,"height":_flower_height94(rng)})
			flower_points94.append(at);count+=1
		colonies94.append(count)
	for variant in 4:
		if points[variant].is_empty(): continue
		var p: Dictionary=profiles[variant];var cell: Array=p.cell
		var tile := source.get_region(Rect2i(cell[0],cell[1],cell[2],cell[3]));tile.generate_mipmaps()
		var texture := ImageTexture.create_from_image(tile)
		var batch := MultiMeshInstance3D.new();batch.name="IndependentFlowerStems94_%d"%variant
		batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;batch.extra_cull_margin=.4
		var material := _plant_material94(texture)
		material.set_shader_parameter("field94",true);material.set_shader_parameter("tint",Vector3(.97,.98,.94))
		batch.material_override=material
		var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D;multi.mesh=_flower_mesh94(texture,p)
		multi.instance_count=points[variant].size()
		for i in points[variant].size():
			var point: Dictionary=points[variant][i];var at: Vector2=point.at;var h: float=point.height
			var basis := Basis(Vector3.RIGHT,deg_to_rad(-25.)).scaled(Vector3(h*(1. if i%3 else -1.),h,h))
			multi.set_instance_transform(i,Transform3D(basis,Vector3(at.x,world.floor_height(at)-.018,at.y)))
		batch.multimesh=multi;add_child(batch);flower_batches94.append(batch)

func _ready() -> void:
	super._ready()
	for plant in plants87:
		plant.material_override=_plant_material94(plant.texture);plant.extra_cull_margin=.45
		plants94.append({"visual":plant,"push":Vector3.ZERO,"radius":clampf(plant.texture.get_width()*plant.pixel_size*.42+.35,.85,1.45)})
	_build_flowers94()
	print("FLOWERS94 stems=",flower_points94.size()," colonies=",colonies94," reactive_plants=",plants94.size())

func set_reactive94(value: bool) -> void:
	reactive94=value
	for plant in plants94: plant.visual.material_override.set_shader_parameter("reactive94",value)
	for batch in flower_batches94: batch.material_override.set_shader_parameter("reactive94",value)

func _process(delta: float) -> void:
	super._process(delta)
	if not enabled87 or not is_instance_valid(world.hero): return
	var walker: Vector3=world.hero.get_global_transform_interpolated().origin
	for plant in plants94:
		var visual: Sprite3D=plant.visual
		if not _plant_active94(visual):
			if Vector3(plant.push).length_squared()>.000001:
				plant.push=Vector3.ZERO;visual.material_override.set_shader_parameter("push94",Vector3.ZERO)
			continue
		var away := Vector2(visual.position.x-walker.x,visual.position.z-walker.z)
		var touch: float=(1.-smoothstep(.12,plant.radius,away.length()))*(1.-smoothstep(.55,1.15,absf(visual.position.y-walker.y)))
		var target := Vector3(away.normalized().x,-.25,away.normalized().y)*touch*.25
		plant.push=Vector3(plant.push).lerp(target,1.-exp(-delta*(12. if touch>.01 else 5.)))
		visual.material_override.set_shader_parameter("push94",plant.push)
		visual.material_override.set_shader_parameter("clock",world.clock)
	for batch in flower_batches94:
		batch.material_override.set_shader_parameter("walker",walker)
		batch.material_override.set_shader_parameter("clock",world.clock)
		batch.material_override.set_shader_parameter("trail",world.trail)
