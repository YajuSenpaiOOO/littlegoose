extends "res://scripts/combat/relay_flag245.gd"
const GOOSE_CENTRE246=(330.915+709.5*.43-332.)*PX
func shader245() -> Shader:return preload("res://scripts/art/relay_flag246.gdshader")
func ready_timeout245() -> float:return -1.
func offer245(packet: Dictionary,aim: Vector3) -> bool:
 var accepted=super.offer245(packet,aim)
 if accepted:
  var centre=global_position+battle.camera.global_basis.x*GOOSE_CENTRE246
  flip=-1. if battle.camera.unproject_position(aim).x<battle.camera.unproject_position(centre).x else 1.
 return accepted
func render245() -> void:
 super.render245()
 for i in inks.size():
  inks[i].set_shader_parameter("flip245",flip if i==2 else 1.)
  inks[i].set_shader_parameter("flip_centre246",GOOSE_CENTRE246 if i==2 else 0.)
func mouth245() -> Vector3:
 var x=GOOSE_CENTRE246+(.686-GOOSE_CENTRE246)*flip
 return global_position+battle.camera.global_basis.x*x+battle.camera.global_basis.y*.625
