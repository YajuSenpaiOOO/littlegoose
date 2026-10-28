extends "res://scripts/world/world34.gd"
var small_attack_cue := true

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan35.gd") if legacy_feel else super._enemy_script()

func _ready() -> void:
	super._ready()
	while not parry_ready: await get_tree().physics_frame
	_title35()
	print("WORLD35_READABLE_RECOVERY_READY")

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 读招35 · 右键弹反 · PageDown 小闪光 "+("开" if small_attack_cue else "关"))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_PAGEDOWN:
		small_attack_cue=not small_attack_cue
		_title35()
		return
	super._unhandled_input(event)
	if event is InputEventKey and event.pressed and event.physical_keycode in [KEY_DELETE,KEY_END,KEY_HOME,KEY_INSERT]: _title35()

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界34","连续世界35").replace("动作读招默认无箭头","PageDown 起跳小闪光")
