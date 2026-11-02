extends "res://scripts/combat/candy_aim118.gd"
## The bat visual belongs to the rig, not its target proxy: use global sprite bounds.
var drawn_bat223 := 0
var drawn_rect223 := Rect2()
func is_bat223(actor: Variant) -> bool:
 return is_instance_valid(actor) and battle.bats220.has(actor)
func can_frame223(actor: Variant) -> bool:
 return active117 and battle.active114 and battle.battle_phase220=="repair" and is_bat223(actor) and actor.enabled220 and not actor.dead and actor.hp>0.
func frame_rect223(actor: Node3D) -> Rect2:
 var art: Sprite3D=actor.visual;var bounds: Rect2=art.get_meta("aim_bounds223",Rect2(Vector2.ZERO,art.texture.get_size()))
 var size=art.texture.get_size();var rect=Rect2();var first=true
 for uv in [bounds.position,bounds.position+Vector2(bounds.size.x,0.),bounds.end,bounds.position+Vector2(0.,bounds.size.y)]:
  var local=Vector3((uv.x-size.x*.5+art.offset.x)*art.pixel_size,(size.y*.5-uv.y+art.offset.y)*art.pixel_size,0.)
  var point=battle.camera.unproject_position(art.to_global(local))
  if first:rect=Rect2(point,Vector2.ZERO);first=false
  else:rect=rect.expand(point)
 return rect
func cursor223(targeted: bool) -> void:
 if not active117 or not cursor_live117:return
 var scale117=clampf(get_viewport_rect().size.y/1000.,.75,1.5)
 var at=get_viewport().get_mouse_position().round();var px=maxf(1.,roundf(scale117*2.))
 var frame=(2 if targeted else 0)+(1 if int(clock117*2.)%4==0 else 0)
 draw_texture_rect(sweets117[frame],Rect2(at-Vector2(8.,7.)*px,Vector2(19,21)*px),false)
func _draw() -> void:
 drawn_bat223=0;drawn_rect223=Rect2()
 var actor: Variant=battle.target114
 if not is_bat223(actor):super._draw();return
 var eligible=can_frame223(actor);cursor223(eligible)
 if not eligible:return
 var scale223=clampf(get_viewport_rect().size.y/1000.,.75,1.5)
 var rect=frame_rect223(actor).grow((7.+acquired117*35.)*scale223)
 drawn_bat223=actor.get_instance_id();drawn_rect223=rect
 var length=14.*scale223;var thick=3.*scale223
 var color=Color(1.,.90,.66,.85+.10*sin(clock117*3.))
 for corner in [Vector2.ZERO,Vector2(1,0),Vector2.ONE,Vector2(0,1)]:
  var at=(rect.position+rect.size*corner).round();var inward=Vector2(1.-2.*corner.x,1.-2.*corner.y)
  for dir in [Vector2(inward.x,0.),Vector2(0.,inward.y)]:
   draw_line(at,at+dir*length,Color(.18,.24,.22,.88),thick+3.*scale223)
   draw_line(at,at+dir*length,color,thick)
  pixel117(at+inward*3.*scale223,2.*scale223,Color(1.,.73,.69,.92))
