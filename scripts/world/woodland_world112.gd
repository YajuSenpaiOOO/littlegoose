extends "res://scripts/world/woodland_world111.gd"
var woodland_ready112 := false
var speech112: CanvasLayer
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 112 · 小黑鹅气泡 / 性能分项诊断")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time112.gd")
func _ready() -> void:
 super._ready()
 while not woodland_ready111: await get_tree().physics_frame
 speech112=preload("res://scripts/combat/goose_speech112.gd").new();speech112.battle=self;add_child(speech112)
 woodland_ready112=true;_title35();print("WOODLAND112_READY")
func _continue_after_buff(card: Dictionary) -> void:
 super._continue_after_buff(card)
 if result_open: _apply_owned_buffs()
 # Keep mechanical card descriptions in the draft, dialogue over its speaker.
 encounter_hud.announce(str(card.name),"大王战完成 · 可以继续探索或F5重试" if result_open else "回忆已获得",1.8)
 if is_instance_valid(speech112): speech112.say_card(str(card.get("line","")))
func start_combat(reposition := true) -> void:
 if is_instance_valid(speech112): speech112.dismiss()
 super.start_combat(reposition)
func _leave_encounter() -> void:
 if is_instance_valid(speech112): speech112.dismiss()
 super._leave_encounter()
