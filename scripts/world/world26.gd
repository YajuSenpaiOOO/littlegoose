extends "res://scripts/world/world25.gd"
## Keep the familiar world and weapon; compare cursor/body mapping explicitly.
var direct_body_aim := true

func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
	super._add_actor_shadow(actor,sprite)
	# The new silhouette replaces, rather than overlays, the old ellipse.
	if actor==hero:
		hero_contact.hide()
	else:
		var contact: MeshInstance3D = actor.get("shadow")
		if is_instance_valid(contact): contact.hide()

func accepts_cursor_enemy(enemy: CharacterBody3D) -> bool:
	return not enemy.dead

func aim_at_screen(point: Vector2) -> Vector3:
	if not direct_body_aim or not planar_aim or not body_hit_3d:
		return super.aim_at_screen(point)
	var origin := camera.project_ray_origin(point)
	var direction := camera.project_ray_normal(point)
	# Honor physical occluders. Target lies on the cursor ray, without snapping
	# to an enemy center or adding automatic movement prediction.
	var query := PhysicsRayQueryParameters3D.create(origin,origin+direction*250.,2|8,[hero.get_rid()])
	query.collide_with_areas = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.collider.has_meta("enemy"):
		var enemy: CharacterBody3D = hit.collider.get_meta("enemy")
		if is_instance_valid(enemy) and accepts_cursor_enemy(enemy) and aim_model.sprite_contains(camera,point,enemy.visual):
			# Move slightly inside the body to avoid ending on its surface.
			return hit.position+direction*.035
	# Empty space retains an explicit floor-relative shooting height.
	return elevated_surface_point(point)

func _update_bullet_shadow(shot: Dictionary) -> void:
	if not shot.has("shadow"): return
	var at: Vector3 = shot.node.position
	var direction: Vector3 = -sun.global_basis.z.normalized()
	var projected := at
	for i in 3:
		var height := floor_height(Vector2(projected.x,projected.z))
		projected = at+direction*((height-at.y)/direction.y)
	var shadow: MeshInstance3D = shot.shadow
	if not shadow.has_meta("projected26"):
		var ink := ShaderMaterial.new()
		ink.shader = preload("res://scripts/art/bullet_shadow26.gdshader")
		shadow.material_override = ink
		shadow.set_meta("projected26",true)
	_fit_contact(shadow,projected,.033)
	var lift := maxf(0.,at.y-floor_height(Vector2(at.x,at.z)))
	shadow.material_override.set_shader_parameter("opacity",clampf(.50-lift*.07,.23,.5))

func _process(delta: float) -> void:
	super._process(delta)
	if is_instance_valid(perf_label):
		var caption := " · F6 指向身体" if direct_body_aim else " · F6 旧辅助"
		# Parent refreshes at 0.4-second intervals; avoid re-shaping every frame.
		if not perf_label.text.contains(caption):
			perf_label.text = perf_label.text.get_slice(" · F6",0)+caption

func _status() -> void:
	super._status()
	if world_ready:
		label.text = label.text.replace("连续世界25","连续世界26").replace("F9 轻辅助","F9 旧模式辅助")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6:
		direct_body_aim = not direct_body_aim
		_clear_combat_shots()
		return
	super._unhandled_input(event)
