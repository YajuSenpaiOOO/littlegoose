extends "res://scripts/world/woodland_world158.gd"
var effects159: Node3D
func combat_effect_root159() -> Node3D:
 if not is_instance_valid(effects159):
  effects159=preload("res://scripts/combat/world_effects159.gd").new();effects159.battle=self;add_child(effects159)
 return effects159
func _sword_manager153() -> Script: return preload("res://scripts/combat/balloon_sword159.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 159 · 统一昼夜弹幕 / A气球剑")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(swords153): await get_tree().physics_frame
 if "--grade159" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
