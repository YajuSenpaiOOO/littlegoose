extends "res://scripts/world/world21.gd"
## Same camera, planar combat. Visual hopping is not a second aim requirement.
const Audio = preload("res://scripts/combat/combat_sfx22.gd")
var aim_model = preload("res://scripts/combat/aim_model22.gd").new()
var planar_aim := true
var gentle_assist := true
var hover_enemy: CharacterBody3D
var feedback: Control
var feedback_count := 0

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan22.gd")

func _ready() -> void:
	super._ready()
	while not combat_ready: await get_tree().physics_frame
	Audio.attach(get_tree())
	feedback = feedback_script().new()
	feedback.battle = self
	feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	battle_label.get_parent().add_child(feedback)
	crosshair.hide()
	print("WORLD22_AIM_READY")

func feedback_script() -> Script:
	return preload("res://scripts/combat/combat_feedback22.gd")

func uses_planar_hits() -> bool:
	return planar_aim

func projectile_speed() -> float:
	return 38.

func enemy_under_cursor(point: Vector2) -> CharacterBody3D:
	var selected: CharacterBody3D
	var nearest := INF
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.dead or camera.is_position_behind(enemy.position): continue
		if not aim_model.sprite_contains(camera,point,enemy.visual): continue
		var distance: float = camera.position.distance_squared_to(enemy.position)
		if distance<nearest: selected=enemy; nearest=distance
	return selected

func aim_at_screen(point: Vector2) -> Vector3:
	if not planar_aim: return super.aim_at_screen(point)
	var height := hero.position.y+.85
	var at: Vector3 = aim_model.plane_point(camera,point,height)
	if gentle_assist:
		var selected := enemy_under_cursor(point)
		if is_instance_valid(selected):
			# At most 0.14s of lead, only while the cursor covers visible enemy pixels.
			var lead := minf(.14,hero.position.distance_to(selected.position)/projectile_speed())
			at = selected.position+Vector3(selected.velocity.x,0,selected.velocity.z)*lead
			at.y = height
	return at

func _shot_sound_enabled110() -> bool: return true
func fire_at(destination: Vector3) -> void:
	var old_count := fired_count
	super.fire_at(destination)
	if fired_count==old_count: return
	if _shot_sound_enabled110(): Audio.play("shoot")
	if not planar_aim: return
	var shot: Dictionary = shots[-1]
	shot.velocity = shot.velocity.normalized()*projectile_speed()
	shot.life = 1.4
	if _projectile_mesh_enabled24():
		var mesh := CapsuleMesh.new()
		mesh.radius = .055
		mesh.height = .42
		mesh.radial_segments = 6
		mesh.rings = 1
		shot.node.mesh = mesh
		shot.node.basis = Basis(Quaternion(Vector3.UP,shot.velocity.normalized()))
	shot.node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _step_shots(delta: float) -> void:
	if not uses_planar_hits():
		super._step_shots(delta)
		return
	for i in range(shots.size()-1,-1,-1):
		var shot: Dictionary = shots[i]
		var start: Vector3 = shot.node.position
		var end: Vector3 = start+shot.velocity*delta
		var query := PhysicsRayQueryParameters3D.create(start,end,1|2)
		var obstruction := get_world_3d().direct_space_state.intersect_ray(query)
		var first_t := INF
		if not obstruction.is_empty(): first_t = start.distance_to(obstruction.position)/maxf(.0001,start.distance_to(end))
		var victim: CharacterBody3D
		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy.dead: continue
			if start.y<enemy.position.y-.1 or start.y>enemy.position.y+1.7: continue
			var t: float = aim_model.sweep_circle(Vector2(start.x,start.z),Vector2(end.x,end.z),Vector2(enemy.position.x,enemy.position.z),.65)
			if t<first_t: victim=enemy; first_t=t
		shot.life -= delta
		if first_t<INF:
			if is_instance_valid(victim):
				victim.receive_hit(projectile_damage(),shot.velocity.normalized())
				landed_hits += 1
			else: blocks += 1
		if first_t<INF or shot.life<=0.:
			shot.node.queue_free()
			shots.remove_at(i)
		else: shot.node.position = end

func on_combat_impact(enemy: CharacterBody3D,_damage: float) -> void:
	feedback_count += 1
	if is_instance_valid(feedback): feedback.impact(enemy.position+Vector3.UP*(.65+enemy.visual.position.y),enemy.dead)
	Audio.play_tuantuan("down" if enemy.dead else "hit")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if combat_ready: hover_enemy = enemy_under_cursor(get_viewport().get_mouse_position())

func start_combat(reposition := true) -> void:
	super.start_combat(reposition)
	feedback_count = 0
	if is_instance_valid(feedback): feedback.bursts.clear(); feedback.marker=0.

func _status() -> void:
	super._status()
	if not world_ready: return
	label.text = label.text.replace("连续世界21","连续世界22")
	var mode := "平面瞄准＋轻辅助" if planar_aim and gentle_assist else "平面自由瞄准" if planar_aim else "原21三维瞄准"
	label.text = label.text.replace("本轮：普通团团怪追逐、命中击退、接触伤害；高差方案暂存",mode+" · F8 新旧对照 · F9 辅助开关 · 25°镜头保持")

func _unhandled_input(event: InputEvent) -> void:
	if combat_ready and event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_F8:
			planar_aim = not planar_aim
			_clear_combat_shots()
			_status()
			return
		if event.physical_keycode==KEY_F9:
			gentle_assist = not gentle_assist
			_status()
			return
	super._unhandled_input(event)
