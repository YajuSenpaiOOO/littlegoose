extends "res://scripts/art/sister_transport211.gd"
var lost220 := -1
func _ready() -> void:
 super._ready();manual=true;running=false;drop_enabled206=false;body.collision_layer=0
func place220(at: Vector2,height: float,delta: float) -> void:
 elapsed+=delta;state="travel";age=0.;person_at=at;rig_at=at;sitting=true;rig_visible=true;lift=height
 body.global_position=ground(at);contact.global_position=ground(at)+Vector3.UP*.03;contact_ink.set_shader_parameter("strength",.10)
 swing206=sin(elapsed*2.)*.02
 if lost220>=0:swing206+=.24
func _process(delta: float) -> void:
 super._process(delta)
 if lost220>=0 and not bats.is_empty():
  bats[lost220].global_basis=Basis(world.camera.global_basis.z,1.15)*world.camera.global_basis
  bats[lost220].scale=Vector3.ONE*.75
