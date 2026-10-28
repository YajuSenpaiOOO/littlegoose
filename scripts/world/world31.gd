extends "res://scripts/world/world30.gd"
var material_feedback := true
var material_ready := false
var jelly_fx: Node3D
var directional_kick := Vector2.ZERO
var kick_left := 0.

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan31.gd") if legacy_feel else super._enemy_script()

func _material_fx_script() -> Script:
	return preload("res://scripts/combat/jelly_fx31.gd")

func _ready() -> void:
	super._ready()
	while not feel_ready: await get_tree().physics_frame
	jelly_fx=_material_fx_script().new()
	jelly_fx.battle=self
	add_child(jelly_fx)
	ordinary_hitstop=false
	material_ready=true
	DisplayServer.window_set_title("小白鹅 · 果冻反馈31 · Insert 新旧对照")
	print("WORLD31_MATERIAL_READY")

func on_legacy_contact(enemy: CharacterBody3D,contact: Vector3,direction: Vector3,juice: bool) -> void:
	if not material_feedback or not is_instance_valid(jelly_fx):
		super.on_legacy_contact(enemy,contact,direction,juice)
		return
	feedback_count+=1
	if is_instance_valid(feedback): feedback.marker=.13
	# Shared candy shell + a distinct body response. No old flat overlay juice.
	sugar_contact(contact,direction)
	jelly_fx.play_contact(contact,enemy.dead)
	if juice: jelly_fx.burst(contact,direction,enemy.dead)
	# A short body-attached contact accent follows recoil, ejected matter does not.
	var node := anchor(contact,.09)
	if node!=null:
		var offset: Vector3=enemy.visual.to_local(contact)
		node.set_meta("body",weakref(enemy.visual))
		node.set_meta("offset",offset)
		Candy.emit(node,Vector2.ZERO,screen_direction(contact,direction),"impact",0,1.5)
		localize_art(node)
	if not cup_contact_active: notify_hit()
	if enemy.dead or (not cup_contact_active and combo in [10,20,30]):
		directional_kick=screen_direction(contact,direction)*.035
		kick_left=.14

func sugar_contact(contact: Vector3,direction: Vector3) -> void:
	var fragments := anchor(contact,.4)
	if fragments!=null:
		MaterialFX.break_sugar(fragments,Vector2.ZERO,screen_direction(contact,direction),1.)
		localize_art(fragments)

func _update_impact_camera(delta: float) -> void:
	super._update_impact_camera(delta)
	if not material_feedback: return
	kick_left=maxf(0.,kick_left-delta)
	var beat := sin((1.-kick_left/.14)*PI)*kick_left/.14 if kick_left>0. else 0.
	camera.h_offset+=directional_kick.x*beat
	camera.v_offset+=-directional_kick.y*beat

func _process(delta: float) -> void:
	super._process(delta)
	if not material_ready: return
	for node in anchors:
		if not is_instance_valid(node) or not node.has_meta("body"): continue
		var body: Node3D=node.get_meta("body").get_ref()
		if is_instance_valid(body): node.at=body.to_global(node.get_meta("offset"))

func _reset_impact_state() -> void:
	super._reset_impact_state()
	kick_left=0.; directional_kick=Vector2.ZERO
	if is_instance_valid(jelly_fx): jelly_fx.clear()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_INSERT:
		material_feedback=not material_feedback
		ordinary_hitstop=not material_feedback
		start_combat()
		DisplayServer.window_set_title("小白鹅 · 果冻反馈31 · "+("新反馈" if material_feedback else "旧反馈")+" · Insert 对照")
		return
	super._unhandled_input(event)

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界30","连续世界31")
		var hint := "\nInsert 果冻反馈 / 旧反馈对照 · X 普通全局微顿"
		if not label.text.contains(hint): label.text+=hint
