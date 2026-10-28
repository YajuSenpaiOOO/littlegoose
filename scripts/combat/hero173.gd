extends "res://scripts/combat/hero172.gd"
var feet173: MeshInstance3D
func web_speed172() -> float: return .55
func clear_web172() -> void:
 super.clear_web172()
 if is_instance_valid(feet173): feet173.hide();feet173.attached173=false;feet173.threads173.clear_surfaces()
func _ready() -> void:
 super._ready()
 feet173=preload("res://scripts/combat/web_feet173.gd").new();feet173.hero=self;feet173.battle=battle
 battle.combat_effect_root159().add_child(feet173)
