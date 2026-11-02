extends "res://scripts/art/pig_drop220.gd"
var mirrored225 := false
func update_pose219() -> void:
 super.update_pose219()
 visual.flip_h=mirrored225
 if mirrored225:visual.offset.x=-visual.offset.x
func nose219(index: int) -> Vector3:
 if not mirrored225:return super.nose219(index)
 var f: Dictionary=layout.poses.frames[1];var p=Vector2(138.,280.) if index==0 else Vector2(189.,284.)
 var anchor=Vector2(f.anchor[0],f.anchor[1])
 return visual.global_position-visual.global_basis.x*(p.x-anchor.x)*visual.pixel_size+visual.global_basis.y*(anchor.y-p.y)*visual.pixel_size
