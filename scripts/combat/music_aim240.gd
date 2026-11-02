extends "res://scripts/combat/music_aim239.gd"
var resolved240 := false
var offset240 := 0.
var offset_until240 := -1.
func _process(delta: float) -> void:
 super._process(delta)
 # Acquisition flourish must not move the timing boundary underneath the notes.
 if battle.music_enabled236():acquired117=0.
func frame_alpha238(index: int,nearest: bool) -> float:return 1. if nearest else (.22 if index==1 else .12)
func frame_width238(nearest: bool) -> float:return 4. if nearest else 1.
func result237(kind: String,offset: float) -> void:
 super.result237(kind,offset)
 if kind=="miss_shot" and resolved240:
  text237="MISS · 此拍已结束";offset_until240=-1.;return
 if kind in ["perfect","early","late","miss_shot"]:
  offset240=offset*1000.;offset_until240=clock237+1.
  text237+="  %+.0fms"%offset240
 else:offset_until240=-1.
func _draw() -> void:
 super._draw()
 if not active117 or not battle.music_running236():return
 var actor: Variant=battle.target114
 if is_bat223(actor) and not can_frame223(actor):return
 var rect=judge_rect238
 if rect.size==Vector2.ZERO:return
 var scale240=clampf(get_viewport_rect().size.y/1000.,.75,1.4)
 var phase=fmod(battle.rhythm236.time,.5)
 if battle.rhythm236.time>=.5 and phase<.10:
  draw_rect(rect,Color(1.,.97,.8,(1.-phase/.10)*.85),false,5.*scale240)
 var centre=Vector2(rect.get_center().x,rect.end.y+25.*scale240)
 var unit=scale240/3.
 draw_line(centre-Vector2(240.*unit,0),centre+Vector2(240.*unit,0),Color(.12,.09,.18,.9),10.*scale240)
 draw_line(centre-Vector2(160.*unit,0),centre+Vector2(160.*unit,0),Color(.45,.7,.74,.65),6.*scale240)
 draw_line(centre-Vector2(80.*unit,0),centre+Vector2(80.*unit,0),Color(.95,.83,.47,.85),6.*scale240)
 draw_line(centre-Vector2(0,7)*scale240,centre+Vector2(0,7)*scale240,Color.WHITE,2.*scale240)
 if clock237<offset_until240:
  var at=centre+Vector2(clampf(offset240,-240.,240.)*unit,0.)
  draw_circle(at,4.*scale240,color237)
 draw_string(ThemeDB.fallback_font,centre+Vector2(-80,23)*scale240,"早 ←       正拍       → 晚",HORIZONTAL_ALIGNMENT_LEFT,-1,14*scale240,Color("dcd5e5"))
