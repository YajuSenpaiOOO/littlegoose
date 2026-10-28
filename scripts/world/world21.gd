extends "res://scripts/world/world20.gd"
## Flat-woodland combat trial. Exploration art and previous auditions stay available.
var combat_ready := false
var combat_paused := false
var navigation = preload("res://scripts/combat/woodland_navigation21.gd").new()
var enemies: Array[CharacterBody3D] = []
var combat_poses: Dictionary = {}
var combat_textures: Dictionary = {}
var player_hp := 100.
var invulnerability := 0.
var wave_state := "waiting"
var defeated_count := 0
var total_enemies := 6
var fired_count := 0
var landed_hits := 0
var hurt_count := 0
var battle_label: Label
var health_track: ColorRect
var health_value: ColorRect

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow = preload("res://scripts/world/world_surface21.gd").new()

func _build_stairs() -> void:
	pass

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	for material in ground_materials: material.shader = preload("res://scripts/art/world_ground19.gdshader")

func _ready() -> void:
	super._ready()
	hero.combat_enabled = true
	combat_poses = JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_v2/motion_v1.json"))
	for key in combat_poses: combat_textures[key] = load(combat_poses[key].texture)
	_build_battle_hud()
	# Let the world enter the physics server before sampling tree collisions.
	await get_tree().physics_frame
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	combat_ready = true
	if "--combat" in OS.get_cmdline_user_args(): start_combat()
	_status()
	print("WORLD21_COMBAT_READY")

func _build_battle_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "CombatHUD"
	add_child(layer)
	health_track = ColorRect.new()
	health_track.position = Vector2(24,22)
	health_track.size = Vector2(220,13)
	health_track.color = Color("2b392d")
	health_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(health_track)
	health_value = ColorRect.new()
	health_value.size = health_track.size
	health_value.color = Color("a3bd76")
	health_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_track.add_child(health_value)
	battle_label = Label.new()
	battle_label.position = Vector2(24,43)
	battle_label.add_theme_font_size_override("font_size",20)
	battle_label.add_theme_color_override("font_shadow_color",Color("18231c"))
	battle_label.add_theme_constant_override("shadow_offset_x",2)
	battle_label.add_theme_constant_override("shadow_offset_y",2)
	layer.add_child(battle_label)

func start_combat(reposition := true) -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			remove_child(enemy)
			enemy.queue_free()
	enemies.clear()
	_clear_combat_shots()
	player_hp = 100.
	invulnerability = .8
	defeated_count = 0
	fired_count = 0
	landed_hits = 0
	hurt_count = 0
	wave_state = "fighting"
	combat_paused = false
	hero.controls_enabled = true
	hero.combat_impulse = Vector2.ZERO
	hero.locomotion = Vector2.ZERO
	hero.velocity = Vector3.ZERO
	hero.visual.modulate = Color.WHITE
	var center: Vector2 = meadow.landmarks.grove
	if reposition: _teleport15(center+Vector2(0,5.5))
	var positions := spawn_offsets()
	total_enemies = positions.size()
	for i in positions.size():
		var enemy = _enemy_script().new()
		enemy.name = "Tuantuan%02d"%i
		enemy.battle = self
		enemy.poses = combat_poses
		enemy.textures = combat_textures
		enemy.home = center
		enemy.rest = .15+float(i)*.07
		var cell: Vector2i = navigation.nearest(center+positions[i])
		var at: Vector2 = navigation.origin+Vector2(cell)*navigation.CELL
		enemy.position = Vector3(at.x,meadow.walk_height(at,true)+.06,at.y)
		add_child(enemy)
		enemy.reset_physics_interpolation()
		enemies.append(enemy)
	_status()

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan21.gd")

func spawn_offsets() -> Array:
	return [Vector2(-6,-2),Vector2(-3,-5),Vector2(0,-5),Vector2(3,-4),Vector2(6,-2),Vector2(4,2)]

func attack_cooldown() -> float:
	return .18

func projectile_damage() -> float:
	return 4.

func _clear_combat_shots() -> void:
	for shot in shots:
		if is_instance_valid(shot.node): shot.node.queue_free()
	shots.clear()

func enemy_defeated(_enemy: CharacterBody3D) -> void:
	defeated_count += 1
	if defeated_count>=total_enemies: wave_state = "cleared"

