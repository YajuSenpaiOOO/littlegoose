extends "res://scripts/world/world35.gd"

func _ready() -> void:
	super._ready()
	while not parry_ready: await get_tree().physics_frame
	_title35()
	print("WORLD36_TAKEOFF_TARGET_READY")

func _hero_script() -> Script: return preload("res://scripts/combat/hero36.gd")
func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan36.gd") if legacy_feel else super._enemy_script()

func _title35() -> void:
	DisplayServer.window_set_title("小白鹅 · 扑跳36 · 起跳锁定 · PageDown 小闪光 "+("开" if small_attack_cue else "关"))

func _status() -> void:
	super._status()
	if world_ready: label.text=label.text.replace("连续世界35","连续世界36")
