extends "res://scripts/combat/spider351.gd"
var kind301:="bomber"
var ground353:=Vector3.ZERO
var anchor353:=Vector3.ZERO
var swing353:=0.
var angle353:=0.
var amp353:=.58
var phase353:="swing"
var phase_age353:=0.
var volley353:=0
var thrown353:=0
var held353: Sprite3D
func _ready() -> void:
 super._ready()
 set_meta("air_target353",true)
 ground353=destination351;anchor353=ground353+Vector3.UP*5.8
 destination351=ground353+Vector3.UP*1.25
 held353=Sprite3D.new();held353.texture=load("res://assets/spider171/ball.png")
 held353.billboard=BaseMaterial3D.BILLBOARD_FIXED_Y;held353.pixel_size=1.05/float(held353.texture.get_width()-8)
 held353.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 held353.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(held353);held353.hide()
 animate351(0.)
func play119() -> void:
 super.play119()
 collision_layer=0;collision_mask=0
 phase353="swing";phase_age353=0.;volley353=0
func receive_hit(damage: float,direction: Vector3) -> void:
 super.receive_hit(damage,direction)
 if dead and is_instance_valid(held353):held353.hide()
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if dead or travel351!="":
  super._physics_process(delta)
  return
 if not battle.active114:return
 _step_response121(delta);swing353+=delta;phase_age353+=delta
 var wanted:=.08 if phase353=="rest" else (.20 if phase353=="windup" else .58)
 amp353=lerpf(amp353,wanted,1.-exp(-delta*4.))
 angle353=lerpf(angle353,cos(swing353*1.65)*amp353,1.-exp(-delta*7.))
 var before:=global_position
 global_position=anchor353+battle.camera.global_basis.x*sin(angle353)*3.4-Vector3.UP*(cos(angle353)*3.4+1.15)
 velocity=(global_position-before)/maxf(.001,delta)
 match phase353:
  "swing":
   if phase_age353>=1.5 and absf(angle353)<.25:phase353="windup";phase_age353=0.
  "windup":
   if phase_age353>=.85:
    battle.drop_bomb353(self,held353.global_position)
    thrown353+=1;volley353+=1;phase353="push";phase_age353=0.
  "push":
   if phase_age353>=.28:
    phase353="rest" if volley353>=2 else "swing";phase_age353=0.
  "rest":
   if phase_age353>=2.4:phase353="swing";phase_age353=0.;volley353=0
 pose353()
func pose353() -> void:
 var key:="sit" if phase353=="rest" else ("push" if phase353=="push" else "airborne")
 _pose(key,0.);visual.rotation.z=-angle353*.45
 var shade: Color=battle.combat_tint111.color
 shade.b=minf(shade.b,maxf(shade.r,shade.g)*1.25);visual.modulate=shade
 held353.visible=phase353=="windup"
 if held353.visible:
  var t:=smoothstep(0.,.85,phase_age353)
  held353.global_position=visual.to_global(Vector3(.15,.65+t*.85,.03))
  held353.rotation.z=sin(phase_age353*15.)*.08
  held353.modulate=shade
 pivot351=anchor353;silk351.show();rope351();health_fill.hide()
