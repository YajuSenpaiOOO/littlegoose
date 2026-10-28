extends "res://scripts/world/world23.gd"
const Profile = preload("res://scripts/combat/legacy_profile24.gd")
const Candy = preload("res://scripts/combat/legacy/candy_bullet_art.gd")
const MaterialFX = preload("res://scripts/combat/legacy/hit_material_fx.gd")
var legacy_feel := true
var fx_layer: CanvasLayer
var anchors: Array[Node2D] = []
var combo := 0
var max_combo := 0
var miss_streak := 0
var combo_last := 0.
var stop_until := 0.
var stop_gate := 0.
var stop_duration := 0.
var milestone_gate := 0.
var trauma := 0.
var punch := 0.
var shake_offset := Vector2.ZERO
var cosmetic_rng := RandomNumberGenerator.new()
var weapon_rng := RandomNumberGenerator.new()
var hurt_flash := 0.

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan24.gd") if legacy_feel else super._enemy_script()

func goose_script() -> Script:
	return preload("res://scripts/combat/goose24.gd")

func spawn_offsets() -> Array:
	return [Vector2(-4,-3),Vector2(0,-5),Vector2(4,-2)] if legacy_feel else super.spawn_offsets()

func attack_cooldown() -> float:
	return Profile.FIRE_CD if legacy_feel else super.attack_cooldown()

func projectile_damage() -> float:
	return Profile.DAMAGE if legacy_feel else super.projectile_damage()

func projectile_speed() -> float:
	return Profile.BULLET_SPEED if legacy_feel else super.projectile_speed()

func goose_recoil_strength() -> float:
	return Profile.RECOIL if legacy_feel else super.goose_recoil_strength()

func _ready() -> void:
	super._ready()
	while not is_instance_valid(reticle): await get_tree().physics_frame
	fx_layer = CanvasLayer.new()
	fx_layer.name = "LegacyCombatArt"
	fx_layer.layer = 2
	add_child(fx_layer)
	cosmetic_rng.seed = 240024
	weapon_rng.randomize()
	hero.legacy_motion_enabled = legacy_feel
	hero.motion_pixels_per_m = Profile.PPM
	Candy._load_art()
	_status()
	print("WORLD24_LEGACY_CHAIN_READY")

func anchor(at: Vector3,lifetime := .65) -> Node2D:
	for i in range(anchors.size()-1,-1,-1):
		if not is_instance_valid(anchors[i]): anchors.remove_at(i)
	if not is_instance_valid(fx_layer) or anchors.size()>=144: return null
	var node := preload("res://scripts/combat/legacy_canvas24.gd").new()
	node.battle = self
	node.at = at
	node.lifetime = lifetime
	fx_layer.add_child(node)
	anchors.append(node)
	node._process(0.)
	return node

func screen_direction(at: Vector3,direction: Vector3) -> Vector2:
	return (camera.unproject_position(at+direction)-camera.unproject_position(at)).normalized()

func emit_legacy_art(at: Vector3,direction: Vector3,kind: String,gain := 1.) -> void:
	var node := anchor(at)
	if node!=null:
		Candy.emit(node,Vector2.ZERO,screen_direction(at,direction),kind,0,gain)
		localize_art(node)

func localize_art(node: Node2D) -> void:
	for key in ["CandyBulletArt","HitMaterialFX"]:
		var renderer := node.get_node_or_null(key)
		if renderer!=null: renderer.local_coordinates = true

func weapon_spread_radians() -> float:
	return .025

func fire_at(destination: Vector3) -> void:
	if not legacy_feel:
		super.fire_at(destination)
		return
	if not destination.is_finite(): return
	var origin := projectile_origin()
	var vector := destination-origin
	if vector.length()<.05: return
	var spread := weapon_spread_radians()
	var scattered := vector.rotated(Vector3.UP,weapon_rng.randf_range(-spread,spread))
	var before := shots.size()
	super.fire_at(origin+scattered)
	if shots.size()==before: return
	var shot: Dictionary = shots[-1]
	shot.velocity = shot.velocity.normalized()*Profile.BULLET_SPEED
	shot.life = Profile.BULLET_LIFE
	shot.node.position += shot.velocity.normalized()*5./Profile.PPM
	shot.node.mesh = null
	var shadow: Variant = _bullet_shadow110(shot.node)
	if shadow.mesh==null:
		shadow.mesh=PlaneMesh.new()
	shadow.mesh.size = Vector2(.28,.18)
	if shadow.material_override==null:
		var soft := ShaderMaterial.new()
		soft.shader = preload("res://scripts/art/foot_contact16.gdshader")
		shadow.material_override = soft
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if shadow.get_parent()==null: shot.node.add_child(shadow)
	shot.shadow = shadow
	_update_bullet_shadow(shot)
	shot.trail_distance = 0.
	var art = _projectile_anchor24(shot.node.position)
	if art!=null:
		art.projectile = true
		art.follow = shot.node
		art.facing = screen_direction(shot.node.position,shot.velocity.normalized())
		if not art.get_meta("batched105",false) and not art.draw.is_connected(art._draw_bullet): art.draw.connect(art._draw_bullet)
		shot.art = art
	if _shot_sound_enabled110(): emit_legacy_art(origin,shot.velocity.normalized(),"muzzle")

