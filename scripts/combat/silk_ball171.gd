extends "res://scripts/combat/tuantuan121.gd"
const SPEED171 := 2.25
const LIFE171 := 4.6
const UNRAVEL171 := .45
var direction171 := Vector2.DOWN
var clock171 := 0.
var fade171 := 0.
var travelled171 := 0.
var retired171 := false
var reason171 := ""
var strands171: Array[MeshInstance3D]=[]
func _ready() -> void:
 var entry: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/spider171/poses.json")).ball
 var texture: Texture2D=load("res://assets/spider171/ball.png")
 entry.scale=24.*.82/float(texture.get_width()-8)
 entry.visible_width=.82*24.;entry.visible_height=float(texture.get_height()-8)*entry.scale
 poses={};textures={}
 for key in ["idle","hit","defeated","landing","anticipation","airborne"]: poses[key]=entry;textures[key]=texture
 hp=1.;max_hp110=1.;touch110=10.
 super._ready()
 set_meta("silk_ball171",true);collision_layer=0;collision_mask=1|2
 mode119="playing";active_ai=false;hit_area.collision_layer=8
 var capsule: CapsuleShape3D=hit_area.get_child(0).shape;capsule.radius=.36;capsule.height=.72
 cue.set_process(false);cue.hide();small_cue.set_process(false);small_cue.hide();health_fill.hide()
 for i in 3:
  var strand := MeshInstance3D.new();var strip := ImmediateMesh.new()
  var ink := StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color("fff3da");ink.cull_mode=BaseMaterial3D.CULL_DISABLED
  strip.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP,ink)
  for j in 10:
   var t := float(j)/9.;var x := (t-.5)*.35;var y := sin(t*PI)*.13
   strip.surface_add_vertex(Vector3(x,y-.018,0.));strip.surface_add_vertex(Vector3(x,y+.018,0.))
  strip.surface_end();strand.mesh=strip;strand.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  add_child(strand);strand.hide();strands171.append(strand)
 _render_legacy(0.)
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift);visual.material_override=null;visual.offset=Vector2.ZERO;visual.position.y=.38;hit_area.position.y=.36;health_fill.hide()
func _render_legacy(_lift: float) -> void:
 if not is_instance_valid(visual): return
 _pose("idle",0.)
 var screen: Vector2=battle.screen_direction(position,Vector3(direction171.x,0.,direction171.y))
 visual.rotation.z=-travelled171/.41*(1. if screen.x>=0. else -1.)
 if retired171:
  var t := clampf(fade171/UNRAVEL171,0.,1.)
  visual.scale=Vector3(1.+t*.30,1.-t*.70,1.);visual.transparency=t
  for i in strands171.size():
   var strand: MeshInstance3D=strands171[i];strand.show();strand.basis=battle.camera.global_basis
   var side := float(i)-1.;strand.position=Vector3(side*t*.45,.15+sin(t*PI)*.2,0.)
   strand.scale=Vector3.ONE*(1.-t)
func retire171(reason: String) -> void:
 if retired171: return
 retired171=true;reason171=reason;dead=true;hp=0.;velocity=Vector3.ZERO
 hit_area.collision_layer=0;collision_layer=0
 if reason=="shot": battle.silk_clears171+=1
func receive_hit(damage: float,_direction: Vector3) -> void:
 if retired171 or damage<=0.: return
 hit_count+=1;battle.notify_hit();retire171("shot")
func whip(_direction: Vector3) -> void: pass
func deflect(_contact: Vector3) -> void: retire171("parry")
func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 if not battle.active114 or battle.player_hp<=0.: battle.remove_silk171(self);return
 if retired171:
  fade171+=delta;_render_legacy(0.)
  if fade171>=UNRAVEL171: battle.remove_silk171(self)
  return
 clock171+=delta
 if clock171>=LIFE171: retire171("timeout");return
 var before := position
 velocity=Vector3(direction171.x*SPEED171,-.3 if is_on_floor() else velocity.y-20.*delta,direction171.y*SPEED171)
 move_and_slide();travelled171+=Vector2(position.x-before.x,position.z-before.z).length()
 if is_on_wall(): retire171("wall");return
 if before.distance_to(position)<delta*.10: retire171("blocked");return
 if defense171(before): _render_legacy(0.);return
 var player := Vector2(battle.hero.position.x,battle.hero.position.z)
 var crossed: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,.70)
 if crossed<INF and absf(position.y-battle.hero.position.y)<.65:
  if battle.hero.can_parry(): retire171("parry")
  else:
   retire171("touch");battle.hurt_player(touch110,Vector2(position.x,position.z))
 _render_legacy(0.)
func defense171(_before: Vector3) -> bool: return false
