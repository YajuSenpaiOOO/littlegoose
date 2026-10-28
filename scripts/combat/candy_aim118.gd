extends "res://scripts/combat/candy_aim117.gd"
func _draw() -> void:
 super._draw()
 if not active117 or not is_instance_valid(battle.target114) or battle.target114.dead: return
 var actor: CharacterBody3D=battle.target114;var visual: Sprite3D=actor.visual
 var height: float=float(actor.poses.idle.visible_height)/24.*actor.body_scale110*visual.scale.y
 var width: float=float(actor.poses.idle.visible_width)/24.*actor.body_scale110*visual.scale.x
 var base := actor.global_position+visual.position
 var left: Vector2=battle.camera.unproject_position(base+Vector3(-width*.5,height*.5,0))
 var right: Vector2=battle.camera.unproject_position(base+Vector3(width*.5,height*.5,0))
 var top: Vector2=battle.camera.unproject_position(base+Vector3.UP*height)
 var bottom: Vector2=battle.camera.unproject_position(base)
 var scale118 := clampf(get_viewport_rect().size.y/1000.,.75,1.5)
 var pad := (7.+acquired117*35.)*scale118
 var rect := Rect2(Vector2(left.x,top.y),Vector2(right.x-left.x,bottom.y-top.y)).grow(pad)
 var length := 14.*scale118;var thick := 3.*scale118
 var color := Color(1.,.90,.66,.85+.10*sin(clock117*3.))
 for corner in [Vector2.ZERO,Vector2(1,0),Vector2.ONE,Vector2(0,1)]:
  var at: Vector2=(rect.position+rect.size*corner).round();var inward := Vector2(1.-2.*corner.x,1.-2.*corner.y)
  for dir in [Vector2(inward.x,0),Vector2(0,inward.y)]:
   draw_line(at,at+dir*length,Color(.18,.24,.22,.88),thick+3.*scale118)
   draw_line(at,at+dir*length,color,thick)
  pixel117(at+inward*3.*scale118,2.*scale118,Color(1.,.73,.69,.92))
