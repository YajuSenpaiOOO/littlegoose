extends "res://scripts/art/paper_stage298.gd"
const OPERATOR299=preload("res://assets/paper_stage299/operator_dinosaur_v2.png")
## Approximate authored sheet body y658..1310; retain native paper134 37/24m.
const SHEET_PIXELS299 := 652.
const SHEET_HEIGHT299 := 37./24.
var impact299 := false
func _ready() -> void:
 super._ready()
 # Replace separate tiny operator and floating rod with one coherent grip drawing.
 for child in puppet298.get_children():
  if child is Sprite3D and child!=dinosaur298:child.hide()
 dinosaur298.texture=OPERATOR299;dinosaur298.pixel_size=SHEET_HEIGHT299/SHEET_PIXELS299
 dinosaur298.offset=Vector2(OPERATOR299.get_width()*.5-740.,1310.-OPERATOR299.get_height()*.5)
 dinosaur298.material_override.albedo_texture=OPERATOR299
 sample(0.)
func fall299(t: float,start: float,duration: float,height: float) -> float:
 if t<start:return height
 if t<start+duration:
  var u=(t-start)/duration
  return height*(1.-u*u*u)
 var elapsed=t-start-duration
 return -.055*sin(elapsed*28.)*exp(-elapsed*12.) if elapsed<.5 else 0.
func sample(t: float) -> void:
 super.sample(t)
 # Cards remain in their final display plane while falling vertically into slots.
 castle.visible=t>=.8;castle.rotation.x=deg_to_rad(-25.)
 castle.position.y=ground298(0,0)+fall299(t,.8,.62,13.)
 for i in wings298.size():
  var s=wings298[i];var begin=1.45+float(i)*.38
  s.visible=t>=begin;s.rotation.x=deg_to_rad(-25.)
  s.position.y=ground298(s.position.x,s.position.z)+fall299(t,begin,.48,10.)
 # A taller puppet cannot pass through the old short arch without clipping.
 # Demonstrate the already-discussed route around the castle's left side.
 var u=smoothstep(4.5,7.35,t)
 var route=[Vector3(-4.6,0,-1.3),Vector3(-6.1,0,1.1),Vector3(-3.7,0,3.7),Vector3(-1.1,0,4.)]
 var segment=mini(int(u*3.),2);var at: Vector3=route[segment].lerp(route[segment+1],clampf(u*3.-float(segment),0.,1.))
 at.y=ground298(at.x,at.z);puppet298.position=at
 if t<.1:impact299=false
 if playing and t>=1.42 and not impact299:
  impact299=true;battle.trauma=maxf(battle.trauma,.07)