func _projectile_anchor24(at: Vector3) -> Variant: return anchor(at)
func _bullet_shadow110(_node: Variant) -> Variant: return MeshInstance3D.new()
func _retire_projectile110(shot: Dictionary) -> void:
	shot.node.queue_free()
	if shot.has("art") and is_instance_valid(shot.art): shot.art.queue_free()

func _update_bullet_shadow(shot: Dictionary) -> void:
	var at: Vector3 = shot.node.position
	shot.shadow.global_position = Vector3(at.x,meadow.walk_height(Vector2(at.x,at.z),terrain_enabled)+.027,at.z)

func legacy_trace(start: Vector3,end: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(start,end,1|2|8 if not uses_planar_hits() else 1|2,[hero.get_rid()])
	query.collide_with_areas = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not uses_planar_hits(): return hit
	var closest := INF
	if not hit.is_empty(): closest=start.distance_to(hit.position)/maxf(.0001,start.distance_to(end))
	for enemy in enemies:
		if not is_instance_valid(enemy): continue
		if start.y<enemy.position.y-.1 or start.y>enemy.position.y+(1.7 if not enemy.dead else .86): continue
		var t: float = aim_model.sweep_circle(Vector2(start.x,start.z),Vector2(end.x,end.z),Vector2(enemy.position.x,enemy.position.z),.43 if enemy.dead else .65)
		if t<closest:
			closest=t
			hit={"collider":enemy.hit_area,"position":start.lerp(end,t)}
	return hit

func _step_shots(delta: float) -> void:
	if not legacy_feel:
		super._step_shots(delta)
		return
	for i in range(shots.size()-1,-1,-1):
		var shot: Dictionary = shots[i]
		var start: Vector3 = shot.node.position
		var end: Vector3 = start+shot.velocity*delta
		var hit := _trace_shot(shot,start,end)
		shot.life -= delta
		var distance := start.distance_to(end)
		shot.trail_distance += distance
		var emitted := 0
		while not shot.get("stream110",false) and shot.trail_distance>=4.5/Profile.PPM and emitted<6:
			var progress: float = 1.-(shot.trail_distance-4.5/Profile.PPM)/maxf(distance,.0001)
			emit_trail(start.lerp(end,clampf(progress,0.,1.)),shot.velocity.normalized())
			shot.trail_distance -= 4.5/Profile.PPM
			emitted += 1
		if not hit.is_empty():
			_apply_shot_hit(shot,hit)
		elif shot.life<=0.: _shot_expired(shot)
		if not hit.is_empty() or shot.life<=0.:
			_retire_projectile110(shot)
			shots.remove_at(i)
		else:
			shot.node.position = end
			_update_bullet_shadow(shot)
			if shot.has("art") and is_instance_valid(shot.art) and not shot.art.get_meta("batched105",false): shot.art.facing = screen_direction(end,shot.velocity.normalized())

func _trace_shot(_shot: Dictionary,start: Vector3,end: Vector3) -> Dictionary:
	return legacy_trace(start,end)

func _shot_expired(_shot: Dictionary) -> void:
	notify_miss()

func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
	var direction: Vector3=shot.velocity.normalized()
	if hit.collider.has_meta("enemy"):
		var enemy: CharacterBody3D=hit.collider.get_meta("enemy")
		if is_instance_valid(enemy):
			if enemy.dead:
				enemy.whip(direction)
				legacy_contact_art(hit.position,direction,false)
				Audio.play("hit"); notify_hit()
			else:
				enemy.impact_contact=hit.position
				enemy.receive_hit(damage_for_shot(shot),direction)
				landed_hits+=1
	else:
		blocks+=1
		legacy_contact_art(hit.position,-direction,false)
		Audio.play("crack"); notify_miss()

func emit_trail(at: Vector3,direction: Vector3) -> void:
	var node := anchor(at,.32)
	if node!=null:
		Candy.trail(node,Vector2.ZERO,screen_direction(at,direction),1.)
		localize_art(node)

func damage_for_shot(shot: Dictionary) -> float:
	return projectile_damage()*float(shot.get("damage_multiplier",1.))

func legacy_contact_art(at: Vector3,direction: Vector3,juice: bool,finishing := false) -> void:
	var node := anchor(at)
	if node==null: return
	var forward := screen_direction(at,direction)
	Candy.emit(node,Vector2.ZERO,forward,"impact",0)
	MaterialFX.break_sugar(node,Vector2.ZERO,forward,1.)
	if juice: MaterialFX.splash_juice(node,Vector2.ZERO,forward,finishing)
	localize_art(node)

func on_legacy_contact(enemy: CharacterBody3D,contact: Vector3,direction: Vector3,juice: bool) -> void:
	feedback_count += 1
	if is_instance_valid(feedback): feedback.marker = .13
	legacy_contact_art(contact,direction,juice,enemy.dead)
	Audio.play_tuantuan("down" if enemy.dead else "hit")
	notify_hit()

func notify_hit() -> void:
	combo += 1
	max_combo = maxi(combo,max_combo)
	miss_streak = 0
	combo_last = Time.get_ticks_msec()/1000.
	if combo in [10,20,30]:
		var now := Time.get_ticks_msec()/1000.
		if now>=milestone_gate:
			milestone_gate = now+.6
			var tier := int(combo/10)
			hitstop(.03+.015*tier,true)
			trauma = maxf(trauma,[0.,.3,.45,.65][tier])
	else: hitstop(.012)

func notify_miss() -> void:
	miss_streak += 1
	if miss_streak>=3: miss_streak=0; combo=0

func hitstop(duration: float,force := false) -> void:
	var now := Time.get_ticks_msec()/1000.
	if now<stop_gate and (not force or duration<=stop_duration): return
	stop_gate = now+duration+.12
	stop_duration = duration
	stop_until = maxf(stop_until,now+duration)
	Engine.time_scale = .05

func enemy_defeated(enemy: CharacterBody3D) -> void:
	super.enemy_defeated(enemy)
	if legacy_feel:
		hitstop(.04)
		trauma = minf(1.,trauma+.35)
		punch = .32

func hurt_player(damage: float,from: Vector2) -> void:
	var previous := player_hp
	super.hurt_player(damage,from)
	if legacy_feel and player_hp<previous:
		invulnerability = .8
		hero.combat_impulse = (Vector2(hero.position.x,hero.position.z)-from).normalized()*90./Profile.PPM
		combo = 0
		miss_streak = 0
		trauma = minf(1.,trauma+.3+damage/10.*.06)
		hitstop(.03,true)
		Audio.play("hurt")
		hurt_flash = .2

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if legacy_feel and combat_ready:
		hurt_flash = maxf(0.,hurt_flash-delta)
		hero.visual.modulate = Color(1.,.4,.45).lerp(Color.WHITE,1.-hurt_flash/.2) if hurt_flash>0. else Color.WHITE

func _advance_impact_time() -> void:
	if stop_until>0. and Time.get_ticks_msec()/1000.>=stop_until:
		stop_until = 0.
		Engine.time_scale = 1.

func _update_impact_camera(delta: float) -> void:
	if legacy_feel and combat_ready:
		trauma = maxf(0.,trauma-2.2*delta)
		var target := Vector2(cosmetic_rng.randf_range(-1,1),cosmetic_rng.randf_range(-1,1))*5.*trauma*trauma/Profile.PPM
		shake_offset = shake_offset.lerp(target,1.-pow(.55,delta*60.))
		camera.h_offset = shake_offset.x
		camera.v_offset = shake_offset.y
		punch = lerpf(punch,0.,minf(1.,9.*delta))
		camera.fov = rad_to_deg(2.*atan(tan(deg_to_rad(21.))/(1.+punch/3.)))
		if combo>0 and Time.get_ticks_msec()/1000.-combo_last>1.2: combo=0

func _process(delta: float) -> void:
	_advance_impact_time()
	_update_impact_camera(delta)
	super._process(delta)

func start_combat(reposition := true) -> void:
	_reset_impact_state()
	super.start_combat(reposition)
	cooldown = 0.
	combo = 0
	max_combo = 0
	miss_streak = 0
	hero.legacy_motion_enabled = legacy_feel
	hero.motion_pixels_per_m = Profile.PPM
	if is_instance_valid(goose):
		goose.attack_hold=0.; goose.attack_blend=0.; goose.visual_kick=0.; goose.kick_cd=0.
		goose.update_follow(0.,aim_at_screen(get_viewport().get_mouse_position()),true)
	for node in anchors:
		if is_instance_valid(node): node.queue_free()
	anchors.clear()

func _reset_impact_state() -> void:
	Engine.time_scale = 1.
	stop_until = 0.
	stop_gate = 0.
	stop_duration = 0.
	milestone_gate = 0.
	trauma = 0.
	punch = 0.
	shake_offset = Vector2.ZERO
	hurt_flash = 0.
	if is_instance_valid(camera): camera.h_offset=0.; camera.v_offset=0.; camera.fov=42.

func _exit_tree() -> void:
	Engine.time_scale = 1.
	if is_instance_valid(Audio._box):
		for player in Audio._box.players:
			player.stop()
			player.stream = null

func _status() -> void:
	super._status()
	if not world_ready: return
	label.text = label.text.replace("连续世界23","连续世界24")
	label.text += "\nF12 旧基础攻击链 / 23试验链 · 当前："+("旧版基础参数" if legacy_feel else "23版简化参数")
	if combat_ready and is_instance_valid(battle_label): battle_label.text += " · 连击 %d"%combo

func _unhandled_input(event: InputEvent) -> void:
	if combat_ready and event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_F12:
			legacy_feel = not legacy_feel
			start_combat()
			return
		if event.physical_keycode==KEY_F7 and not combat_paused: _reset_impact_state()
	super._unhandled_input(event)
