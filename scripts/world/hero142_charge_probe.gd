extends SceneTree
class Cards:
 extends RefCounted
 func level(key: String) -> int: return 1 if key=="slingshot" else 0
class Context:
 extends Node3D
 var buffs := Cards.new()
 var charge_active := false
func _initialize() -> void:
 var context := Context.new()
 var actor := preload("res://scripts/combat/hero142.gd").new();actor.battle=context
 var normal: float=actor.movement_speed();context.charge_active=true
 var charged: float=actor.movement_speed()
 var okay := normal>0. and is_equal_approx(charged,normal*.6)
 print("HERO142_CHARGE_SPEED ","PASS" if okay else "FAIL"," normal=",normal," charging=",charged)
 actor.free();context.free();quit(0 if okay else 1)
