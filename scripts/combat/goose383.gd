extends "res://scripts/combat/goose29.gd"
var human383: Node3D
var use_human383:=true
func _ready() -> void:
 super._ready()
 human383=flight_visual_script383().new();human383.battle=battle;add_child(human383)
 visual.visible=false;shadow.visible=false
func flight_visual_script383() -> Script:return preload("res://scripts/combat/flight_visual383.gd")
func _update_follow_visual(target: Vector3,snap := false) -> void:
 super._update_follow_visual(target,snap)
 shadow.visible=false
 if not is_instance_valid(human383):return
 if not battle.combat_paused:
  if battle.auto114 and not is_instance_valid(battle.target114):
   human383.face383(Vector3(battle.hero.velocity.x,0,battle.hero.velocity.z))
  else:human383.face383(last_shot_direction)
 visual.visible=not use_human383;human383.visible=use_human383
 human383.update_shadow380()
func _process(_delta: float) -> void:
 if not is_instance_valid(human383):return
 for piece in [human383.body379,human383.wing379,human383.far381,human383.hair382]:piece.modulate=visual.modulate
func _update_wing_pose(_delta: float,_target: Vector3) -> void:
 if use_human383:visual.rotation.z=0.
 else:super._update_wing_pose(_delta,_target)
func muzzle() -> Vector3:
 if is_instance_valid(human383) and use_human383:return human383.muzzle383()
 return super.muzzle()
