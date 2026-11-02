extends "res://scripts/art/pig_spray219.gd"
var source220 := Vector3.ZERO
var falling220 := true
var fall_age220 := 0.
var actual_drop220 := Vector3.ZERO
var marker220: MeshInstance3D
func _ready() -> void:
 super._ready();body.collision_layer=0;manual219=true;warning.visible=false
 marker220=MeshInstance3D.new();marker220.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ring=TorusMesh.new();ring.inner_radius=.48;ring.outer_radius=.54;ring.rings=24;ring.ring_segments=6;marker220.mesh=ring
 var mat=StandardMaterial3D.new();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;mat.albedo_color=Color("f0c49b");marker220.material_override=mat;marker220.position.y=.04;marker220.scale.y=.1;add_child(marker220)
func reset219() -> void:
 super.reset219();body.collision_layer=0
func advance219(delta: float) -> void:
 if phase219=="gone":return
 super.advance219(delta);body.collision_layer=0
func _physics_process(delta: float) -> void:
 if world.combat_paused or not world.active114:return
 if falling220:
  fall_age220+=delta
  var t=clampf(fall_age220/.85,0.,1.)
  actual_drop220=source220.lerp(global_position+Vector3.UP*.025,t*t)
  if t>=1.:falling220=false;phase219="idle";age219=0.
 else:advance219(delta)
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(marker220):marker220.visible=falling220
 if falling220:
  visual.global_position=actual_drop220 if fall_age220>0. else source220
  warning.visible=false
 elif phase219=="idle":visual.global_position.y+=absf(sin(age219*PI*5.))*.08*(1.-minf(age219/.6,1.))
