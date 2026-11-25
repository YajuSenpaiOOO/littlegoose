extends "res://scripts/combat/silk_ball172.gd"
var start353:=Vector3.ZERO
var goal353:=Vector3.ZERO
var age353:=0.
var duration353:=1.15
var resolved353:=false
var marker353: MeshInstance3D
func _ready() -> void:
 super._ready()
 set_meta("air_target353",true)
 max_hp110=1.;hp=1.;touch110=1.
 var shape: CapsuleShape3D=hit_area.get_child(0).shape;shape.radius=.5;shape.height=1.
 marker353=MeshInstance3D.new();marker353.top_level=true
 var ring:=TorusMesh.new();ring.inner_radius=1.06;ring.outer_radius=1.13;ring.rings=24;ring.ring_segments=8;marker353.mesh=ring
 var ink:=StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color(.9,.78,.58,.6);ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 marker353.material_override=ink;marker353.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(marker353)
 marker353.global_position=Vector3(goal353.x,battle.floor_height(Vector2(goal353.x,goal353.z))+.035,goal353.z)
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift)
 visual.pixel_size*=1.4
 visual.position.y=0.;hit_area.position.y=0.
func retire171(reason: String) -> void:
 super.retire171(reason)
 if is_instance_valid(marker353):marker353.hide()
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if not battle.active114 or battle.player_hp<=0.:battle.remove_silk171(self);return
 if retired171:
  fade171+=delta;_render_legacy(0.)
  if fade171>=UNRAVEL171:battle.remove_silk171(self)
  return
 age353+=delta
 var t:=clampf(age353/duration353,0.,1.)
 var before:=global_position
 global_position=start353.lerp(goal353,t)
 global_position.y=lerpf(start353.y,goal353.y,t*t)+sin(t*PI)*.35
 velocity=(global_position-before)/maxf(.001,delta)
 travelled171+=before.distance_to(global_position)
 _render_legacy(0.)
 marker353.scale=Vector3.ONE*lerpf(.65,1.,t)
 if t>=1. and not resolved353:
  resolved353=true
  battle.resolve_bomb353(self)
  retire171("impact")
