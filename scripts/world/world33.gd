extends "res://scripts/world/world32.gd"
var tactical_combat := true
var combat_clock33 := 0.
var next_attack33 := 0.
var encounter_ready := false

func _enemy_script() -> Script:
	return preload("res://scripts/combat/tuantuan33.gd") if legacy_feel else super._enemy_script()

func _material_fx_script() -> Script:
	return preload("res://scripts/combat/material_fx33.gd")

func _ready() -> void:
	super._ready()
	while not elastic_ready: await get_tree().physics_frame
	encounter_ready=true
	_title33()
	print("WORLD33_ENCOUNTER_READY")

func reserve_attack(_enemy: CharacterBody3D) -> bool:
	if combat_clock33<next_attack33: return false
	var busy := 0
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.dead and enemy.attack_phase in ["windup","lunge"]: busy+=1
	if busy>=2: return false
	next_attack33=combat_clock33+.55
	return true

func can_perfect_dodge(enemy: CharacterBody3D) -> bool:
	return not legacy_feel or not tactical_combat or enemy.attack_phase=="lunge" or (enemy.attack_phase=="windup" and enemy.phase_clock>=enemy.WINDUP-.12)

func _physics_process(delta: float) -> void:
	if not combat_paused: combat_clock33+=delta
	super._physics_process(delta)

func _reset_impact_state() -> void:
	super._reset_impact_state()
	combat_clock33=0.; next_attack33=0.

func _title33() -> void:
	DisplayServer.window_set_title("小白鹅 · 团团怪进攻33 · "+("蓄力扑跳" if tactical_combat else "旧追逐对照")+" · End 对照")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_END:
		tactical_combat=not tactical_combat
		start_combat(); _title33()
		return
	super._unhandled_input(event)
	if event is InputEventKey and event.pressed and event.physical_keycode in [KEY_HOME,KEY_INSERT]: _title33()

func _status() -> void:
	super._status()
	if world_ready:
		label.text=label.text.replace("连续世界32","连续世界33")
		var hint := "\nEnd 蓄力扑跳 / 旧追逐对照"
		if not label.text.contains(hint): label.text+=hint
