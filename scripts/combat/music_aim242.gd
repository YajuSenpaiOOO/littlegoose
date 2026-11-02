extends "res://scripts/combat/music_aim241.gd"
var corners242 := 0
func draw_base238() -> void:
 if not battle.music_running236():super.draw_base238();return
 var actor: Variant=battle.target114
 cursor223(is_instance_valid(actor) and not actor.dead and (not is_bat223(actor) or can_frame223(actor)))
func frame_shape238(rect: Rect2,ink: Color,width: float) -> void:
 if not battle.music_running236():super.frame_shape238(rect,ink,width);return
 if width<=.01:return
 var scale242=clampf(get_viewport_rect().size.y/1000.,.75,1.4)
 var length=minf(19.*scale242,minf(rect.size.x,rect.size.y)*.30)
 var radius=minf(7.*scale242,length*.48)
 for corner in [Vector2.ZERO,Vector2(1,0),Vector2.ONE,Vector2(0,1)]:
  var origin=rect.position+rect.size*corner
  var inward=Vector2(1.-2.*corner.x,1.-2.*corner.y)
  var points=PackedVector2Array([origin+Vector2(length,0.)*inward,origin+Vector2(radius,0.)*inward])
  for j in range(1,7):
   var angle=-PI*.5-PI*.5*j/6.
   points.append(origin+(Vector2.ONE*radius+Vector2(cos(angle),sin(angle))*radius)*inward)
  points.append(origin+Vector2(0.,length)*inward)
  draw_polyline(points,ink,width,true)
  draw_circle(points[0],width*.5,ink);draw_circle(points[-1],width*.5,ink)
  corners242+=1
func _draw() -> void:
 corners242=0;super._draw()
 if not active117 or not battle.music_running236() or note_times237.is_empty():return
 var actor: Variant=battle.target114
 if is_bat223(actor) and not can_frame223(actor):return
 var scale242=clampf(get_viewport_rect().size.y/1000.,.75,1.4)
 var dt=note_times237[0]-battle.rhythm236.time
 var box=judge_rect238.grow(dt/battle.rhythm236.period237()*36.*scale242)
 var at=Vector2(box.end.x-9.*scale242,box.position.y-7.*scale242)
 var ink=Color("f6dfb5")
 draw_circle(at,3.*scale242,ink)
 draw_line(at+Vector2(2,0)*scale242,at+Vector2(2,-10)*scale242,ink,2.*scale242,true)
 draw_line(at+Vector2(2,-10)*scale242,at+Vector2(7,-7)*scale242,ink,2.*scale242,true)
