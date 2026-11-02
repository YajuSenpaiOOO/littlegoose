extends "res://scripts/combat/bat_aim223.gd"
# Compatibility with inherited world236 reset/input hooks.
var consumed236 := -1
var pulses236 := []
var click_until236 := -1.
var clock237 := 0.
var stamp237 := 0
var text237 := "音符到线时点击"
var color237 := Color("d4d8e9")
var until237 := 0.
var pulse237 := 0.
var serial237 := 0
var note_times237: Array[float]=[]
func _process(delta: float) -> void:
 super._process(delta)
 var now=Time.get_ticks_usec()
 if stamp237>0 and not battle.combat_paused:clock237+=float(now-stamp237)/1000000.
 stamp237=now
func click236() -> void:click_until236=clock237+.08
func hit236(_beat: int,_perfect: bool) -> void:
 result237(battle.last_kind237,battle.last_offset237)
func result237(kind: String,offset: float) -> void:
 serial237+=1;pulse237=clock237;until237=clock237+.65
 match kind:
  "perfect":text237="PERFECT!  ×1.4";color237=Color("fff2a0")
  "early":text237="普通 · 偏早  %d ms"%roundi(absf(offset)*1000.);color237=Color("c7c0f0")
  "late":text237="普通 · 偏晚  %d ms"%roundi(absf(offset)*1000.);color237=Color("c7c0f0")
  "auto":text237="自动 · 普通 ×1.0";color237=Color("b5c4d2")
  "miss":text237="MISS";color237=Color("ec999f")
  "skip":text237="避让 · 跳拍";color237=Color("9ba1ab")
  "too_early":text237="太早 · 尚未到线";color237=Color("eab58b")
  "too_late":text237="太晚 · 此音已结束";color237=Color("eab58b")
func _draw() -> void:
 super._draw()
 if not active117 or not battle.music_running236():return
 var scale237=clampf(get_viewport_rect().size.y/1000.,.75,1.4)
 var centre=Vector2(get_viewport_rect().size.x*.60,get_viewport_rect().size.y*.42)
 var actor: Variant=battle.target114
 if is_instance_valid(actor) and not actor.dead and (not is_bat223(actor) or can_frame223(actor)):
  if is_bat223(actor):
   var rect=frame_rect223(actor);centre=Vector2(rect.get_center().x,rect.position.y-58.*scale237)
  else:
   # Match the existing ordinary target frame; full atlas margins are not bounds.
   var art: Sprite3D=actor.visual
   var height=float(actor.poses.idle.visible_height)/24.*actor.body_scale110*art.scale.y
   var top=battle.camera.unproject_position(actor.global_position+art.position+Vector3.UP*height)
   centre=top-Vector2(0,58.*scale237)
 centre.x=clampf(centre.x,180.*scale237,get_viewport_rect().size.x-180.*scale237)
 centre.y=clampf(centre.y,190.*scale237,get_viewport_rect().size.y-120.*scale237)
 var box=Rect2(centre-Vector2(164,28)*scale237,Vector2(328,56)*scale237)
 draw_style_box(style237(),box)
 var line=centre+Vector2(-108,0)*scale237
 var velocity=160.*scale237
 draw_rect(Rect2(line-Vector2(velocity*.08,18.*scale237),Vector2(velocity*.16,36.*scale237)),Color(.9,.85,.5,.13))
 draw_line(Vector2(box.position.x+8.*scale237,centre.y),Vector2(box.end.x-8.*scale237,centre.y),Color(.6,.65,.75,.5),2.)
 draw_line(line-Vector2(0,22)*scale237,line+Vector2(0,22)*scale237,Color.WHITE,3.*scale237)
 var t=battle.rhythm236.time
 note_times237.clear()
 for beat in range(maxi(1,floori(t/.5)-1),floori(t/.5)+5):
  var dt=beat*.5-t
  if dt>1.5 or dt<-.16 or beat<=battle.rhythm236.last:continue
  note_times237.append(beat*.5)
  var at=line+Vector2(dt*velocity,0.)
  var next=beat==maxi(battle.rhythm236.last+1,1)
  var ink=Color("ffe6a1") if next else Color("9ed4dc")
  draw_rect(Rect2(at-Vector2(8,12)*scale237,Vector2(16,24)*scale237),Color(.12,.12,.2),true)
  draw_rect(Rect2(at-Vector2(8,12)*scale237,Vector2(16,24)*scale237),ink,false,(3. if next else 2.)*scale237)
  draw_circle(at,2.5*scale237,ink)
 var age=clock237-pulse237
 if age<.28 and serial237>0:
  var u=age/.28
  draw_circle(line,(12.+u*19.)*scale237,Color(color237,(1.-u)*.23))
  draw_arc(line,(12.+u*19.)*scale237,0.,TAU,24,Color(color237,1.-u),4.*scale237,true)
  if text237.begins_with("PERFECT"):
   for dir in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:star117(line+dir*(18.+u*22.)*scale237,2.*scale237*(1.-u),Color(color237,1.-u))
 if clock237<click_until236:draw_line(line-Vector2(0,22)*scale237,line+Vector2(0,22)*scale237,Color.WHITE,7.*scale237)
 var words=text237 if clock237<until237 else "♪ 120 BPM · 到线点击 / 按住自动"
 var pos=Vector2(box.position.x,box.position.y-12.*scale237)
 draw_string_outline(ThemeDB.fallback_font,pos,words,HORIZONTAL_ALIGNMENT_LEFT,-1,21*scale237,5,Color("242033"))
 draw_string(ThemeDB.fallback_font,pos,words,HORIZONTAL_ALIGNMENT_LEFT,-1,21*scale237,color237 if clock237<until237 else Color("e4dfed"))
func style237() -> StyleBoxFlat:
 var style=StyleBoxFlat.new();style.bg_color=Color(.07,.06,.12,.86);style.border_color=Color(.6,.6,.7,.6);style.set_border_width_all(1);style.set_corner_radius_all(8);return style
