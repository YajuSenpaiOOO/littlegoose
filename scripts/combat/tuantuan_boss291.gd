extends "res://scripts/combat/tuantuan_boss290.gd"
const ART291={
 "charge":preload("res://assets/tuantuan_boss291/charge.png"),
 "airborne":preload("res://assets/tuantuan_boss291/airborne.png"),
 "hit":preload("res://assets/tuantuan_boss291/hit.png"),
 "landing":preload("res://assets/tuantuan_boss291/landing.png"),
 "dizzy":preload("res://assets/tuantuan_boss291/dizzy.png"),
 "sleep":preload("res://assets/tuantuan_boss291/sleep.png")}
var layout291: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_boss291/layout.json"))
var rich291 := true
var pose291 := "idle"
func choose291() -> String:
 if dead:return "hit" if defeat_age<.065 else "dizzy"
 if hit_left>0.:return "hit"
 if phase247 in ["deflected"]:return "hit"
 if phase247 in ["angry","squat","pounce_wait"]:return "charge"
 if phase247=="bumper":return "dizzy"
 if phase247=="flat":return "landing" if clock247<.12 else ("dizzy" if clock247<2.15 else "idle")
 if phase247=="rebound":return "landing"
 if phase247 in ["flight","pounce"]:return "airborne"
 if landing_left>0.:return "landing"
 return "idle"
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift);pose291="idle"
 if not glass290 or not rich291:return
 pose291=choose291()
 if pose291=="idle":return
 var spec: Dictionary=layout291[pose291]
 var target_key={"charge":"shove124","airborne":"airborne","hit":"hit","landing":"landing","dizzy":"landing"}[pose291]
 var entry: Dictionary=poses[target_key]
 visual.texture=ART291[pose291]
 visual.pixel_size=float(poses.idle.visible_height)/24.*body_scale110/779.
 var foot=Vector2(spec.foot[0],spec.foot[1]);var span=Vector2(spec.span[0],spec.span[1])
 visual.offset=Vector2(visual.texture.get_width()*.5-foot.x,foot.y-visual.texture.get_height()*.5)
 # Fit authored world silhouette once. Legacy procedural impact follows this fit.
 fit290=Vector3(float(entry.visible_width)/24.*body_scale110/(span.x*visual.pixel_size),float(entry.visible_height)/24.*body_scale110/(span.y*visual.pixel_size),1.)
func skin_shader290() -> void:
 if not rich291 or pose291=="idle":super.skin_shader290();return
 if not glass290 or soft_ink==null:return
 var spec: Dictionary=layout291[pose291]
 soft_ink.set_shader_parameter("art",ART291[pose291])
 soft_ink.set_shader_parameter("body_span",Vector2(spec.span[0],spec.span[1])/visual.texture.get_size())
 soft_ink.set_shader_parameter("foot_y",float(spec.foot[1])/visual.texture.get_height())
func _process(delta: float) -> void:
 super._process(delta)
 if not rich291 or not glass290 or not resting265 or not (sleeping265 or wake_left265>.45):return
 var spec: Dictionary=layout291.sleep;var art: Texture2D=ART291.sleep
 pose291="sleep";visual.texture=art;visual.pixel_size=3./float(spec.span[0])
 visual.offset=Vector2(art.get_width()*.5-float(spec.foot[0]),float(spec.foot[1])-art.get_height()*.5)
 visual.material_override=soft_ink;skin_shader290()
