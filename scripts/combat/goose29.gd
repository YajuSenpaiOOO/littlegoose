extends "res://scripts/combat/goose24.gd"
## Paper Cup Telephone: legacy relative spring, extended leash and touch damage.
var cup_phone := true
var last_shot_direction := Vector3.RIGHT
var contact_clock := 0.
var contact_next: Dictionary = {}

func flight_radius() -> float:
	return 110./battle.Profile.PPM

func clear_contact_state() -> void:
	contact_clock = 0.
	contact_next.clear()

func update_follow(delta: float,target: Vector3,snap := false) -> void:
	if not cup_phone and offset_xz.length()<=1.35:
		super.update_follow(delta,target,snap)
		_remember_direction(target)
		return
	if not battle.combat_paused:
		age += delta
		contact_clock += delta
	var center: Vector3 = battle.hero.position
	var wanted := Vector2(target.x-center.x,target.z-center.z)
	if not target.is_finite(): wanted=offset_xz
	if cup_phone:
		wanted=wanted.limit_length(flight_radius())
	else:
		wanted=wanted.normalized()*clampf(wanted.length(),.45,1.05)
	if snap:
		offset_xz=wanted
		spring_velocity=Vector2.ZERO
		if wanted.length()>.32:
			last_shot_direction=Vector3(wanted.x,0,wanted.y).normalized()
	elif not battle.combat_paused:
		spring_velocity += (wanted-offset_xz)*26.*delta
		spring_velocity -= spring_velocity*6.5*delta
		spring_velocity=spring_velocity.limit_length(480./battle.Profile.PPM)
		offset_xz=(offset_xz+spring_velocity*delta).limit_length(flight_radius())
	var at := Vector2(center.x,center.z)+offset_xz
	position=Vector3(at.x,battle.floor_height(at)+.43,at.y)
	_remember_direction(target)
	# Arrival keeps the previous heading instead of flipping every time the
	# recoil spring crosses the cursor or the beak changes side.
	var facing_target := position+last_shot_direction*2.
	_update_follow_visual(facing_target,snap)
	_update_wing_pose(delta,facing_target)
	if not snap: step_contact()

func _remember_direction(target: Vector3) -> void:
	if not target.is_finite(): return
	var vector := target-muzzle()
	if Vector2(vector.x,vector.z).length()>.32 and vector.length()>.32:
		last_shot_direction=vector.normalized()

func resolve_target(target: Vector3,origin: Vector3) -> Vector3:
	if not cup_phone or not target.is_finite(): return target
	var vector := target-origin
	if Vector2(vector.x,vector.z).length()<.32:
		return origin+last_shot_direction*3.
	return target

func step_contact() -> void:
	if not cup_phone or battle.combat_paused or battle.player_hp<=0. or battle.wave_state!="fighting": return
	for enemy in battle.enemies:
		if not is_instance_valid(enemy) or enemy.dead: continue
		var at := Vector2(position.x,position.z)
		var other := Vector2(enemy.position.x,enemy.position.z)
		var radius: float=.5*float(enemy.poses.idle.visible_width)/24.+10./battle.Profile.PPM
		if at.distance_to(other)>radius: continue
		var id: int=enemy.get_instance_id()
		if contact_clock<float(contact_next.get(id,-1.)): continue
		contact_next[id]=contact_clock+.5
		var direction := Vector3(enemy.position.x-position.x,0,enemy.position.z-position.z)
		if direction.length_squared()<.0001: direction=last_shot_direction
		battle.cup_contact_enemy(enemy,direction.normalized())
