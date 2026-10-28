extends "res://scripts/combat/tuantuan32.gd"
const WINDUP := .48
const LOCK_AT := .18
const LUNGE := .36
const RECOVER := .62
var attack_phase := "approach"
var phase_clock := 0.
var attack_direction := Vector2.DOWN
var attack_distance := 0.
var attack_connected := false
var attacks_started := 0
var attack_landings := 0
var cue: MeshInstance3D

func _engagement_radius33() -> float: return 23.

func _ready() -> void:
	super._ready()
	phase_clock=-rest
	cue=preload("res://scripts/combat/attack_cue33.gd").new()
	cue.enemy=self
	add_child(cue)

func _begin_windup(target: Vector2) -> void:
	attack_phase="windup"; phase_clock=0.; hopping=false
	_lock_direction(target)
	attacks_started+=1
	attack_connected=false
	impulse*=.5
	battle.Audio.play("parry_on",.8)

func _lock_direction(target: Vector2) -> void:
	var vector := target-Vector2(global_position.x,global_position.z)
	attack_direction=vector.normalized() if vector.length()>.001 else Vector2.DOWN
	attack_distance=clampf(vector.length(),1.4,3.8)

func _update_windup_target(target: Vector2) -> void:
	if phase_clock<LOCK_AT: _lock_direction(target)

func _physics_process(delta: float) -> void:
	if not battle.tactical_combat or dead:
		super._physics_process(delta)
		return
	if battle.combat_paused: return
	_step_soft_response(delta)
	_step_squeeze(delta)
	age+=delta; phase_clock+=delta
	hit_left=maxf(0.,hit_left-delta); hit_rearm=maxf(0.,hit_rearm-delta)
	landing_left=maxf(0.,landing_left-delta); flash=maxf(0.,flash-delta)
	health_time=maxf(0.,health_time-delta); juice_gate=maxf(0.,juice_gate-delta)
	var at := Vector2(global_position.x,global_position.z)
	var player := Vector2(battle.hero.global_position.x,battle.hero.global_position.z)
	var engaged: bool=active_ai and battle.player_hp>0. and player.distance_to(home)<_engagement_radius33() and battle.wave_state=="fighting"
	var motion := Vector2.ZERO
	var lift := 0.
	if not engaged:
		attack_phase="approach"; phase_clock=0.; hopping=false
	elif attack_phase=="approach":
		if not hopping and phase_clock>=0. and at.distance_to(player)<=4.6 and battle.reserve_attack(self):
			_begin_windup(player)
		else:
			path_clock-=delta
			if path_clock<=0.: route=battle.navigation.path(at,player); path_clock=.35
			while route.size()>1 and at.distance_to(route[0])<.65: route.remove_at(0)
			if not hopping and phase_clock>=.12:
				hop_direction=(route[0]-at).normalized() if not route.is_empty() else (player-at).normalized()
				hopping=true; hop_clock=0.
			if hopping:
				hop_clock+=delta
				var progress := clampf(hop_clock/.40,0.,1.)
				motion=hop_direction*3.1*sin(progress*PI)
				lift=sin(progress*PI)*.24
				if progress>=1.:
					hopping=false; phase_clock=0.; landing_left=.09
					squeeze=minf(.16,squeeze+.045); squeeze_velocity=-.2
	elif attack_phase=="windup":
		_update_windup_target(player)
		if phase_clock>=WINDUP:
			attack_phase="lunge"; phase_clock=0.
			battle.Audio.play("dash",.8)
	elif attack_phase=="lunge":
		var progress := clampf(phase_clock/LUNGE,0.,1.)
		motion=attack_direction*attack_distance/LUNGE
		lift=sin(progress*PI)*.60
		if phase_clock>=LUNGE:
			attack_phase="recover"; phase_clock=0.; motion=Vector2.ZERO; lift=0.
			landing_left=.12; landing_count+=1; attack_landings+=1
			squeeze=minf(.19,squeeze+.10); squeeze_velocity=-.35; tuft_velocity+=.35
			if is_instance_valid(battle.jelly_fx): battle.jelly_fx._play(battle.jelly_fx.landing_clip,global_position,-11.,.85)
	elif attack_phase=="recover":
		if phase_clock>=RECOVER: attack_phase="approach"; phase_clock=0.
	var before := global_position
	velocity.x=motion.x+impulse.x; velocity.z=motion.y+impulse.y
	impulse*=maxf(0.,1.-Profile.KNOCK_DECAY*delta)
	velocity.y=-.3 if is_on_floor() else velocity.y-20.*delta
	move_and_slide()
	if engaged and attack_phase=="lunge" and not attack_connected:
		if _try_parry_attack(before):
			_render_legacy(lift)
			return
		var t: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(global_position.x,global_position.z),player,.82)
		if t<INF and absf(global_position.y-battle.hero.global_position.y)<.65:
			attack_connected=true
			battle.hurt_player(20.,Vector2(global_position.x,global_position.z))
	_render_legacy(lift)

func _try_parry_attack(_before: Vector3) -> bool:
	return false

func _hold_recovery_pose() -> bool:
	return true

func _render_legacy(lift: float) -> void:
	var saved_hopping := hopping
	var saved_clock := hop_clock
	var saved_landing := landing_left
	if battle.tactical_combat and not dead:
		if attack_phase=="windup": hopping=true; hop_clock=0.
		elif attack_phase=="lunge": hopping=true; hop_clock=.1
		elif attack_phase=="recover":
			hopping=false
			if _hold_recovery_pose(): landing_left=maxf(landing_left,.08)
	super._render_legacy(lift)
	hopping=saved_hopping; hop_clock=saved_clock; landing_left=saved_landing
	if battle.tactical_combat and not dead and attack_phase=="windup":
		var press := .055*clampf(phase_clock/WINDUP,0.,1.)
		visual.scale*=Vector3(1.+press,1.-press,1.)
	if dead and defeat_age>=.28 and defeat_age<.44:
		var settle := sin((defeat_age-.28)/.16*PI)
		visual.scale*=Vector3(1.+settle*.06,1.-settle*.08,1.)
