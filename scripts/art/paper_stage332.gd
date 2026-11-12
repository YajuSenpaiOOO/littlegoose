extends "res://scripts/art/paper_stage331.gd"

func shell331(at: Vector3, _heading: Vector2) -> Sprite3D:
 return make_shell326(at)

func orient_shell331(sprite: Sprite3D, _at: Vector3, _heading: Vector2) -> void:
 sprite.rotation.z += .07

func sweep_cue331(stream: Dictionary) -> void:
 if stream.is_empty():
  super.sweep_cue331(stream)
  return
 var shown := stream.duplicate()
 if stream.age<0.: shown.age = -.8
 else: shown.fired = battle.sweep_fraction332(int(stream.fired))*23.
 super.sweep_cue331(shown)
