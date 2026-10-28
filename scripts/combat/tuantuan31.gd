extends "res://scripts/combat/tuantuan30.gd"
## Cosmetic spring only: never displace the native hurt capsule or accumulate offsets.
var squeeze := 0.
var squeeze_velocity := 0.
var response_direction := Vector3.RIGHT

func receive_hit(damage: float,direction: Vector3) -> void:
	if dead: return
	response_direction=direction.normalized()
	squeeze=minf(.19,squeeze+.13)
	squeeze_velocity=-.4
	super.receive_hit(damage,direction)

func _physics_process(delta: float) -> void:
	_step_squeeze(delta)
	super._physics_process(delta)

func _step_squeeze(delta: float) -> void:
	if not battle.combat_paused:
		# Substeps keep the damped spring stable after a long render frame.
		var remaining := minf(delta,.1)
		while remaining>0.:
			var step := minf(remaining,1./120.)
			squeeze_velocity+=(-260.*squeeze-16.*squeeze_velocity)*step
			squeeze+=squeeze_velocity*step
			remaining-=step

func _render_legacy(lift: float) -> void:
	super._render_legacy(lift)
	if not battle.material_feedback: return
	# Rebuilt from the authored pose every frame; feet remain the scale pivot.
	var amount := clampf(squeeze,-.07,.2)
	visual.scale=Vector3(1.+amount*.8,1.-amount,1.)
	var screen: Vector2=battle.screen_direction(global_position,response_direction)
	visual.rotation.z+=-screen.x*amount*.24
	visual.position+=response_direction*amount*.23
	# Depth-directed hits still compress the visible silhouette.
	visual.position.y+=absf(screen.y)*maxf(0.,amount)*.10
