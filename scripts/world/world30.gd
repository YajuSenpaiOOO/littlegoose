extends "res://scripts/world/world29.gd"
var impact_clock=preload("res://scripts/combat/impact_clock30.gd").new()
var feel_ready := false
var closeup_started := -1.
var closeup_focus := Vector3.ZERO
var closeup_weight := 0.
var camera_gain := 1.
var dodge_zoom := 0.
var camera_clock := 0.
var perfect_dodges := 0
const LEGACY_BASE_ZOOM := 4.0 # my_map.tscn uses main.gd's default base_zoom.
const LEGACY_BATTLE_ZOOM := 1.2
const Butterfly = preload("res://scripts/combat/legacy/perfect_dodge_butterfly.gd")
const LegacyFX = preload("res://scripts/combat/legacy/fx.gd")
var camera_look := Vector2.ZERO
var closeup_slow_shaken := false
var hp_shake_left := 0.
var hp_shake_amp := 0.

func _hero_script() -> Script:
	return preload("res://scripts/combat/hero30.gd")

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan30.gd") if legacy_feel else super._enemy_script()

func accepts_cursor_enemy(enemy: CharacterBody3D) -> bool:
	return not enemy.dead or enemy.visual.transparency<.9

func _ready() -> void:
	super._ready()
	while not is_instance_valid(guide_overlay): await get_tree().physics_frame
	guide_overlay.queue_free()
	guide_overlay=null
	var previous: Node3D=reticle
	remove_child(previous)
	previous.queue_free()
	reticle=preload("res://scripts/combat/muzzle_reticle30.gd").new()
	reticle.battle=self
	add_child(reticle)
	var meter := preload("res://scripts/combat/dash_meter30.gd").new()
	meter.battle=self
	battle_label.get_parent().add_child(meter)
	ordinary_hitstop=true
	# Warm the translucent sprite pipeline before the first visible dash.
	hero._spawn_ghost(.001)
	camera_clock=Time.get_ticks_msec()/1000.
	feel_ready=true
	print("WORLD30_FEEL_READY")

func hitstop(duration: float,force := false) -> void:
	if duration<=.012 and not ordinary_hitstop: return
	var now := Time.get_ticks_msec()/1000.
	if now<stop_gate and (not force or duration<=stop_duration): return
	stop_gate=now+duration+.12
	stop_duration=duration
	stop_until=maxf(stop_until,now+duration)
	impact_clock.add(.05,duration)
	impact_clock.tick()

func set_temp_time_scale(scale: float,duration: float,delay := 0.) -> void:
	impact_clock.add(scale,duration,delay)
	impact_clock.tick()

func _advance_impact_time() -> void:
	impact_clock.tick()
	if Time.get_ticks_msec()/1000.>=stop_until: stop_until=0.

func _base_zoom_delta() -> float:
	return LEGACY_BATTLE_ZOOM if wave_state=="fighting" else 0.

func _framing_gain(_delta: float) -> float:
	return (LEGACY_BASE_ZOOM+_base_zoom_delta())/LEGACY_BASE_ZOOM

func _update_impact_camera(delta: float) -> void:
	if not legacy_feel or not combat_ready: return
	var now := Time.get_ticks_msec()/1000.
	camera_clock=now
	trauma=maxf(0.,trauma-2.2*delta)
	var desired := Vector2(cosmetic_rng.randf_range(-1,1),cosmetic_rng.randf_range(-1,1))*5.*trauma*trauma/Profile.PPM
	shake_offset=shake_offset.lerp(desired,.45) if trauma>0. else Vector2.ZERO
	camera.h_offset=shake_offset.x
	camera.v_offset=shake_offset.y
	punch=lerpf(punch,0.,minf(1.,9.*delta))
	dodge_zoom=lerpf(dodge_zoom,0.,minf(1.,1.8*delta))
	closeup_weight=0.
	if closeup_started>=0.:
		var age := now-closeup_started
		if age<1.1:
			closeup_weight=1.
			if age>=.4 and not closeup_slow_shaken:
				closeup_slow_shaken=true
				trauma=minf(1.,trauma+.45)
		else: closeup_started=-1.
	# Old zooms are additive to the MAP baseline, not to a guessed 3.0.
	var base_gain := (LEGACY_BASE_ZOOM+2.2)/LEGACY_BASE_ZOOM if closeup_weight>0. else _framing_gain(delta)
	var target_gain := base_gain+(punch+dodge_zoom)/LEGACY_BASE_ZOOM
	camera_gain=lerpf(camera_gain,target_gain,minf(1.,8.*delta))
	camera.fov=rad_to_deg(2.*atan(tan(deg_to_rad(21.))/camera_gain))
	if is_instance_valid(health_track):
		hp_shake_left=maxf(0.,hp_shake_left-delta)
		var offset := Vector2(cosmetic_rng.randf_range(-1,1),cosmetic_rng.randf_range(-1,1))*hp_shake_amp*hp_shake_left/.25 if hp_shake_left>0. else Vector2.ZERO
		health_track.position=Vector2(24,22)+offset
	if combo>0 and now-combo_last>1.2: combo=0

