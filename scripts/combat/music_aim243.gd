extends "res://scripts/combat/music_aim242.gd"
# Screen extents are registered once per repair window, independent of art bounds.
var bat_sizes243 := {}
func frame_rect223(actor: Node3D) -> Rect2:
 if not battle.music_enabled236() or not is_bat223(actor):return super.frame_rect223(actor)
 var centre: Vector3=actor.hit_area.global_position
 var id=actor.get_instance_id()
 var viewport_height=maxf(1.,get_viewport_rect().size.y)
 if not bat_sizes243.has(id):
  var camera=battle.camera
  var left=camera.unproject_position(centre-camera.global_basis.x*.72)
  var right=camera.unproject_position(centre+camera.global_basis.x*.72)
  var top=camera.unproject_position(centre+camera.global_basis.y*.48)
  var bottom=camera.unproject_position(centre-camera.global_basis.y*.48)
  bat_sizes243[id]=Vector2(absf(right.x-left.x),absf(bottom.y-top.y))/viewport_height
 var size: Vector2=bat_sizes243[id]*viewport_height
 var at=battle.camera.unproject_position(centre)
 return Rect2(at-size*.5,size)
func _process(delta: float) -> void:
 super._process(delta)
 if battle.battle_phase220!="repair":bat_sizes243.clear()
func frame_alpha238(index: int,nearest: bool) -> float:return 1. if nearest else (.52 if index==1 else .36)
func frame_width238(nearest: bool) -> float:return 4. if nearest else 2.