func hurt_player(damage: float,from: Vector2) -> void:
	if player_hp<=0. or invulnerability>0. or combat_paused or wave_state!="fighting": return
	player_hp = maxf(0.,player_hp-damage)
	hurt_count += 1
	invulnerability = .85
	var away := (Vector2(hero.position.x,hero.position.z)-from).normalized()
	if away.length_squared()<.01: away = Vector2.DOWN
	hero.combat_impulse = away*6.
	if player_hp<=0.:
		wave_state = "defeated"
		hero.controls_enabled = false
		hero.locomotion = Vector2.ZERO
		_clear_combat_shots()

func aim_at_screen(point: Vector2) -> Vector3:
	var start := camera.project_ray_origin(point)
	var query := PhysicsRayQueryParameters3D.create(start,start+camera.project_ray_normal(point)*200.,1|2|8)
	query.collide_with_areas = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty(): return Vector3.INF
	var at: Vector3 = hit.position
	if hit.collider is StaticBody3D and hit.collider.collision_layer==1:
		at.y += .65
	return at

func fire_at(destination: Vector3) -> void:
	if not combat_ready or combat_paused or player_hp<=0. or not destination.is_finite(): return
	var previous := shots.size()
	super.fire_at(destination)
	if shots.size()>previous: fired_count += 1

func _step_shots(delta: float) -> void:
	for i in range(shots.size()-1,-1,-1):
		var shot: Dictionary = shots[i]
		var start: Vector3 = shot.node.position
		var end: Vector3 = start+shot.velocity*delta
		var query := PhysicsRayQueryParameters3D.create(start,end,1|2|8,[hero.get_rid()])
		query.collide_with_areas = true
		var hit := get_world_3d().direct_space_state.intersect_ray(query)
		shot.life -= delta
		if not hit.is_empty():
			if hit.collider.has_meta("enemy"):
				var enemy: CharacterBody3D = hit.collider.get_meta("enemy")
				if is_instance_valid(enemy) and not enemy.dead:
					enemy.receive_hit(projectile_damage(),shot.velocity.normalized())
					landed_hits += 1
			else: blocks += 1
		if not hit.is_empty() or shot.life<=0.:
			shot.node.queue_free()
			shots.remove_at(i)
		else: shot.node.position = end

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not combat_ready or combat_paused: return
	invulnerability = maxf(0.,invulnerability-delta)
	hero.visual.modulate = Color(1.4,.7,.7) if invulnerability>.12 and wave_state=="fighting" else Color.WHITE
	if wave_state=="waiting" and Vector2(hero.position.x,hero.position.z).distance_to(meadow.landmarks.grove)<9.:
		start_combat(false)
	cooldown = maxf(0.,cooldown-delta)
	_step_fire_input(delta)
	_step_shots(delta)
	if is_instance_valid(crosshair): crosshair.queue_redraw()

func fire_input_held() -> bool:
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func _step_fire_input(_delta: float) -> void:
	if player_hp>0. and fire_input_held() and cooldown<=0.:
		fire_at(aim_at_screen(get_viewport().get_mouse_position()))
		cooldown=attack_cooldown()

func _travel_region(key: String) -> void:
	if key=="steps": key = "grove"
	super._travel_region(key)
	if combat_ready:
		hero.combat_impulse = Vector2.ZERO
		hero.locomotion = Vector2.ZERO
		_clear_combat_shots()

func _status() -> void:
	super._status()
	if not world_ready: return
	label.text = "连续世界21 · 平地战斗试验 · WASD / Shift 移动 · 滚轮缩放\n鼠标左键按住射击 · F5 开始 / 重开 · F7 暂停怪物与弹丸\n1 小院 / 2 世界树 / 3 原林地 · 4 湖岸 / 5 车站 / 6 码头 · Tab 地图\n本轮：普通团团怪追逐、命中击退、接触伤害；高差方案暂存"
	if not combat_ready or not is_instance_valid(battle_label): return
	health_value.size.x = health_track.size.x*player_hp/100.
	var state_text: String = {"waiting":"走进林地触发试战，或按 F5","fighting":"林地试战","cleared":"本轮清完了 · F5 再来一轮","defeated":"本轮倒下了 · F5 重开"}[wave_state]
	if combat_paused: state_text = "战斗已暂停 · F7 继续"
	battle_label.text = "生命 %d / 100 · %s\n团团怪 %d / %d · 命中 %d"%[player_hp,state_text,defeated_count,total_enemies,landed_hits]

func _unhandled_input(event: InputEvent) -> void:
	if combat_ready and event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_F5: start_combat(); return
			KEY_F7: combat_paused = not combat_paused; _status(); return
			KEY_F6: _travel_region("grove"); return
	super._unhandled_input(event)
