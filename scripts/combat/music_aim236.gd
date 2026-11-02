extends "res://scripts/combat/bat_aim223.gd"
var music_rect236 := Rect2()
var pulses236: Array[Dictionary]=[]
var consumed236 := -1
var click_until236 := -1.
func click236() -> void:click_until236=age236+.09
var age236 := 0.
var stamp236 := 0
func _process(delta: float) -> void:
 super._process(delta)
 var now=Time.get_ticks_usec()
 if stamp236>0 and not battle.combat_paused:age236+=float(now-stamp236)/1000000.
 stamp236=now
 for i in range(pulses236.size()-1,-1,-1):
  if age236-float(pulses236[i].start)>.32:pulses236.remove_at(i)
func hit236(beat: int,perfect: bool) -> void:
 consumed236=beat
 if music_rect236.size==Vector2.ZERO:return
 var phase=fmod(battle.rhythm236.time,.5)/.5
 var expansion=(1.-phase)*65. if beat>floori(battle.rhythm236.time/.5) else 0.
 pulses236.append({"rect":music_rect236.grow(expansion),"start":age236,"perfect":perfect})
 while pulses236.size()>4:pulses236.pop_front()
func feedback236(scale236: float) -> void:
 for pulse in pulses236:
  var t=clampf((age236-float(pulse.start))/.30,0.,1.)
  var ink=Color("fff1a0") if pulse.perfect else Color("bcb4d5")
  ink.a=1.-t
  var box: Rect2=pulse.rect
  box=box.grow(t*(14. if pulse.perfect else 6.)*scale236)
  draw_rect(box,Color(ink,.10*(1.-t)),true)
  draw_rect(box,Color(.10,.07,.15,ink.a*.8),false,(11. if pulse.perfect else 6.)*(1.-t)*scale236)
  draw_rect(box,ink,false,(7. if pulse.perfect else 3.)*(1.-t)*scale236)
  if pulse.perfect:
   for corner in [box.position,Vector2(box.end.x,box.position.y),box.end,Vector2(box.position.x,box.end.y)]:star117(corner,2.*scale236*(1.-t),ink)
  var words="PERFECT!  ×1.4" if pulse.perfect else "普通  ×1.0"
  var pos=Vector2(box.get_center().x-85.*scale236,box.position.y-24.*scale236-t*12.)
  draw_string_outline(ThemeDB.fallback_font,pos,words,HORIZONTAL_ALIGNMENT_LEFT,-1,25*scale236,6,Color(.12,.07,.18,ink.a))
  draw_string(ThemeDB.fallback_font,pos,words,HORIZONTAL_ALIGNMENT_LEFT,-1,25*scale236,ink)

func _draw() -> void:
 super._draw()
 if not active117 or not battle.music_running236():return
 var actor: Variant=battle.target114
 if is_bat223(actor) and not can_frame223(actor):return
 var scale236=clampf(get_viewport_rect().size.y/1000.,.75,1.5)
 var rect: Rect2
 if is_instance_valid(actor) and not actor.dead:
  if is_bat223(actor):rect=frame_rect223(actor).grow((7.+acquired117*35.)*scale236)
  else:
   var art: Sprite3D=actor.visual
   var h=float(actor.poses.idle.visible_height)/24.*actor.body_scale110*art.scale.y
   var width=float(actor.poses.idle.visible_width)/24.*actor.body_scale110*art.scale.x
   var base=actor.global_position+art.position
   var left=battle.camera.unproject_position(base+Vector3(-width*.5,h*.5,0.));var right=battle.camera.unproject_position(base+Vector3(width*.5,h*.5,0.))
   var top=battle.camera.unproject_position(base+Vector3.UP*h);var bottom=battle.camera.unproject_position(base)
   rect=Rect2(Vector2(left.x,top.y),Vector2(right.x-left.x,bottom.y-top.y)).grow((7.+acquired117*35.)*scale236)
 else:rect=Rect2(get_viewport().get_mouse_position()-Vector2.ONE*20.*scale236,Vector2.ONE*40.*scale236)
 music_rect236=rect
 var phase=fmod(battle.rhythm236.time,.5)/.5
 var approaching=rect.grow((1.-phase)*65.*scale236)
 var ink=Color("9cdedc")
 if battle.flash236>0.:ink=Color("fff2a6") if battle.judgment236.begins_with("Perfect") else Color("d3d1e2")
 draw_rect(rect,Color(ink,.55),false,1.5*scale236)
 if consumed236!=floori(battle.rhythm236.time/.5)+1:draw_rect(approaching,Color.WHITE if age236<click_until236 else ink,false,(5. if age236<click_until236 else 2.)*scale236)
 feedback236(scale236)
 var status="♪ 120 BPM  ·  "+battle.judgment236
 draw_string(ThemeDB.fallback_font,rect.position+Vector2(0.,-12.*scale236),status,HORIZONTAL_ALIGNMENT_LEFT,-1,18*scale236,ink)
 # A stable four-beat indicator remains readable while the selected actor moves.
 var centre=Vector2(get_viewport_rect().size.x*.5,get_viewport_rect().size.y-64.)
 for i in 4:
  var at=centre+Vector2((i-1.5)*22.,0.)
  draw_circle(at,5.,ink if i==posmod(floori(battle.rhythm236.time/.5),4) else Color(.4,.4,.5,.65))
