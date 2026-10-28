extends "res://scripts/combat/hero34.gd"
const WALK_KEYS := {
	KEY_W: Vector2.UP, KEY_UP: Vector2.UP,
	KEY_S: Vector2.DOWN, KEY_DOWN: Vector2.DOWN,
	KEY_A: Vector2.LEFT, KEY_LEFT: Vector2.LEFT,
	KEY_D: Vector2.RIGHT, KEY_RIGHT: Vector2.RIGHT,
}
var walk_key_order: Array[int]=[]

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or event.echo: return
	var key: int=event.physical_keycode
	if not WALK_KEYS.has(key): return
	walk_key_order.erase(key)
	if event.pressed and controls_enabled and not battle.combat_paused:
		walk_key_order.append(key)

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_WINDOW_FOCUS_OUT: walk_key_order.clear()

func _walk_facing(direction: Vector2) -> void:
	if direction==Vector2.ZERO: return
	var chosen := direction
	for i in range(walk_key_order.size()-1,-1,-1):
		var candidate: Vector2=WALK_KEYS[walk_key_order[i]]
		# Opposing keys cancel movement and should not steal the remaining axis.
		if candidate.dot(direction)>0.:
			chosen=candidate
			break
	if absf(chosen.x)>absf(chosen.y): facing="right" if chosen.x>0. else "left"
	else: facing="down" if chosen.y>0. else "up"

func render_pose() -> void:
	if dash_left<=0. and not knocked_down and not story_knocked:
		_walk_facing(movement_input())
	super.render_pose()

func request_dash(direction := Vector2.ZERO) -> bool:
	# Capture the current last-pressed facing once. Inputs during a dash must
	# not flip its authored animation halfway through the movement.
	if direction==Vector2.ZERO and dash_left<=0.: _walk_facing(movement_input())
	return super.request_dash(direction)

func request_parry() -> bool:
	if dash_left<=0.: _walk_facing(movement_input())
	return super.request_parry()

func reset_actions() -> void:
	super.reset_actions()
	walk_key_order.clear()
