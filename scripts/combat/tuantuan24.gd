extends "res://scripts/combat/tuantuan23.gd"
const Profile = preload("res://scripts/combat/legacy_profile24.gd")
var hit_left := 0.
var hit_rearm := 0.
var landing_left := 0.
var hit_direction := Vector3.ZERO
var defeat_age := 0.
var defeat_start_lift := 0.
var impact_contact := Vector3.INF
var juice_gate := 0.
var whip_count := 0

func receive_hit(damage: float,direction: Vector3) -> void:
	if dead: return
	hp = maxf(0.,hp-damage)
	hit_count += 1
	health_time = 1.5
	hit_direction = direction.normalized()
	if hit_rearm<=0.:
		hit_left = Profile.HIT_POSE
		hit_rearm = Profile.HIT_REARM
	impulse = (impulse*.35+Vector2(direction.x,direction.z).normalized()*Profile.KNOCK).limit_length(Profile.KNOCK_MAX)
	flash = Profile.FLASH
	if hp<=0.:
		dead = true
		defeat_age = 0.
		defeat_start_lift = visual.position.y
		hopping = false
		collision_layer = 0
		var capsule: CapsuleShape3D = hit_area.get_child(0).shape
		capsule.radius = .43
		capsule.height = .86
		hit_area.position.y = .43
		battle.enemy_defeated(self)
	var contact := impact_contact if impact_contact.is_finite() else position+Vector3.UP*(.65+visual.position.y)
	battle.on_legacy_contact(self,contact,direction,juice_gate<=0. or dead)
	juice_gate = .11 if juice_gate<=0. or dead else juice_gate
	impact_contact = Vector3.INF
	_render_legacy(visual.position.y)

func whip(direction: Vector3) -> void:
	if not dead: return
	whip_count += 1
	hit_left = .12
	impulse += Vector2(direction.x,direction.z).normalized()*30./Profile.PPM

func _pose(key: String,lift: float) -> void:
	# Reconstruct the pose from its root every frame. Hit recoil below is a
	# temporary local offset, never an increment to last frame's displaced art.
	visual.position = Vector3(0,lift,0)
	super._pose(key,lift)
	# The selected old tuantuan art uses authored pose silhouettes, not generic scale squash.
	visual.scale = Vector3.ONE
	if dead: hit_area.position.y = .43

func _render_legacy(lift: float) -> void:
	var pose := "idle"
	if dead: pose = "hit" if defeat_age<.065 else "defeated"
	elif hit_left>0.: pose = "hit"
	elif landing_left>0.: pose = "landing"
	elif hopping: pose = "anticipation" if hop_clock<.045 else "airborne"
	_pose(pose,lift)
	visual.flip_h = pose=="hit" and hit_direction.x>0.
	# Sprite3D's flip changes UVs; invert the anchored offset as the old Sprite2D did.
	if visual.flip_h: visual.offset.x = -visual.offset.x
	visual.modulate = Color(1.12,.88,.96) if flash>0. and not dead else Color.WHITE
	if dead:
		visual.rotation.z = -hit_direction.x*.18*sin(clampf(defeat_age/.28,0.,1.)*PI)
	elif pose=="hit":
		var kick := sin(clampf(hit_left/.12,0.,1.)*PI)*2./Profile.PPM
		visual.position += Vector3(hit_direction.x*kick,0,hit_direction.z*kick)
	else: visual.rotation.z = 0.

func _physics_process(delta: float) -> void:
	if battle.combat_paused: return
	age += delta
	hit_left = maxf(0.,hit_left-delta)
	hit_rearm = maxf(0.,hit_rearm-delta)
	landing_left = maxf(0.,landing_left-delta)
	juice_gate = maxf(0.,juice_gate-delta)
	flash = maxf(0.,flash-delta)
	health_time = maxf(0.,health_time-delta)
	var motion := Vector2.ZERO
	var lift := 0.
	if dead:
		corpse_time += delta
		defeat_age += delta
		var progress := clampf(defeat_age/Profile.DEFEAT_TIME,0.,1.)
		lift = defeat_start_lift*(1.-progress)+sin(progress*PI)*8./Profile.PPM
		if defeat_age-delta<Profile.DEFEAT_TIME and defeat_age>=Profile.DEFEAT_TIME:
			battle.emit_legacy_art(position,Vector3.RIGHT,"impact",.8)
		if corpse_time>Profile.CORPSE_LIFE:
			var fraction := clampf((corpse_time-Profile.CORPSE_LIFE)/Profile.CORPSE_FADE,0.,1.)
			visual.transparency = fraction
			if fraction>=1.: queue_free(); return
	else:
		var at := Vector2(position.x,position.z)
		var player := Vector2(battle.hero.position.x,battle.hero.position.z)
		var engaged: bool = active_ai and battle.player_hp>0. and player.distance_to(home)<23.
		var target := player if engaged else home
		path_clock -= delta
		if path_clock<=0.:
			route = battle.navigation.path(at,target)
			path_clock = .4
		while route.size()>1 and at.distance_to(route[0])<.65: route.remove_at(0)
		if not hopping and active_ai and (engaged or at.distance_to(home)>1.):
			hop_direction = (route[0]-at).normalized() if not route.is_empty() else Vector2.ZERO
			var separation := Vector2.ZERO
			for other in battle.enemies:
				if not is_instance_valid(other) or other==self or other.dead: continue
				var diff := at-Vector2(other.position.x,other.position.z)
				if diff.length_squared()<1.8 and diff.length_squared()>.001: separation += diff.normalized()*.45
			hop_direction = (hop_direction+separation).normalized()
			hopping = true
			hop_clock = 0.
		if hopping:
			hop_clock += delta
			var phase := clampf(hop_clock/Profile.HOP_TIME,0.,1.)
			motion = hop_direction*Profile.HOP_SPEED*sin(phase*PI)
			lift = sin(phase*PI)*Profile.HOP_LIFT
			if phase>=1.:
				hopping = false
				landing_left = .09
				lift = 0.
		if battle.player_hp>0. and at.distance_to(player)<.88:
			battle.hurt_player(20.,at)
	velocity.x = motion.x+impulse.x
	velocity.z = motion.y+impulse.y
	impulse *= maxf(0.,1.-(6. if dead else Profile.KNOCK_DECAY)*delta)
	velocity.y = -.3 if is_on_floor() else velocity.y-20.*delta
	move_and_slide()
	_render_legacy(lift)
	if dead and corpse_time>Profile.CORPSE_LIFE:
		visual.scale *= clampf(1.-(corpse_time-Profile.CORPSE_LIFE)/Profile.CORPSE_FADE,0.,1.)
