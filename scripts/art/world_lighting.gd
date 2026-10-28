extends Node2D
## One sky per canvas, plus an unshadowed native directional light.
## Ground projections use sample_shadow(), never native infinite directional shadows.
@export var profile: Resource
@export var auto_update_projections := true
@export var shadows_enabled := true
var projections: Array[Node2D] = []
var ambience: CanvasModulate
var sunlight: DirectionalLight2D
var current_sky := Color.WHITE
var current_color := Color.WHITE
var current_energy := 0.0
var current_azimuth := 0.0
var current_elevation := 45.0
var current_opacity := 0.0
var current_tint := Color("374461")
var current_ground_y := 0.65
var local_shadow_visibility := 1.0
var eave_visibility := 1.0
var transitions_paused := false
@export var cache_enabled := true
# Incremented only when the sampled natural shadow changes.
var shadow_revision := 0
var _shadow_state: Array = []
var _target_state: Array = []
var _transition_elapsed := 0.0
var _settled := false
var story_progress := -1.0
var story_profile: Resource
var sync_count := 0
# Discontinuous narrative time changes reposition shadows only while invisible.
var projection_epoch := 0
var _day_reset_pending: Resource
func _profile_state() -> Array:
	return [profile.sky_color,profile.direct_color,profile.direct_energy,profile.shadow_azimuth_degrees,profile.elevation_degrees,profile.shadow_opacity,profile.shadow_tint,profile.ground_y_scale,profile.local_shadow_visibility,profile.eave_visibility]

# Narrative time only changes when this is called. No wall-clock sun movement.
func set_act(act: int,total_acts: int,instant := false) -> void:
	set_story_progress(float(act-1)/float(maxi(total_acts,1)),instant)

func set_story_progress(value: float,instant := false) -> void:
	value = clampf(value,0,1)
	if story_progress==value and (profile==story_profile or _day_reset_pending==story_profile) and not instant: return
	var new_day := story_progress>=0 and value<story_progress
	_day_reset_pending = null
	story_progress = value
	# Story anchors: dawn -> noon -> sunset -> night. The final anchor is curtain call.
	var names := ["dawn","noon","sunset","night"]
	var stops := [0.0,0.3,0.7,1.0]
	var segment := 0
	while segment<2 and value>stops[segment+1]: segment += 1
	var a: Resource = load("res://assets/world_lighting_v1/"+names[segment]+".tres")
	var b: Resource = load("res://assets/world_lighting_v1/"+names[segment+1]+".tres")
	var weight: float = inverse_lerp(stops[segment],stops[segment+1],value)
	story_profile = a.duplicate()
	for field in ["direct_energy","elevation_degrees","shadow_opacity","ground_y_scale","local_shadow_visibility","eave_visibility"]:
		story_profile.set(field,lerpf(a.get(field),b.get(field),weight))
	for field in ["sky_color","direct_color","shadow_tint"]:
		story_profile.set(field,a.get(field).lerp(b.get(field),weight))
	# Keep the sunset direction while sunlight fades out, rather than sweeping at dusk.
	story_profile.shadow_azimuth_degrees = a.shadow_azimuth_degrees if segment==2 else rad_to_deg(lerp_angle(deg_to_rad(a.shadow_azimuth_degrees),deg_to_rad(b.shadow_azimuth_degrees),weight))
	if segment==2: story_profile.elevation_degrees = lerpf(a.elevation_degrees,5.0,weight)
	story_profile.nighttime = value>=0.85
	story_profile.label = "剧情时间 %d%%" % roundi(value*100)
	if new_day and not instant:
		var blackout: Resource = story_profile.duplicate()
		blackout.sky_color = current_sky
		blackout.direct_color = current_color
		blackout.direct_energy = 0.0
		blackout.shadow_opacity = 0.0
		blackout.shadow_azimuth_degrees = rad_to_deg(current_azimuth)
		blackout.elevation_degrees = current_elevation
		blackout.ground_y_scale = current_ground_y
		blackout.local_shadow_visibility = local_shadow_visibility
		blackout.eave_visibility = eave_visibility
		blackout.shadow_tint = current_tint
		set_profile(blackout)
		_day_reset_pending = story_profile
	else:
		set_profile(story_profile,instant)

func _ready() -> void:
	ambience = CanvasModulate.new()
	ambience.name = "SkyAmbient"
	add_child(ambience)
	sunlight = DirectionalLight2D.new()
	sunlight.name = "SunOrMoon"
	sunlight.shadow_enabled = false
	sunlight.range_layer_min = 0
	sunlight.range_layer_max = 0
	add_child(sunlight)
	if profile: set_profile(profile,true)

