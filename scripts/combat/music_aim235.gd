extends "res://scripts/combat/bat_aim223.gd"
var music_rect235 := Rect2()
func _draw() -> void:
 super._draw()
 if not active117 or not battle.music_running235():return
 var actor: Variant=battle.target114
 if is_bat223(actor) and not can_frame223(actor):return
 var scale235=clampf(get_viewport_rect().size.y/1000.,.75,1.5)
 var rect: Rect2
 if is_instance_valid(actor) and not actor.dead:
  if is_bat223(actor):rect=frame_rect223(actor).grow((7.+acquired117*35.)*scale235)
  else:
   var art: Sprite3D=actor.visual
   var h=float(actor.poses.idle.visible_height)/24.*actor.body_scale110*art.scale.y
   var width=float(actor.poses.idle.visible_width)/24.*actor.body_scale110*art.scale.x
   var base=actor.global_position+art.position
   var left=battle.camera.unproject_position(base+Vector3(-width*.5,h*.5,0.));var right=battle.camera.unproject_position(base+Vector3(width*.5,h*.5,0.))
   var top=battle.camera.unproject_position(base+Vector3.UP*h);var bottom=battle.camera.unproject_position(base)
   rect=Rect2(Vector2(left.x,top.y),Vector2(right.x-left.x,bottom.y-top.y)).grow((7.+acquired117*35.)*scale235)
 else:rect=Rect2(get_viewport().get_mouse_position()-Vector2.ONE*20.*scale235,Vector2.ONE*40.*scale235)
 music_rect235=rect
 var phase=fmod(battle.rhythm235.time,.5)/.5
 var approaching=rect.grow((1.-phase)*65.*scale235)
 var ink=Color("9cdedc")
 if battle.flash235>0.:ink=Color("fff2a6") if battle.judgment235.begins_with("Perfect") else Color("d3d1e2")
 draw_rect(rect,Color(ink,.55),false,1.5*scale235)
 draw_rect(approaching,ink,false,2.*scale235)
 var status="♪ 120 BPM  ·  "+battle.judgment235
 draw_string(ThemeDB.fallback_font,rect.position+Vector2(0.,-12.*scale235),status,HORIZONTAL_ALIGNMENT_LEFT,-1,18*scale235,ink)
 # A stable four-beat indicator remains readable while the selected actor moves.
 var centre=Vector2(get_viewport_rect().size.x*.5,get_viewport_rect().size.y-64.)
 for i in 4:
  var at=centre+Vector2((i-1.5)*22.,0.)
  draw_circle(at,5.,ink if i==posmod(floori(battle.rhythm235.time/.5),4) else Color(.4,.4,.5,.65))
