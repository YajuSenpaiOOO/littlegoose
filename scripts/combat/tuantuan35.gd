extends "res://scripts/combat/tuantuan34.gd"
var small_cue: MeshInstance3D

func _ready() -> void:
	super._ready()
	small_cue=preload("res://scripts/combat/attack_glint35.gd").new()
	small_cue.enemy=self
	add_child(small_cue)

func _hold_recovery_pose() -> bool:
	# The real landing timer supplies the brief squash. Never hold it for the
	# whole vulnerability window: standing recovery must differ from windup.
	return false

func _render_legacy(lift: float) -> void:
	super._render_legacy(lift)
	if not battle.tactical_combat or dead or attack_phase!="recover" or hit_left>0. or landing_left>0.: return
	# Regain height while still catching breath; preserve the 0.62s punish window.
	var breath := sin(maxf(0.,phase_clock-.12)*TAU*2.)*.014
	visual.scale*=Vector3(1.-breath*.5,1.+breath,1.)
