extends "res://scripts/combat/tuantuan125.gd"
func _ready() -> void:
 super._ready()
 textures["shove124"]=load("res://assets/tuantuan_v2/shove127_annoyed.png")
 poses["shove124"]=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_v2/shove127_annoyed.json"))
func _step_play123(delta: float) -> void:
 var target := peer123
 var tick := shove_tick123
 var contact := play_state123=="shove" and is_instance_valid(target) and Vector2(position.x-target.position.x,position.z-target.position.z).length()<1.3
 super._step_play123(delta)
 if contact and shove_tick123>tick and peer123==target and is_instance_valid(target) and not dead and not target.dead:
  battle.shove_juice127(self,target)

