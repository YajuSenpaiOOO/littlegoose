extends "res://scripts/combat/hero30.gd"
const PARRY_WINDOW := .18
const PARRY_CD := 1.
const PARRY_GATE := .06
const PARRY_RECLOSE := .03
const PARRY_RECOVER := .18
const PARRY_REACH := 30./(78.3/4.1)
var parry_t := 0.
var parry_cd := 0.
var parry_recover := 0.
var parry_previous := false
var parried := false
var parry_facing := "down"
var parry_art: Dictionary={}
var parry_squash := Vector2.ZERO
var parry_squash_velocity := Vector2.ZERO
var parry_starts := 0
var parry_whiffs := 0

func _ready() -> void:
	super._ready()
	parry_art=JSON.parse_string(FileAccess.get_file_as_string("res://assets/hero_pixel/parry_directions_v1.json"))
	for entry: Dictionary in parry_art.values(): entry.texture=load("res://assets/hero_pixel/"+str(entry.file))

func parry_key_down() -> bool:
	return controls_enabled and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

func request_parry() -> bool:
	if not controls_enabled or battle.combat_paused or battle.player_hp<=0. or knocked_down or story_knocked or dash_left>0. or parry_cd>0. or parry_t>0.: return false
	parry_t=PARRY_WINDOW; parry_cd=PARRY_CD; parried=false
	parry_facing=facing; parry_starts+=1
	battle.Audio.play("parry_on")
	render_pose()
	return true

func can_parry() -> bool:
	return parry_t>0. and dash_left<=0. and dodge_invulnerability<=0. and battle.invulnerability<=0. and battle.player_hp>0. and not battle.combat_paused

func consume_parry() -> void:
	parried=true
	parry_t=minf(parry_t,PARRY_RECLOSE)
	parry_cd=PARRY_GATE; parry_recover=PARRY_RECOVER
	parry_squash=Vector2(.26,-.24); parry_squash_velocity=Vector2.ZERO

func request_dash(direction := Vector2.ZERO) -> bool:
	var accepted := super.request_dash(direction)
	if accepted: parry_t=0.
	return accepted

func reset_actions() -> void:
	super.reset_actions()
	parry_t=0.; parry_cd=0.; parry_recover=0.; parried=false
	parry_squash=Vector2.ZERO; parry_squash_velocity=Vector2.ZERO
	parry_previous=parry_key_down()
	parry_starts=0; parry_whiffs=0

func _physics_process(delta: float) -> void:
	if battle.combat_paused: return
	parry_cd=maxf(0.,parry_cd-delta); parry_recover=maxf(0.,parry_recover-delta)
	if parry_t>0.:
		parry_t=maxf(0.,parry_t-delta)
		if parry_t<=0. and not parried:
			parry_whiffs+=1
			battle.Audio.play("parry_whiff")
	var pressed := parry_key_down()
	if pressed and not parry_previous: request_parry()
	parry_previous=pressed
	var remaining := minf(delta,.1)
	while remaining>0.:
		var step := minf(remaining,1./120.)
		parry_squash_velocity+=(-620.*parry_squash-11.*parry_squash_velocity)*step
		parry_squash+=parry_squash_velocity*step
		remaining-=step
	super._physics_process(delta)

func render_pose() -> void:
	super.render_pose()
	if knocked_down or story_knocked or (is_instance_valid(battle) and battle.player_hp<=0.) or dash_left>0.: return
	if parry_t>0. and parry_art.has(parry_facing):
		var pose: Dictionary=parry_art[parry_facing]
		visual.texture=pose.texture
		visual.flip_h=false
		visual.pixel_size=float(pose.world_height)/float(pose.body_height)/motion_pixels_per_m
		visual.offset=Vector2(visual.texture.get_width()*.5-float(pose.foot[0]),float(pose.foot[1])-visual.texture.get_height()*.5)
		visual.position=Vector3.ZERO; visual.scale=Vector3.ONE; visual.rotation=Vector3.ZERO
	visual.scale*=Vector3(1.+parry_squash.x,1.+parry_squash.y,1.)
