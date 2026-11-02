extends "res://scripts/world/woodland_world249.gd"
var projection250: MeshInstance3D
func _init() -> void:
 super._init();memory_save116="user://tuantuan_boss250_preview.cfg"
func boss_script247() -> Script:return preload("res://scripts/combat/tuantuan_boss250.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 250 · 团团Boss / 共用轮廓投影")
func begin247() -> void:
 super.begin247()
 _add_actor_shadow(boss247,boss247.visual)
 projection250=actor_shadows[-1]
 # Register with the same current sunlight/night palette immediately, not after a tick.
 if is_instance_valid(time55):time55.apply_look()
func _process(delta: float) -> void:
 super._process(delta)
 if ready247:guide247.text=guide247.text.replace("249 团团Boss · 地影读招","250 团团Boss · 共用轮廓投影")
