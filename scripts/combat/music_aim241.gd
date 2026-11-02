extends "res://scripts/combat/music_aim239.gd"
var resolved240 := false
func _process(delta: float) -> void:
 super._process(delta)
 if battle.music_enabled236():acquired117=0.
func frame_alpha238(index: int,nearest: bool) -> float:return 1. if nearest else (.22 if index==1 else .12)
func frame_width238(nearest: bool) -> float:return 4. if nearest else 1.
func result237(kind: String,offset: float) -> void:
 super.result237(kind,offset)
 if kind=="miss_shot" and resolved240:text237="MISS · 此拍已结束"
func _draw() -> void:
 super._draw()
 if not active117 or not battle.music_running236():return
 var actor: Variant=battle.target114
 if is_bat223(actor) and not can_frame223(actor):return
 var period=battle.rhythm236.period237()
 var phase=fmod(battle.rhythm236.time,period)
 var duration=minf(.10,period*.2)
 if battle.rhythm236.time>=period and phase<duration:
  frame_shape238(judge_rect238,Color(1.,.97,.8,(1.-phase/duration)*.85),5.*clampf(get_viewport_rect().size.y/1000.,.75,1.4))
