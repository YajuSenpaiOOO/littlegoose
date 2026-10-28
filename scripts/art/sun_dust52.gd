extends Node3D
const CAPACITY := 96
var world: Node3D
var enabled := true
var batch: MultiMeshInstance3D
var motes: Array[Dictionary] = []
var nearby: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var refresh_left := 0.
var visible_motes := 0
var size_multiplier := 1.
var opacity_multiplier := 1.
var drift_multiplier := 1.
var near_hero_fraction := 0.

func set_presence(size_gain: float,opacity_gain: float,drift_gain: float,near_fraction: float) -> void:
	size_multiplier=size_gain
	opacity_multiplier=opacity_gain
	drift_multiplier=drift_gain
	near_hero_fraction=near_fraction
	_refresh()
	for i in motes.size(): _spawn(i,true)
	update_motes(0.)

func _ready() -> void:
	name="SunlitDust52"
	rng.seed=520018
	batch=MultiMeshInstance3D.new()
	batch.name="DustPool96_NoLights"
	batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	batch.extra_cull_margin=2.
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/sun_dust52.gdshader")
	batch.material_override=material
	var multi := MultiMesh.new()
	multi.transform_format=MultiMesh.TRANSFORM_3D
	multi.use_custom_data=true
	var quad := QuadMesh.new()
	quad.size=Vector2.ONE
	multi.mesh=quad
	multi.instance_count=CAPACITY
	batch.multimesh=multi
	add_child(batch)
	_refresh()
	for i in CAPACITY:
		motes.append({})
		_spawn(i,true)
	update_motes(0.)

func _refresh() -> void:
	nearby.clear()
	var p: Vector3=world.hero.global_position
	var at := Vector2(p.x,p.z)
	for opening in world.porch49.woodland_data.openings:
		var center := Vector2(opening.at[0],opening.at[1])
		if center.distance_to(at)<18.:
			nearby.append({"at":center,"radius":Vector2(opening.radius[0],opening.radius[1])})
	if at.distance_to(Vector2(-4.7,-2.8))<13.:
		nearby.append({"at":Vector2(-3.8,-3.3),"radius":Vector2(3.5,2.6)})
	nearby.sort_custom(func(a: Dictionary,b: Dictionary)->bool: return a.at.distance_squared_to(at)<b.at.distance_squared_to(at))
	if nearby.size()>3: nearby.resize(3)

func _spawn(index: int,initial := false) -> void:
	var mote: Dictionary=motes[index]
	var at := Vector2(world.hero.position.x,world.hero.position.z)
	if rng.randf()<near_hero_fraction:
		var angle := rng.randf()*TAU
		at+=Vector2(cos(angle),sin(angle))*rng.randf_range(.8,3.8)
	elif not nearby.is_empty():
		var opening: Dictionary=nearby[rng.randi_range(0,nearby.size()-1)]
		var angle := rng.randf()*TAU
		at=opening.at+Vector2(cos(angle),sin(angle))*opening.radius*sqrt(rng.randf())
	else: at+=Vector2(rng.randf_range(-6.,6.),rng.randf_range(-6.,6.))
	var lifetime := rng.randf_range(14.,25.)
	mote.at=Vector3(at.x,world.floor_height(at)+rng.randf_range(.35,2.7),at.y)
	mote.life=lifetime
	mote.age=rng.randf_range(0.,lifetime) if initial else 0.
	mote.phase=rng.randf()*TAU
	mote.size=rng.randf_range(.017,.037)*(1.45 if index%13==0 else 1.)*size_multiplier
	mote.opacity=minf(.78,rng.randf_range(.24,.48)*opacity_multiplier)
	mote.drift=Vector3(rng.randf_range(.015,.045),rng.randf_range(.003,.016),rng.randf_range(-.015,.025))*drift_multiplier

func set_enabled(value: bool) -> void:
	enabled=value
	batch.visible=value
	world._title35()

func update_motes(delta: float) -> void:
	visible_motes=0
	for i in motes.size():
		var mote: Dictionary=motes[i]
		mote.age+=delta
		if mote.age>mote.life or mote.at.distance_to(world.hero.position)>22.:
			_spawn(i)
		var t: float=mote.age
		var at: Vector3=mote.at+mote.drift*t+Vector3(sin(t*.45+mote.phase)*.15,sin(t*.55+mote.phase)*.12,cos(t*.35+mote.phase)*.10)
		var field: Color=world.porch49.sample_field(Vector2(at.x,at.z))
		var luma := (field.r*.2126+field.g*.7152+field.b*.0722)*1.25
		luma=lerpf(.95,luma,field.a)
		# The courtyard's separate canopy opening is not stored in the atlas.
		var home_p := Vector2(at.x+4.7,at.z+2.8)
		var home := 1.-smoothstep(10.,17.,home_p.length())
		var q := (home_p-Vector2(.9,-1.))/Vector2(3.7,3.1)
		var opening := exp(-q.length_squared())
		luma*=lerpf(1.,lerpf(.56,1.06,opening),home)
		var lit := smoothstep(.65,1.02,luma)
		var fade: float=smoothstep(0.,1.7,t)*(1.-smoothstep(mote.life-2.5,mote.life,t))
		var distance_fade := 1.-smoothstep(13.,20.,at.distance_to(world.hero.position))
		var alpha: float=mote.opacity*lit*fade*distance_fade
		if alpha>.015: visible_motes+=1
		batch.multimesh.set_instance_transform(i,Transform3D(world.camera.global_basis.scaled(Vector3.ONE*mote.size),at))
		batch.multimesh.set_instance_custom_data(i,Color(.98,.90,.73,alpha))

func _process(delta: float) -> void:
	if not enabled: return
	refresh_left-=delta
	if refresh_left<=0.: refresh_left=1.; _refresh()
	update_motes(delta)
