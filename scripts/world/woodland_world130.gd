extends "res://scripts/world/woodland_world129.gd"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 130 · 随风漂流 / 阵风弧线掠过")
func _enemy_script() -> Script: return preload("res://scripts/combat/paper130.gd") if paper_trial129 else preload("res://scripts/combat/tuantuan128.gd")
func paper_wind130(at: Vector2,time: float) -> Vector2:
 var direction := .48*sin(time*.24)+.28*sin(time*.11+1.3)
 var speed := 1.02+.43*sin(time*.58)+.24*sin(time*.19+2.)
 return Vector2.from_angle(direction+sin(at.y*.12+time*.17)*.18)*speed
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if paper_trial129 and active114: encounter_hud.announce("作业纸 · 随风漂流","纸片先绷直，再借阵风划弧掠过；风弱时更舒展。",3.)
func _steering_snapshot113() -> void:
 super._steering_snapshot113()
 if not paper_trial129: return
 for i in steering_nodes113.size():
  var actor: CharacterBody3D=steering_nodes113[i]
  if is_instance_valid(actor) and actor.get("paper_lift129")!=null:
   steering_positions113[i].y+=actor.paper_lift129