func _update_camera(delta: float,snap := false) -> void:
	if not feel_ready or not legacy_feel:
		super._update_camera(delta,snap)
		return
	if not follow_camera and not snap: return
	var focus := hero.position+Vector3.UP*.85
	if closeup_started>=0.:
		focus=closeup_focus
		camera_look=Vector2.ZERO
	else:
		camera_look=camera_look.lerp(Vector2(hero.velocity.x,hero.velocity.z)*.22,minf(1.,4.*delta)).limit_length(48./Profile.PPM)
		focus+=Vector3(camera_look.x,0,camera_look.y)
	var offset := Vector3(0,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))*camera_distance
	camera.position=focus+offset if snap else camera.position.lerp(focus+offset,minf(1.,7.*delta))
	if snap: camera.reset_physics_interpolation()

func enemy_defeated(enemy: CharacterBody3D) -> void:
	super.enemy_defeated(enemy)
	if wave_state=="cleared" and legacy_feel and player_hp>0. and not combat_paused:
		closeup_started=Time.get_ticks_msec()/1000.
		# Source focus is the ground anchor + (0,-6) in legacy screen pixels.
		closeup_focus=enemy.global_position+Vector3.UP*(6./Profile.PPM)
		closeup_weight=1.
		closeup_slow_shaken=false
		trauma=minf(1.,trauma+.3)
		# Old end-of-wave closeup: push in, 0.25x for 0.5 real seconds, pull out.
		set_temp_time_scale(.25,.5,.4)
		set_temp_time_scale(1.,0.,.95)

func on_dash_started() -> void:
	if not is_instance_valid(fx_layer): return
	Audio.play("dash")
	var node := anchor(hero.position,.4)
	if node!=null:
		LegacyFX.burst(node,Vector2.ZERO,3,30.,70.,Color(.9,.82,.92,.9),-screen_direction(hero.position,Vector3(hero.dash_direction.x,0,hero.dash_direction.y)),.3,.35,.6)

func perfect_dodge() -> void:
	if player_hp<=0. or combat_paused: return
	perfect_dodges+=1
	set_temp_time_scale(.3,.22)
	trauma=minf(1.,trauma+.1)
	dodge_zoom=1.
	hero.dodge_invulnerability=maxf(hero.dodge_invulnerability,.5)
	Audio.play("absorb")
	var at := hero.position+Vector3.UP*(14./Profile.PPM)
	var node := anchor(at,1.)
	if node!=null:
		var effect: Node2D=Butterfly.spawn(node,node.global_position,screen_direction(at,Vector3(hero.dash_direction.x,0,hero.dash_direction.y)))
		effect.position=Vector2.ZERO

func hurt_player(damage: float,from: Vector2) -> void:
	if hero.dodge_invulnerability>0.: return
	var before := player_hp
	super.hurt_player(damage,from)
	if player_hp<before and legacy_feel:
		hp_shake_left=.25
		hp_shake_amp=7.*clampf((damage/10.)/2.,1.,3.)
	if before>0. and player_hp<=0.:
		hero.knocked_down=true
		hero.render_pose()
		# Game-over resets an existing freeze before the old 0.25x death beat.
		impact_clock.clear()
		set_temp_time_scale(.25,.6)
		trauma=minf(1.,trauma+.5)
		Audio.play("over")

func _reset_impact_state() -> void:
	super._reset_impact_state()
	impact_clock.clear()
	closeup_started=-1.; closeup_weight=0.; camera_gain=1.; dodge_zoom=0.
	camera_clock=Time.get_ticks_msec()/1000.
	perfect_dodges=0
	camera_look=Vector2.ZERO; closeup_slow_shaken=false
	hp_shake_left=0.; hp_shake_amp=0.
	if is_instance_valid(health_track): health_track.position=Vector2(24,22)
	if is_instance_valid(hero) and hero.has_method("reset_actions"): hero.reset_actions()

func _exit_tree() -> void:
	impact_clock.clear()
	super._exit_tree()

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界29","连续世界30").replace("WASD / Shift 移动","WASD 移动 / Shift 闪避")
