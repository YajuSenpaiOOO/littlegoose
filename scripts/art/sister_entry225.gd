extends "res://scripts/art/sister_fall224.gd"
var entering225 := false
var step225 := false
func entry_pose225(at: Vector2,bed: Vector2,seat: bool,show_bed: bool,height: float,delta: float) -> void:
 entering225=true;place220(bed,height,delta)
 person_at=at;rig_at=bed;sitting=seat;rig_visible=show_bed
func _process(delta: float) -> void:
 super._process(delta)
 if entering225 and not sitting:
  var breath=sin(elapsed*TAU/3.4)*.006
  standing.scale=Vector3(1.-breath*.5,1.+breath,1.)
  if step225:
   standing.global_position.y+=absf(sin(elapsed*5.))* .012
   standing.global_basis=Basis(world.camera.global_basis.z,sin(elapsed*5.)*.012)*standing.global_basis
