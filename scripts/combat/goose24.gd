extends "res://scripts/combat/goose23.gd"
var attack_hold := 0.
var attack_blend := 0.
var visual_kick := 0.
var kick_cd := 0.

func update_follow(delta: float,target: Vector3,snap := false) -> void:
	super.update_follow(delta,target,snap)
	_update_wing_pose(delta,target)

func _update_wing_pose(delta: float,target: Vector3) -> void:
	if not battle.legacy_feel:
		visual.rotation.z = 0.
		return
	if not battle.combat_paused:
		attack_hold = maxf(0.,attack_hold-delta)
		kick_cd = maxf(0.,kick_cd-delta)
		visual_kick = move_toward(visual_kick,0.,delta*.6)
		attack_blend = move_toward(attack_blend,1. if attack_hold>0. else 0.,delta*8.)
	var facing := 1. if visual.flip_h else -1.
	var vx: float = (battle.hero.velocity.x+spring_velocity.x)*battle.Profile.PPM
	visual.rotation.z = -clampf(vx*.002,-.12,.12)-facing*(attack_blend*.13-visual_kick)

func recoil(direction: Vector3) -> void:
	super.recoil(direction)
	if battle.legacy_feel:
		attack_hold = .18
		if kick_cd<=0.: visual_kick=.045; kick_cd=.18

func muzzle() -> Vector3:
	return visual.to_global(Vector3(.108 if visual.flip_h else -.108,.416,0))
