extends "res://scripts/combat/tuantuan21.gd"
var impact_pause := 0.

func receive_hit(damage: float,direction: Vector3) -> void:
	if dead: return
	var lift := visual.position.y
	super.receive_hit(damage,direction)
	impact_pause = .055
	if not dead: _pose("hit",lift)
	battle.on_combat_impact(self,damage)

func _pose(key: String,lift: float) -> void:
	super._pose(key,lift)
	var squeeze := clampf(flash/.13,0.,1.) if not dead else 0.
	visual.scale = Vector3(1.+squeeze*.18,1.-squeeze*.18,1.)

func _physics_process(delta: float) -> void:
	if impact_pause>0. and not battle.combat_paused:
		impact_pause = maxf(0.,impact_pause-delta)
		return
	super._physics_process(delta)
