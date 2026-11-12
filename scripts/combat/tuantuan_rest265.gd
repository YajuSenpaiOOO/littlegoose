extends "res://scripts/combat/tuantuan_boss262.gd"
var resting265 := false
var sleeping265 := true
var rest_clock265 := 0.
var wake_left265 := 0.
var sleep265: Texture2D
var layout265: Dictionary
func _ready() -> void:
 super._ready();sleep265=preload("res://assets/tuantuan_rest265/sleep.png")
 layout265=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_rest265/layout.json"))["sleep.png"]
 set_process(true)
func rest265(sleeping: bool) -> void:
 resting265=true;sleeping265=sleeping;wake_left265=0.;set_physics_process(false)
 collision_layer=16;hit_area.collision_layer=0;health_fill.hide();marker247.hide();cue.hide();small_cue.hide()
 var foot=get_child(0) as CollisionShape3D;var shape=CylinderShape3D.new();shape.radius=.85;shape.height=.45;foot.shape=shape;foot.position.y=.225
 _process(0.)
func wake265() -> void:
 sleeping265=false;wake_left265=.85
func _process(delta: float) -> void:
 if not resting265:super._process(delta);return
 if not battle.combat_paused:rest_clock265+=delta;wake_left265=maxf(0.,wake_left265-delta)
 var snoozing=sleeping265 or wake_left265>.45
 if snoozing:
  var box: Array=layout265.alpha_bbox;var foot: Array=layout265.foot
  visual.texture=sleep265;visual.pixel_size=3.4/float(box[2]-box[0]);visual.offset=Vector2(sleep265.get_width()*.5-float(foot[0]),float(foot[1])-sleep265.get_height()*.5)
  visual.position=Vector3(0,.24,0);visual.rotation=Vector3.ZERO;visual.scale=Vector3(1.+sin(rest_clock265*2.)*.006,1.+sin(rest_clock265*2.)*.015,1.)
  visual.material_override=soft_ink;soft_ink.set_shader_parameter("art",sleep265);soft_ink.set_shader_parameter("tint",visual.modulate);soft_ink.set_shader_parameter("dent",0.);soft_ink.set_shader_parameter("head_lag",0.)
 else:
  dead=false;phase247="rest";lift247=0.;flash=0.;hit_left=0.;landing_left=0.;hopping=false;render247();visual.position.y+=.24
  if wake_left265>0.:visual.scale*=Vector3(1.+wake_left265*.12,1.-wake_left265*.25,1.)
 health_fill.hide();shadow.hide();hit_area.collision_layer=0
