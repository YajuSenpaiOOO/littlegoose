extends "res://scripts/combat/tuantuan121.gd"
const PREPARE170 := .80
const POUNCE170 := .55
const RECOVER170 := 1.25
var state170 := "watch"
var clock170 := 0.
var wait170 := .8
var lift170 := 0.
var hop170 := Vector2.ZERO
var target170 := Vector2.ZERO
var jump_from170 := Vector2.ZERO
var hops170 := 0
var recoveries170 := 0
var marker170: MeshInstance3D
var art170 := {}
func _ready() -> void:
 art170=JSON.parse_string(FileAccess.get_file_as_string("res://assets/spider170/poses.json"))
 poses=poses.duplicate(true);textures=textures.duplicate()
 for key in poses.keys():
  var source: String=key if art170.has(key) else ("landing" if key=="defeated" else "idle")
  poses[key]=art170[source];textures[key]=load("res://assets/spider170/"+source+".png")
 super._ready()
 cue.set_process(false);cue.hide();small_cue.set_process(false);small_cue.hide()
 marker170=MeshInstance3D.new();marker170.top_level=true
 var ring := TorusMesh.new();ring.inner_radius=.62;ring.outer_radius=.70;ring.rings=24;ring.ring_segments=8;marker170.mesh=ring
 var ink := StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color("ffd28a")
 marker170.material_override=ink;marker170.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(marker170);marker170.hide()
 collision_mask=1|2
 _render_legacy(0.)
func play119() -> void:
 super.play119();state170="watch";clock170=0.;wait170=.65+role110*.24;lift170=0.;impulse=Vector2.ZERO
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift)
 # Standard sprite follows the existing world tint and terrain shadow path.
 visual.material_override=null
 hit_area.position.y=.60+lift
 health_fill.position.y=1.3+lift
func _render_legacy(lift: float) -> void:
 if not is_instance_valid(visual): return
 var key := "idle"
 if dead or state170=="recover": key="landing"
 elif state170=="prepare" or state170=="crouch": key="anticipation"
 elif state170 in ["hop","pounce"]: key="airborne"
 _pose(key,lift)
 visual.rotation.z=0.
 if state170=="prepare":
  var t := clampf(clock170/PREPARE170,0.,1.);visual.scale=Vector3(1.+.10*t,1.-.10*t,1.)
 elif state170=="recover" and not dead:
  var t := clampf(clock170/RECOVER170,0.,1.)
  visual.rotation.z=sin(t*TAU*2.)*.14*(1.-t)
  visual.scale=Vector3(1.+.06*sin(t*PI),1.-.06*sin(t*PI),1.)
 elif state170=="watch": visual.scale.y=1.+sin(age*3.+role110)*.018
 if is_instance_valid(marker170):
  marker170.visible=not dead and active_ai and battle.wave_state=="fighting" and state170 in ["prepare","pounce"]
  if marker170.visible:
   marker170.global_position=Vector3(target170.x,battle.floor_height(target170)+.045,target170.y)
   marker170.scale=Vector3(1.,.10,1.)
 if is_instance_valid(cue): cue.hide()
 if is_instance_valid(small_cue): small_cue.hide()
func receive_hit(damage: float,direction: Vector3) -> void:
 super.receive_hit(damage,direction)
 impulse=impulse.limit_length(.65)
 if dead and is_instance_valid(marker170): marker170.hide()
func deflect(contact: Vector3) -> void:
 super.deflect(contact);enter170("recover");lift170=0.
func enter170(next: String) -> void:
 state170=next;clock170=0.
 attack_phase="windup" if next=="prepare" else ("lunge" if next=="pounce" else ("recover" if next=="recover" else "approach"))
 if next=="recover": recoveries170+=1;lift170=0.;attack_connected=true;landing_left=.18
func prepare170(player: Vector2) -> void:
 jump_from170=Vector2(position.x,position.z)
 var distance := (player-jump_from170).limit_length(5.5)
 target170=jump_from170+distance
 attack_direction=distance.normalized();attack_distance=distance.length();attack_connected=false;attacks_started+=1
 impulse=Vector2.ZERO;enter170("prepare")
func begin_hop170(player: Vector2) -> void:
 var at := Vector2(position.x,position.z)
 var away := (at-player).normalized()
 if away.length_squared()<.01: away=Vector2.RIGHT
 var goal := player+away.rotated((.55 if (hops170+role110)%2==0 else -.55))*3.0
 route=battle.navigation.path(at,goal)
 while not route.is_empty() and at.distance_to(route[0])<.35: route.remove_at(0)
 hop170=(route[0]-at).normalized() if not route.is_empty() else Vector2.ZERO
 hops170+=1;enter170("crouch")
func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 if dead or mode119!="playing": super._physics_process(delta);return
 _step_response121(delta)
 if not active_ai or battle.player_hp<=0. or battle.wave_state!="fighting":
  if is_instance_valid(marker170): marker170.hide()
  return
 clock170+=delta;phase_clock=clock170
 var at := Vector2(position.x,position.z);var player := Vector2(battle.hero.position.x,battle.hero.position.z)
 var motion := Vector2.ZERO;lift170=0.
 match state170:
  "watch":
   if clock170>=wait170:
    if at.distance_to(player)<=5.5 and absf(position.y-battle.hero.position.y)<.65 and battle.line_clear110(at,player) and battle.reserve_spider170(self): prepare170(player)
    else: begin_hop170(player)
  "crouch":
   if clock170>=.16: enter170("hop")
  "hop":
   var t := clampf(clock170/.38,0.,1.)
   motion=hop170*4.2*sin(t*PI)*float(get_meta("locomotion_scale153",1.));lift170=sin(t*PI)*.32
   if t>=1.: enter170("watch");wait170=.35+float(role110%3)*.11
  "prepare":
   if clock170>=PREPARE170: enter170("pounce");attack_connected=false
  "pounce":
   var t := clampf(clock170/POUNCE170,0.,1.)
   motion=(target170-jump_from170)/POUNCE170;lift170=sin(t*PI)*.95
   if t>=1.: enter170("recover");motion=Vector2.ZERO
  "recover":
   if clock170>=RECOVER170: enter170("watch");wait170=.70
 var before := position
 var recoil := impulse if state170 not in ["prepare","pounce"] else Vector2.ZERO
 velocity=Vector3(motion.x+recoil.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y+recoil.y)
 impulse*=maxf(0.,1.-8.*delta);move_and_slide()
 if state170=="pounce" and not attack_connected:
  if _try_parry_attack(before): _render_legacy(lift170);return
  var crossed: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,.72)
  if crossed<INF and lift170<.65 and absf(position.y-battle.hero.position.y)<.65:
   attack_connected=true;attack_landings+=1;battle.hurt_player(touch110,Vector2(position.x,position.z))
 _render_legacy(lift170)
