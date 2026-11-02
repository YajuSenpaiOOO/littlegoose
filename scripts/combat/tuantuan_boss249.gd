extends "res://scripts/combat/tuantuan_boss248.gd"
var reverse_pending249 := false
func _ready() -> void:
 super._ready()
 # An actor-local ground projection, not a marker at the future destination.
 var ink=ShaderMaterial.new();ink.shader=preload("res://scripts/combat/boss_shadow249.gdshader")
 shadow.material_override=ink
 var plane=PlaneMesh.new();plane.size=Vector2(1.44,1.20);shadow.mesh=plane
func enter247(next: String) -> void:
 super.enter247(next)
 if next in ["angry","flat","rest"]:reverse_pending249=false
func lock247() -> void:
 reflected248=reverse_pending249
 super.lock247()
 reverse_pending249=false
func land247() -> void:
 # The reflected flight ends here. A fresh parry during this landing may arm one more.
 reflected248=false
 super.land247()
func deflect(contact: Vector3) -> void:
 var before=parried_count
 super.deflect(contact)
 if parried_count>before:reverse_pending249=phase247=="deflected"
func draw_marker247() -> void:
 if battle.show_landing249:super.draw_marker247()
 else:marker247.hide()
func render247() -> void:
 super.render247()
 if not is_instance_valid(shadow):return
 # Retain the current ground-root projection and terrain normal; do not predict landing.
 var spread=1.-minf(lift247*.06,.18)
 shadow.scale=Vector3(body_scale110*spread,1.,body_scale110*spread)
 if shadow.material_override is ShaderMaterial:
  shadow.material_override.set_shader_parameter("opacity",.58-minf(lift247*.025,.08))
 if not battle.show_landing249:marker247.hide()
