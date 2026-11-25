extends SceneTree
func _initialize() -> void:
 var errors: Array=[]
 var b=preload("res://scripts/art/preview_attack_force_20261116.gd").Board.new()
 var curve=preload("res://scripts/art/attack_force_curve_20261116.gd")
 var before:=curve.sample(0.);var max_step:=0.
 for i in 1001:
  var t:=i*.001;var p: Dictionary=curve.sample(t)
  if b.deform_point(Vector2(228,85),p).length()>.000001:errors.append("shoulder root moved")
  if not b.deform_point(Vector2(80,80),p).is_finite():errors.append("invalid hand")
  max_step=maxf(max_step,absf(p.body_x-before.body_x));before=p
 if max_step>.3:errors.append("body discontinuity")
 var end: Dictionary=curve.sample(1.)
 if absf(end.body_x)+absf(end.upper)+absf(end.elbow)+absf(end.reach)>.000001:errors.append("not settled")
 if curve.sample(.18).body_x>=curve.sample(.28).body_x:errors.append("body does not lag hand")
 b.free()
 var f:=FileAccess.open("res://docs/attack-force-20261116-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"errors":errors,"max_body_step_per_ms":max_step,"hand_extension_peak_s":.18,"recoil_peak_s":.28},"\t"));f.close()
 print("ATTACK_FORCE_DONE ",errors);quit(0 if errors.is_empty() else 1)
