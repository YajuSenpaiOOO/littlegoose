extends "res://scripts/perspective_actor.gd"
const DASH_DURATION := .16
const DASH_COOLDOWN := .55
var battle: Node3D
var body_clock := 0.
var dash_left := 0.
var dash_cd := 0.
var dodge_invulnerability := 0.
var dash_direction := Vector2.DOWN
var dash_pose := "down"
var dash_count := 0
var dash_eligible := false
var shift_previous := false
var dash_art: Dictionary={}
var ghosts: Array[Dictionary]=[]
var ghost_clock := 0.

func _ready() -> void:
	battle=get_parent()
	super._ready()
	# Horizontal camera angle is fixed. Keep a real upright card so Sprite3D's
	# billboard shader does not discard the authored in-plane walking tilt.
	visual.billboard=BaseMaterial3D.BILLBOARD_DISABLED
	dash_art=JSON.parse_string(FileAccess.get_file_as_string("res://assets/hero_pixel/dash_choices/directions_v1.json"))
	for data in dash_art.values(): data.texture=load("res://assets/hero_pixel/dash_choices/"+str(data.file))

func movement_speed() -> float: return 4.1
func dash_speed() -> float: return 260./motion_pixels_per_m
func dash_key_down() -> bool: return controls_enabled and Input.is_physical_key_pressed(KEY_SHIFT)

func request_dash(direction := Vector2.ZERO) -> bool:
	if not controls_enabled or dash_left>0. or dash_cd>0. or battle.combat_paused or battle.player_hp<=0.: return false
	if direction==Vector2.ZERO:
		direction=movement_input()
	if direction==Vector2.ZERO:
		direction={"down":Vector2.DOWN,"up":Vector2.UP,"left":Vector2.LEFT,"right":Vector2.RIGHT}[facing]
	dash_direction=direction.normalized()
	dash_pose=facing
	dash_left=DASH_DURATION
	dash_cd=DASH_COOLDOWN
	dodge_invulnerability=maxf(dodge_invulnerability,DASH_DURATION+.04)
	dash_eligible=battle.invulnerability<=0.
	locomotion=Vector2.ZERO
	combat_impulse=Vector2.ZERO
	ghost_clock=0.
	dash_count+=1
	if battle.has_method("on_dash_started"): battle.on_dash_started()
	return true

func reset_actions() -> void:
	knocked_down=false; story_knocked=false
	dash_left=0.; dash_cd=0.; dodge_invulnerability=0.
	shift_previous=dash_key_down()
	for ghost in ghosts:
		if is_instance_valid(ghost.node): ghost.node.queue_free()
	ghosts.clear()
	visual.flip_h=false
	visual.scale=Vector3.ONE
	visual.position=Vector3.ZERO
	visual.rotation=Vector3.ZERO

func _physics_process(delta: float) -> void:
	body_clock+=delta
	dash_cd=maxf(0.,dash_cd-delta)
	dodge_invulnerability=maxf(0.,dodge_invulnerability-delta)
	_step_ghosts(delta)
	var pressed := dash_key_down()
	if pressed and not shift_previous: request_dash()
	shift_previous=pressed
	if not controls_enabled: dash_left=0.
	if dash_left<=0.:
		super._physics_process(delta)
		return
	var before := global_position
	var step := minf(delta,dash_left)
	var speed := dash_speed()*step/maxf(delta,.00001)
	velocity=Vector3(dash_direction.x*speed,-.3 if is_on_floor() else velocity.y-20.*delta,dash_direction.y*speed)
	move_and_slide()
	moving=true
	render_pose()
	ghost_clock-=delta
	if ghost_clock<=0.: _spawn_ghost(); ghost_clock=.03
	if dash_eligible:
		for enemy in battle.enemies:
			if not is_instance_valid(enemy) or enemy.dead: continue
			if battle.has_method("can_perfect_dodge") and not battle.can_perfect_dodge(enemy): continue
			var t: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(global_position.x,global_position.z),Vector2(enemy.position.x,enemy.position.z),34./motion_pixels_per_m)
			if t<INF:
				dash_eligible=false
				battle.perfect_dodge()
				break
	dash_left=maxf(0.,dash_left-step)
	if dash_left<=0.:
		combat_impulse=dash_direction*70./motion_pixels_per_m
		render_pose()

func render_pose() -> void:
	var fallen: bool=knocked_down or story_knocked or (is_instance_valid(battle) and battle.player_hp<=0.)
	if dash_left>0. and not fallen and dash_art.has(dash_pose):
		var pose: Dictionary=dash_art[dash_pose]
		visual.texture=pose.texture
		visual.flip_h=bool(pose.get("flip_h",false))
		var x: float=pose.foot[0]
		if visual.flip_h: x=visual.texture.get_width()-x
		visual.offset=Vector2(visual.texture.get_width()*.5-x,float(pose.foot[1])-visual.texture.get_height()*.5)
		visual.pixel_size=float(pose.unit)/motion_pixels_per_m
		visual.position=Vector3.ZERO
		visual.scale=Vector3.ONE
		visual.rotation=Vector3.ZERO
		return
	super.render_pose()
	visual.flip_h=false
	visual.position=Vector3.ZERO
	visual.scale=Vector3.ONE
	visual.rotation=Vector3.ZERO
	if fallen:
		if knocked_art==null: knocked_art=load("res://assets/hero_pixel/ko_knocked_v2.png")
		visual.texture=knocked_art
		visual.pixel_size=1.6/980.
		visual.offset=Vector2(knocked_art.get_width()*.5-650.5,1112.-knocked_art.get_height()*.5)
		return
	if moving:
		var wave := sin(phase*TAU)
		var step := absf(wave)
		visual.position.y=step*6.*.20/motion_pixels_per_m
		visual.rotation.z=-wave*.013
		visual.scale=Vector3(1.-step*.018,1.+step*.028,1.)
	else:
		var breath := sin(body_clock*PI*1.8)*.008
		visual.scale=Vector3(1.-breath,1.+breath,1.)

func _spawn_ghost(opacity := .4) -> void:
	if ghosts.size()>=7: return
	var ghost := Sprite3D.new()
	ghost.texture=visual.texture
	ghost.pixel_size=visual.pixel_size
	ghost.offset=visual.offset
	ghost.flip_h=visual.flip_h
	ghost.billboard=visual.billboard
	ghost.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	ghost.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ghost.shaded=false
	ghost.modulate=Color(1.,.75,.85,opacity)
	ghost.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
	battle.add_child(ghost)
	ghost.global_transform=visual.global_transform
	ghosts.append({"node":ghost,"age":0.,"opacity":opacity})

func _step_ghosts(delta: float) -> void:
	for i in range(ghosts.size()-1,-1,-1):
		var ghost: Dictionary=ghosts[i]
		ghost.age+=delta
		if ghost.age>=.22 or not is_instance_valid(ghost.node):
			if is_instance_valid(ghost.node): ghost.node.queue_free()
			ghosts.remove_at(i)
		else: ghost.node.modulate.a=ghost.opacity*(1.-ghost.age/.22)
