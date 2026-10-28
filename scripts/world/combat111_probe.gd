extends "res://scripts/world/combat110_probe.gd"
class Battle111:
 extends "res://scripts/world/woodland_world111.gd"
 var permit := false
 var immortal := true
 var shooting := false
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return shooting
 func start_combat(reposition := true) -> void:
  if permit: super.start_combat(reposition)
 func hurt_player(damage: float,at: Vector2) -> void:
  super.hurt_player(damage,at)
  if immortal and player_hp>0.: player_hp=100.
func create_sample110() -> Node3D: return Battle111.new()
