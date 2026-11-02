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
var judge_rect238 := Rect2()
func _draw() -> void:
 draw_base238()
 if not active117 or not battle.music_running236():return
 var scale238=clampf(get_viewport_rect().size.y/1000.,.75,1.4)
 var actor: Variant=battle.target114
 var rect=Rect2(get_viewport().get_mouse_position()-Vector2.ONE*22.*scale238,Vector2.ONE*44.*scale238)
 if is_instance_valid(actor) and not actor.dead:
  if is_bat223(actor):
   if not can_frame223(actor):return
   rect=frame_rect223(actor).grow((7.+acquired117*35.)*scale238)
  else:
   var art: Sprite3D=actor.visual
   var h=float(actor.poses.idle.visible_height)/24.*actor.body_scale110*art.scale.y
   var width=float(actor.poses.idle.visible_width)/24.*actor.body_scale110*art.scale.x
   var base=actor.global_position+art.position
   var left=battle.camera.unproject_position(base+Vector3(-width*.5,h*.5,0.));var right=battle.camera.unproject_position(base+Vector3(width*.5,h*.5,0.))
   var top=battle.camera.unproject_position(base+Vector3.UP*h);var bottom=battle.camera.unproject_position(base)
   rect=Rect2(Vector2(left.x,top.y),Vector2(right.x-left.x,bottom.y-top.y)).grow((7.+acquired117*35.)*scale238)
 judge_rect238=rect
 # Every frame owns a beat. It approaches, is judged, then disappears permanently.
 var time=battle.rhythm236.time
 var period=battle.rhythm236.period237()
 note_times237.clear()
 for beat in range(maxi(1,floori(time/period)-1),floori(time/period)+5):
  var dt=beat*period-time
  if dt>period*3. or dt< -battle.rhythm236.great_window237() or beat<=battle.rhythm236.last:continue
  note_times237.append(beat*period)
 var nearest=note_times237[0] if not note_times237.is_empty() else -100.
 for i in range(note_times237.size()-1,-1,-1):
  var due=note_times237[i];var dt=due-time
  var box=rect.grow(dt/period*36.*scale238)
  var ink=Color("ffeab0") if due==nearest else Color("a0d3dd")
  ink.a=frame_alpha238(i,due==nearest)
  var thick=frame_width238(due==nearest)*scale238
  if clock237<click_until236 and due==nearest:ink=Color.WHITE;thick=5.*scale238
  frame_shape238(box,Color(.10,.09,.17,ink.a*.65),thick+2.*scale238)
  frame_shape238(box,ink,thick)
 # The existing aim corners remain the stationary judgement boundary.
 frame_shape238(rect,Color(1.,.93,.72,.35),1.*scale238)
 var age=clock237-pulse237
 if age<.30 and serial237>0:
  var u=age/.30
  var box=rect.grow(u*16.*scale238)
  var ink=Color(color237,1.-u)
  frame_shape238(box,Color(.10,.07,.16,(1.-u)*.8),10.*(1.-u)*scale238)
  frame_shape238(box,ink,6.*(1.-u)*scale238)
  if text237.begins_with("PERFECT"):
   for at in [box.position,Vector2(box.end.x,box.position.y),box.end,Vector2(box.position.x,box.end.y)]:star117(at,2.*scale238*(1.-u),ink)
 var words=text237 if clock237<until237 else "♪ 收缩到辅助框时点击"
 var pos=rect.position+Vector2(0,-17.*scale238)
 draw_string_outline(ThemeDB.fallback_font,pos,words,HORIZONTAL_ALIGNMENT_LEFT,-1,22*scale238,5,Color("242033"))
 draw_string(ThemeDB.fallback_font,pos,words,HORIZONTAL_ALIGNMENT_LEFT,-1,22*scale238,color237 if clock237<until237 else Color("eee4ce"))

func frame_alpha238(index: int,nearest: bool) -> float:return .95 if nearest else .25+(.13 if index==1 else 0.)
func frame_width238(nearest: bool) -> float:return 3. if nearest else 1.5

func frame_shape238(rect: Rect2,color: Color,width: float) -> void:draw_rect(rect,color,false,width)
func draw_base238() -> void:super._draw()
