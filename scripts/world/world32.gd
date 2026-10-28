extends "res://scripts/world/world31.gd"
var enhanced_feedback := true
var elastic_ready := false

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan32.gd") if legacy_feel else super._enemy_script()

func _material_fx_script() -> Script:
	return preload("res://scripts/combat/sugar_fx32.gd")

func _ready() -> void:
	super._ready()
	while not material_ready: await get_tree().physics_frame
	elastic_ready=true
	_update_title32()
	print("WORLD32_ELASTIC_READY")

func sugar_contact(contact: Vector3,direction: Vector3) -> void:
	if cup_contact_active: return # A goose touch does not break a nonexistent bullet.
	if not enhanced_feedback or not is_instance_valid(jelly_fx):
		super.sugar_contact(contact,direction)
		return
	jelly_fx.break_sugar(contact,direction)

func legacy_contact_art(at: Vector3,direction: Vector3,juice: bool,finishing := false) -> void:
	if not enhanced_feedback or not material_feedback or not is_instance_valid(jelly_fx):
		super.legacy_contact_art(at,direction,juice,finishing)
		return
	var node := anchor(at,.2)
	if node!=null:
		Candy.emit(node,Vector2.ZERO,screen_direction(at,direction),"impact",0)
		localize_art(node)
	sugar_contact(at,direction)
	if juice: jelly_fx.burst(at,direction,finishing)

func _update_title32() -> void:
	DisplayServer.window_set_title("小白鹅 · 碎糖与软体32 · "+("旧反馈" if not material_feedback else ("32新版" if enhanced_feedback else "31版对照"))+" · Home 对照")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_HOME:
		enhanced_feedback=not enhanced_feedback
		start_combat()
		_update_title32()
		return
	super._unhandled_input(event)
	if event is InputEventKey and event.pressed and event.physical_keycode==KEY_INSERT: _update_title32()

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界31","连续世界32")
		var hint := "\nHome 碎糖落地＋局部软体 / 31版对照"
		if not label.text.contains(hint): label.text+=hint
