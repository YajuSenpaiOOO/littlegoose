extends "res://scripts/world/world28.gd"
var cup_phone_enabled := true
var cup_contact_active := false
var cup_contact_hits := 0
var guide_overlay: Node2D
var cup_label: Label
var cup_chip: PanelContainer
var debug_hud := false

func goose_script() -> Script:
	return preload("res://scripts/combat/goose29.gd")

func _ready() -> void:
	super._ready()
	while not is_instance_valid(reticle) or reticle.get_script()!=preload("res://scripts/combat/muzzle_reticle28.gd"): await get_tree().physics_frame
	var previous: Node3D=reticle
	remove_child(previous)
	previous.queue_free()
	reticle=preload("res://scripts/combat/muzzle_reticle29.gd").new()
	reticle.battle=self
	add_child(reticle)
	var layer := CanvasLayer.new()
	layer.layer=0
	add_child(layer)
	guide_overlay=preload("res://scripts/combat/guide_ink29.gd").new()
	guide_overlay.battle=self
	guide_overlay.source=reticle
	layer.add_child(guide_overlay)
	_build_cup_chip()
	set_cup_phone(cup_phone_enabled)
	_set_debug_hud(false)
	print("WORLD29_CUP_PHONE_READY")

func _build_cup_chip() -> void:
	cup_chip=PanelContainer.new()
	cup_chip.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var ink := StyleBoxFlat.new()
	ink.bg_color=Color(.07,.10,.085,.72)
	ink.border_color=Color(.91,.85,.66,.18)
	ink.set_border_width_all(1)
	ink.set_corner_radius_all(7)
	ink.content_margin_left=13.; ink.content_margin_right=13.
	ink.content_margin_top=9.; ink.content_margin_bottom=9.
	cup_chip.add_theme_stylebox_override("panel",ink)
	label.get_parent().add_child(cup_chip)
	cup_label=Label.new()
	cup_label.add_theme_font_size_override("font_size",16)
	cup_label.add_theme_color_override("font_color",Color(.96,.91,.77))
	cup_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	cup_chip.add_child(cup_label)

func _set_debug_hud(enabled: bool) -> void:
	debug_hud=enabled
	label.visible=enabled
	label.get_parent().get_child(0).visible=enabled
	if is_instance_valid(perf_label): perf_label.visible=enabled

func set_cup_phone(enabled: bool) -> void:
	cup_phone_enabled=enabled
	if is_instance_valid(goose):
		goose.cup_phone=enabled
		goose.clear_contact_state()
	if is_instance_valid(cup_label):
		cup_label.text=("纸杯电话 · 自由飞行" if enabled else "小黑鹅 · 贴身跟随")+"\nBackspace 切换 · E 辅助 · F1 说明"

func start_combat(reposition := true) -> void:
	super.start_combat(reposition)
	cup_contact_hits=0
	if is_instance_valid(goose):
		goose.cup_phone=cup_phone_enabled
		goose.clear_contact_state()

func resolved_fire_target(target: Vector3,origin: Vector3) -> Vector3:
	return goose.resolve_target(target,origin) if is_instance_valid(goose) else target

func fire_at(target: Vector3) -> void:
	super.fire_at(resolved_fire_target(target,projectile_origin()))

func legacy_trace(start: Vector3,end: Vector3) -> Dictionary:
	if uses_planar_hits(): return super.legacy_trace(start,end)
	var query := PhysicsRayQueryParameters3D.create(start,end,1|2|8,[hero.get_rid()])
	query.collide_with_areas=true
	query.hit_from_inside=true
	return get_world_3d().direct_space_state.intersect_ray(query)

func cup_contact_enemy(enemy: CharacterBody3D,direction: Vector3) -> void:
	if combat_paused or wave_state!="fighting" or player_hp<=0. or enemy.dead: return
	cup_contact_active=true
	cup_contact_hits+=1
	enemy.impact_contact=goose.muzzle()
	enemy.receive_hit(.5*projectile_damage(),direction)
	cup_contact_active=false

func on_legacy_contact(enemy: CharacterBody3D,contact: Vector3,direction: Vector3,juice: bool) -> void:
	if not cup_contact_active:
		super.on_legacy_contact(enemy,contact,direction,juice)
		return
	# Legacy telephone touch is not a projectile hit: no combo or sugar split.
	feedback_count+=1
	emit_legacy_art(contact,direction,"impact",.55)
	Audio.play_tuantuan("down" if enemy.dead else "hit")

func _process(delta: float) -> void:
	super._process(delta)
	if is_instance_valid(cup_chip):
		cup_chip.position=Vector2(get_viewport().get_visible_rect().size.x-cup_chip.size.x-20.,20.)

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界28","连续世界29")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_BACKSPACE:
			set_cup_phone(not cup_phone_enabled)
			return
		if event.physical_keycode==KEY_F1:
			_set_debug_hud(not debug_hud)
			return
	super._unhandled_input(event)
