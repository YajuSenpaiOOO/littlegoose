extends "res://scripts/combat/spider350.gd"
var ambient351:=false
var ambient_scale351:=.5
var travel351:="entry"
var clock351:=0.
var destination351:=Vector3.ZERO
var pivot351:=Vector3.ZERO
var departure351:=Vector3.ZERO
var body_layer351:=0
var body_mask351:=0
var silk351: MeshInstance3D
var thread351: ImmediateMesh
func _ready() -> void:
 super._ready()
 destination351=global_position
 pivot351=destination351+Vector3.UP*14.
 body_layer351=collision_layer;body_mask351=collision_mask
 collision_layer=0;collision_mask=0;hit_area.collision_layer=0;active_ai=false
 thread351=ImmediateMesh.new();silk351=MeshInstance3D.new();silk351.mesh=thread351
 silk351.top_level=true;silk351.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var material:=StandardMaterial3D.new();material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 material.albedo_color=Color(.86,.88,.82,.7);material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 material.no_depth_test=false;silk351.material_override=material;add_child(silk351)
 entry350=1.8
 animate351(0.)
 reset_physics_interpolation()
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift)
 if ambient351:visual.scale*=ambient_scale351
func rope351() -> void:
 # Head centre follows the actual upright sprite transform, including its side sway.
 var height: float=float(poses["airborne"].visible_height)/24.*.87
 var end: Vector3=visual.to_global(Vector3(0.,height,0.))
 thread351.clear_surfaces();thread351.surface_begin(Mesh.PRIMITIVE_LINES)
 thread351.surface_add_vertex(pivot351);thread351.surface_add_vertex(end);thread351.surface_end()
func animate351(t: float) -> void:
 var side: Vector3=battle.camera.global_basis.x
 var phase:=float(role110%2)*PI
 if travel351=="entry":
  global_position=destination351+Vector3.UP*pow(1.-t,2.)*10.+side*sin(t*TAU+phase)*(1.-t)*1.5
  _pose("airborne",0.);visual.rotation.z=sin(t*TAU+phase)*.16*(1.-t)
 elif travel351=="exit":
  var rise:=maxf(0.,(t-.14)/.86)
  global_position=departure351+Vector3.UP*rise*rise*13.+side*sin(rise*PI)*1.8*(1. if role110%2==0 else -1.)
  _pose("landing" if t<.14 else "airborne",0.)
  visual.rotation.z=sin(rise*TAU)*.20
 else:
  global_position=destination351+side*sin(t*TAU)*2.5+Vector3.UP*(2.+8.*pow(absf(t*2.-1.),2.))
  _pose("airborne",0.);visual.rotation.z=sin(t*TAU)*.23
 rope351();health_fill.hide()
func receive_hit(damage: float,direction: Vector3) -> void:
 if ambient351 or travel351!="":return
 super.receive_hit(damage,direction)
 if dead:
  travel351="exit";clock351=0.;departure351=global_position
  pivot351=departure351+Vector3.UP*15.
  collision_layer=0;collision_mask=0;hit_area.set_deferred("collision_layer",0)
  velocity=Vector3.ZERO;active_ai=false;silk351.show();set_physics_process(true)
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if ambient351:
  clock351+=delta;travel351="ambient";animate351(clock351/5.)
  if clock351>5.:queue_free()
  return
 if travel351!="":
  clock351+=delta
  var duration:=1.8 if travel351=="entry" else 1.55
  var t:=clampf(clock351/duration,0.,1.)
  animate351(t)
  if t>=1.:
   if travel351=="exit":queue_free();return
   global_position=destination351;travel351="";entry350=0.
   collision_layer=body_layer351;collision_mask=body_mask351;silk351.hide();play119();_render_legacy(0.)
  return
 super._physics_process(delta)
