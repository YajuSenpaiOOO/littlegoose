extends "res://scripts/combat/tuantuan33.gd"
var parry_stun := 0.
var parried_count := 0
var parry_lift := 0.

func _ready() -> void:
	super._ready()
	set_cue_enabled(battle.show_attack_cue)

func set_cue_enabled(enabled: bool) -> void:
	cue.set_process(enabled)
	cue.visible=enabled and attack_phase=="windup" and not dead

func _try_parry_attack(before: Vector3) -> bool:
	return battle.try_parry_lunge(self,before)

func deflect(contact: Vector3) -> void:
	attack_connected=true; parried_count+=1; parry_stun=.75
	parry_lift=visual.position.y
	attack_phase="recover"; phase_clock=-.13; hopping=false
	var away := Vector2(global_position.x-battle.hero.global_position.x,global_position.z-battle.hero.global_position.z).normalized()
	impulse=away*4.5
	hit_direction=Vector3(away.x,0,away.y)
	hit_left=.18; hit_rearm=.055; flash=.075
	squeeze=.17; squeeze_velocity=-.4; tuft_velocity-=away.x*.8
	battle.parry_success(contact,hit_direction)

func _physics_process(delta: float) -> void:
	if not battle.combat_paused: parry_stun=maxf(0.,parry_stun-delta)
	super._physics_process(delta)

func _render_legacy(lift: float) -> void:
	if parry_stun>0.:
		lift=maxf(lift,parry_lift*smoothstep(.45,.75,parry_stun))
	super._render_legacy(lift)
	if not battle.tactical_combat or dead: return
	if attack_phase=="windup":
		var weight := clampf(phase_clock/WINDUP,0.,1.)
		visual.scale*=Vector3(1.+weight*.045,1.-weight*.045,1.)
		# After committing, the held crouch is the tell instead of a ground arrow.
		visual.rotation.z-=attack_direction.x*.025*smoothstep(LOCK_AT,WINDUP,phase_clock)
