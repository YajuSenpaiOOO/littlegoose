extends Node3D
const CAPACITY := 32
var world: Node3D
var strength := 0.
var fireflies_enabled := true
var stage_enabled := true
var fireflies: MultiMeshInstance3D
var stage_beam: MeshInstance3D
var stage_light: SpotLight3D
var firefly_emitter: Node
var stage_emitter: Node
var rng := RandomNumberGenerator.new()
var flies: Array[Dictionary] = []
var elapsed := 0.

func emitter(settings: Resource,light: Light3D,material: ShaderMaterial,parameter: StringName) -> Node:
	var item: Node=preload("res://scripts/art/warm_emitter57.gd").new()
	add_child(item)
	item.bind(settings,light,material,parameter)
	return item

func _ready() -> void:
	rng.seed=570018
	fireflies=MultiMeshInstance3D.new()
	fireflies.name="Fireflies32_CoreOnly_NoLights"
	fireflies.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fireflies.extra_cull_margin=1.
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/firefly57.gdshader")
	fireflies.material_override=material
	var multi := MultiMesh.new()
	multi.transform_format=MultiMesh.TRANSFORM_3D
	multi.use_custom_data=true
	var quad := QuadMesh.new()
	quad.size=Vector2.ONE
	multi.mesh=quad
	multi.instance_count=CAPACITY
	fireflies.multimesh=multi
	add_child(fireflies)
	firefly_emitter=emitter(preload("res://assets/lighting55/firefly57.tres"),null,material,&"strength57")
	for i in CAPACITY:
		flies.append({})
		spawn(i)
	stage_light=SpotLight3D.new()
	stage_light.name="TheatreHeroSpot_OneLight_NoShadow"
	stage_light.position=Vector3(-.65,6.,.25)
	stage_light.spot_angle=21.
	stage_light.spot_attenuation=1.7
	stage_light.light_energy=0.
	stage_light.shadow_enabled=false
	add_child(stage_light)
	stage_beam=MeshInstance3D.new()
	stage_beam.name="SoftStageAir_OneQuad"
	stage_beam.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for uv in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(1,0)]:
		st.set_uv(uv)
		st.add_vertex(Vector3(-.65,6.,.25).lerp(Vector3(0,.05,0),uv.y)+Vector3.RIGHT*(uv.x-.5)*lerpf(.35,4.,uv.y))
	stage_beam.mesh=st.commit()
	var beam_material := ShaderMaterial.new()
	beam_material.shader=preload("res://scripts/art/stage_beam57.gdshader")
	stage_beam.material_override=beam_material
	add_child(stage_beam)
	stage_emitter=emitter(preload("res://assets/lighting55/stage57.tres"),stage_light,beam_material,&"strength57")
	set_strength(0.)
	update_accents(0.)

func spawn(index: int) -> void:
	var hero: Vector3=world.hero.global_position
	var at := Vector2(hero.x,hero.z)
	for attempt in 8:
		var angle := rng.randf()*TAU
		at=Vector2(hero.x,hero.z)+Vector2(cos(angle),sin(angle))*rng.randf_range(3.,13.)
		if not world.meadow.is_water(at) and world.meadow.route_distance(at)>1.: break
	flies[index]={"at":Vector3(at.x,world.floor_height(at)+rng.randf_range(.45,1.65),at.y),"phase":rng.randf()*TAU,"size":rng.randf_range(.32,.54),"rate":rng.randf_range(.4,.8)}

func set_strength(value: float) -> void:
	strength=clampf(value,0.,1.)
	firefly_emitter.set_level(0.,strength,fireflies_enabled)
	stage_emitter.set_level(strength,strength,stage_enabled)
	fireflies.visible=fireflies_enabled and strength>.001
	stage_beam.visible=stage_enabled and strength>.001
	stage_light.visible=stage_enabled and strength>.001
	world.atmosphere41.focus_material.set_shader_parameter("actor_stage57",strength if stage_enabled else 0.)

func update_accents(delta: float) -> void:
	elapsed+=delta
	global_position=world.hero.global_position
	stage_light.look_at(global_position+Vector3.UP*.35,Vector3.UP)
	if stage_enabled and strength>.001:
		var camera: Camera3D=world.camera
		var at: Vector3=global_position+Vector3.UP*.85
		var viewport_size: Vector2=world.get_viewport().get_visible_rect().size
		var center := camera.unproject_position(at)/viewport_size
		var horizontal := camera.unproject_position(at+Vector3.RIGHT*.85)/viewport_size
		var vertical := camera.unproject_position(at+Vector3.UP*1.2)/viewport_size
		var focus: ShaderMaterial=world.atmosphere41.focus_material
		focus.set_shader_parameter("stage_center57",center)
		focus.set_shader_parameter("stage_radius57",Vector2(maxf(.005,absf(horizontal.x-center.x)),maxf(.005,absf(vertical.y-center.y))))
		focus.set_shader_parameter("stage_depth57",-camera.to_local(at).z)
	if not fireflies.visible: return
	var to_local := global_transform.affine_inverse()
	for i in flies.size():
		var fly: Dictionary=flies[i]
		var distance: float=fly.at.distance_to(world.hero.global_position)
		if distance>20.:
			spawn(i)
			fly=flies[i]
			distance=fly.at.distance_to(world.hero.global_position)
		var phase: float=elapsed*fly.rate+fly.phase
		var position: Vector3=fly.at+Vector3(sin(phase*.6)*.45,sin(phase*.9)*.16,cos(phase*.5)*.35)
		var pulse: float=.12+.88*pow(.5+.5*sin(phase),2.)
		var alpha: float=pulse*(1.-smoothstep(14.,19.,distance))
		# Batch is in world space while the stage root follows the actor.
		var transform := Transform3D(world.camera.global_basis.scaled(Vector3.ONE*fly.size),position)
		fireflies.multimesh.set_instance_transform(i,to_local*transform)
		fireflies.multimesh.set_instance_custom_data(i,Color(1.,.9,.4,alpha))

func _process(delta: float) -> void:
	update_accents(delta)
