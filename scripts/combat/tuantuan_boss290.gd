extends "res://scripts/combat/tuantuan_rest266.gd"
## One selected painted skin, fitted to each legacy silhouette's world bounds.
## Keep the original Sprite3D instance: depth, shadow and hit reactions retain it.
const GLASS290 = preload("res://assets/tuantuan_boss289/A_glass.png")
const FOOT290 = Vector2(677.5,983.)
const SPAN290 = Vector2(825.,779.)
var glass290 := true
var fit290 := Vector3.ONE
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift)
 if not glass290:return
 if phase247 in ["angry","squat"] and poses.has("shove124") and not dead and hit_left<=0.:key="shove124"
 var entry: Dictionary=poses[key]
 visual.texture=GLASS290
 visual.pixel_size=float(poses.idle.visible_height)/24.*body_scale110/SPAN290.y
 visual.offset=Vector2(GLASS290.get_width()*.5-FOOT290.x,FOOT290.y-GLASS290.get_height()*.5)
 fit290=Vector3(float(entry.visible_width)/24.*body_scale110/(SPAN290.x*visual.pixel_size),float(entry.visible_height)/24.*body_scale110/(SPAN290.y*visual.pixel_size),1.)
func skin_shader290() -> void:
 if not glass290 or soft_ink==null:return
 soft_ink.set_shader_parameter("art",GLASS290)
 soft_ink.set_shader_parameter("body_span",SPAN290/GLASS290.get_size())
 soft_ink.set_shader_parameter("foot_y",FOOT290.y/GLASS290.get_height())
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if glass290:visual.scale*=fit290
 skin_shader290()
func render247() -> void:
 super.render247();skin_shader290()