func set_profile(value: Resource,instant := false) -> void:
	if profile==value and not instant and _profile_state()==_target_state: return
	_day_reset_pending = null
	var changed := profile!=value
	profile = value
	_settled = false
	_transition_elapsed = 0.0
	_target_state = _profile_state()
	if instant or changed and not is_inside_tree():
		current_sky = profile.sky_color
		current_color = profile.direct_color
		current_energy = profile.direct_energy
		current_azimuth = deg_to_rad(profile.shadow_azimuth_degrees)
		current_elevation = profile.elevation_degrees
		current_opacity = profile.shadow_opacity
		current_tint = profile.shadow_tint
		current_ground_y = profile.ground_y_scale
		local_shadow_visibility = profile.local_shadow_visibility
		eave_visibility = profile.eave_visibility
		_settled = true
		_sync()

func _process(delta: float) -> void:
	advance(delta)
	for index in range(projections.size()-1,-1,-1):
		if not is_instance_valid(projections[index]): projections.remove_at(index)
		elif auto_update_projections: projections[index].update_shadow(delta,shadows_enabled)

func project_sprite(actor: Node2D,visual: Sprite2D,height: float,limit := 110.0) -> Node2D:
	if actor.get_meta("sample_character",false): preload("res://scripts/art/actor_foot_contact.gd").ensure(actor,visual)
	var projection := preload("res://scripts/art/natural_sprite_shadow.gd").new()
	projection.actor = actor
	projection.visual = visual
	projection.natural_light = self
	projection.body_height = height
	projection.max_length = limit
	add_child(projection)
	actor.tree_exiting.connect(projection.queue_free,CONNECT_ONE_SHOT)
	projections.append(projection)
	return projection

func project_plane(actor: Node2D,plane: Rect2,feet: PackedVector2Array,height: float,limit := 110.0) -> Node2D:
	var projection := preload("res://scripts/art/projected_prop_shadow.gd").new()
	projection.actor = actor
	projection.natural_light = self
	projection.source_kind = 1
	projection.height = height
	projection.sun_max_length = limit
	projection.raised_plane = plane
	projection.contacts = feet
	add_child(projection)
	actor.tree_exiting.connect(projection.queue_free,CONNECT_ONE_SHOT)
	projections.append(projection)
	return projection

func advance(delta: float) -> void:
	if profile==null or transitions_paused: return
	var target := _profile_state()
	if target!=_target_state:
		_target_state = target
		_settled = false
		_transition_elapsed = 0.0
	if _settled:
		if not cache_enabled: _sync()
		return
	_transition_elapsed += delta
	if _day_reset_pending and _transition_elapsed>=0.5:
		var morning := _day_reset_pending
		_day_reset_pending = null
		current_energy = 0.0
		current_opacity = 0.0
		current_azimuth = deg_to_rad(morning.shadow_azimuth_degrees)
		current_elevation = morning.elevation_degrees
		current_ground_y = morning.ground_y_scale
		projection_epoch += 1
		set_profile(morning)
		_sync()
		return
	if _transition_elapsed>=2.5:
		set_profile(profile,true)
		return
	var weight := 1.0-exp(-delta*(14.0 if _day_reset_pending else 5.0))
	current_sky = current_sky.lerp(profile.sky_color,weight)
	current_color = current_color.lerp(profile.direct_color,weight)
	current_energy = lerpf(current_energy,profile.direct_energy,weight)
	current_azimuth = lerp_angle(current_azimuth,deg_to_rad(profile.shadow_azimuth_degrees),weight)
	current_elevation = lerpf(current_elevation,profile.elevation_degrees,weight)
	current_opacity = lerpf(current_opacity,profile.shadow_opacity,weight)
	current_tint = current_tint.lerp(profile.shadow_tint,weight)
	current_ground_y = lerpf(current_ground_y,profile.ground_y_scale,weight)
	local_shadow_visibility = lerpf(local_shadow_visibility,profile.local_shadow_visibility,weight)
	eave_visibility = lerpf(eave_visibility,profile.eave_visibility,weight)
	_sync()

func _sync() -> void:
	if ambience==null: return
	sync_count += 1
	var shadow_state := [current_energy,current_azimuth,current_elevation,current_opacity,current_tint,current_ground_y]
	if shadow_state!=_shadow_state:
		_shadow_state = shadow_state
		shadow_revision += 1
	ambience.color = current_sky
	sunlight.enabled = current_energy>0.001
	sunlight.energy = current_energy
	sunlight.color = current_color
	sunlight.rotation = current_azimuth-PI/2
	# Native light height is for normal maps; it does not control shadow length.
	sunlight.height = sin(deg_to_rad(current_elevation))

func sample_shadow(height: float,max_length: float) -> Dictionary:
	# Geometry remains defined while invisible, so a faded preset jump does not
	# regrow the projection from a zero-length vector when shadows return.
	var length := maxf(0,height)/tan(deg_to_rad(clampf(current_elevation,5,85)))
	var direction := Vector2(cos(current_azimuth),sin(current_azimuth)*current_ground_y)
	var vector := direction*length
	if vector.length()>max_length: vector = vector.limit_length(maxf(0,max_length))
	return {"vector":vector,"opacity":current_opacity*clampf(current_energy/0.18,0,1)}

