extends "res://scripts/world/world22.gd"
const AIM_CLEARANCE := .85
var goose: Node3D
var reticle: Node3D
var world_cursor := true
var body_hit_3d := true
var show_hit_bodies := false

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan23.gd")

func feedback_script() -> Script:
	return preload("res://scripts/combat/feedback23.gd")

func goose_script() -> Script:
	return preload("res://scripts/combat/goose23.gd")

func uses_planar_hits() -> bool:
	return planar_aim and not body_hit_3d

func _ready() -> void:
	super._ready()
	while not combat_ready or not is_instance_valid(feedback): await get_tree().physics_frame
	goose = goose_script().new()
	goose.battle = self
	add_child(goose)
	reticle = preload("res://scripts/combat/world_reticle23.gd").new()
	reticle.battle = self
	add_child(reticle)
	var target := aim_at_screen(get_viewport().get_mouse_position())
	goose.update_follow(0.,target,true)
	reticle.update_target(target)
	_status()
	print("WORLD23_GOOSE_RETICLE_READY")

func elevated_surface_point(point: Vector2) -> Vector3:
	var origin := camera.project_ray_origin(point)
	var ray := camera.project_ray_normal(point)
	var query := PhysicsRayQueryParameters3D.create(origin,origin+ray*300.,1)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty(): return Vector3.INF
	var lo := 0.
	var hi := origin.distance_to(hit.position)
	for i in 18:
		var t := (lo+hi)*.5
		var at := origin+ray*t
		var floor_y: float = meadow.walk_height(Vector2(at.x,at.z),terrain_enabled)
		if at.y>floor_y+AIM_CLEARANCE: lo=t
		else: hi=t
	return origin+ray*(lo+hi)*.5

func aim_at_screen(point: Vector2) -> Vector3:
	if not planar_aim: return super.aim_at_screen(point)
	var at := elevated_surface_point(point)
	if gentle_assist:
		var selected := enemy_under_cursor(point)
		if is_instance_valid(selected):
			var lead := minf(.14,projectile_origin().distance_to(selected.position)/projectile_speed())
			at = selected.position+Vector3(selected.velocity.x,0,selected.velocity.z)*lead
			at.y = meadow.walk_height(Vector2(at.x,at.z),terrain_enabled)+AIM_CLEARANCE
	return at

func projectile_origin() -> Vector3:
	return goose.muzzle() if is_instance_valid(goose) else super.projectile_origin()

func goose_recoil_strength() -> float:
	return .97

func _shot_recoil_enabled110() -> bool: return true
func fire_at(destination: Vector3) -> void:
	if not is_instance_valid(goose): return
	var before := fired_count
	super.fire_at(destination)
	if fired_count>before and _shot_recoil_enabled110(): goose.recoil(shots[-1].velocity)

func _physics_process(delta: float) -> void:
	if combat_ready and is_instance_valid(goose):
		goose.update_follow(delta,aim_at_screen(get_viewport().get_mouse_position()))
	super._physics_process(delta)

func _process(delta: float) -> void:
	super._process(delta)
	if combat_ready and is_instance_valid(reticle):
		reticle.update_target(aim_at_screen(get_viewport().get_mouse_position()))

func _travel_region(key: String) -> void:
	super._travel_region(key)
	if is_instance_valid(goose): goose.update_follow(0.,aim_at_screen(get_viewport().get_mouse_position()),true)

func _status() -> void:
	super._status()
	if not world_ready: return
	label.text = label.text.replace("连续世界22","连续世界23")
	var cursor_name := "世界悬浮准星＋地影" if world_cursor else "屏幕准星对照"
	var hit_name := "三维受击胶囊" if body_hit_3d else "平面容错对照"
	label.text = label.text.get_slice("\n",0)+"\n小黑鹅射击 · 左键连射 · F5 重开 · F7 暂停 · 滚轮缩放\n"+cursor_name+" · Q 切准星 · F9 轻辅助 · F10 看受击体\n"+hit_name+" · F11 切判定 · 1 小院 / 2 世界树 / 3 林地 · Tab 地图"

func _unhandled_input(event: InputEvent) -> void:
	if combat_ready and event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_Q: world_cursor = not world_cursor; _status(); return
			KEY_F10:
				show_hit_bodies = not show_hit_bodies
				for enemy in enemies:
					if is_instance_valid(enemy): enemy.debug_body.visible = show_hit_bodies and not enemy.dead
				return
			KEY_F11:
				body_hit_3d = not body_hit_3d
				_clear_combat_shots()
				_status()
				return
	super._unhandled_input(event)
