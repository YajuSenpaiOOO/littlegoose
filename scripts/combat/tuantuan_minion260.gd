extends "res://scripts/combat/tuantuan128.gd"
var state260 := "enter"
var clock260 := 0.
var from260 := Vector2.ZERO
var goal260 := Vector2.ZERO
var projection260: MeshInstance3D
func _ready() -> void:
 super._ready();mode119="playing";active_ai=true;collision_layer=0;hit_area.collision_layer=0
 shadow.hide();cue.hide();small_cue.hide()
func available123() -> bool:return state260=="ground" and super.available123()
func targetable260() -> bool:return not dead and state260 in ["ground","dazed"]
func receive_hit(damage: float,direction: Vector3) -> void:
 if not targetable260():return
 var before=hp;super.receive_hit(damage,direction)
 var dealt=maxf(0.,before-maxf(0.,hp))
 if dealt>0.:battle.record_enemy_damage226(self,dealt)
func deflect(contact: Vector3) -> void:
 if not targetable260():return
 var source=battle.parry_kind260;battle.parry_kind260="minion";super.deflect(contact);battle.parry_kind260=source
func ground260() -> void:
 state260="ground";clock260=0.;collision_layer=16;collision_mask=1|2|16;hit_area.collision_layer=8
 play119();battle.target_minion260(self,true)
func toss260(origin: Vector2) -> bool:
 if dead or state260 not in ["ground","dazed"]:return false
 if play_state123!="":clear_play123()
 state260="air";clock260=0.;hopping=false;attack_phase="recover";attack_connected=true;parry_stun=0.;parry_lift=0.;impulse=Vector2.ZERO
 collision_layer=0;collision_mask=1|2;hit_area.collision_layer=0;cue.hide();small_cue.hide()
 from260=Vector2(position.x,position.z)
 var away=from260-origin
 if away.length()<.05:away=Vector2.RIGHT.rotated(float(role110)*2.4)
 goal260=battle.safe_goal247(from260,from260+away.normalized()*3.2)
 battle.target_minion260(self,false)
 return true
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if dead:super._physics_process(delta);shadow.hide();return
 if not battle.active114:return
 clock260+=delta
 if state260=="enter":
  _step_response121(delta);_render_legacy(absf(sin(clock260/.85*PI*2.))*.16);shadow.hide()
  if clock260>=.85:ground260()
  return
 if state260=="air":
  _step_response121(delta)
  var t=clampf(clock260/.62,0.,1.);var at=from260.lerp(goal260,t)
  var motion=(at-Vector2(position.x,position.z))/maxf(delta,.001)
  velocity=Vector3(motion.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y);move_and_slide()
  hopping=true;hop_clock=.12;_render_legacy(4.*.95*t*(1.-t));visual.rotation.z=sin(t*PI)*.30;shadow.hide()
  if t>=1.:
   state260="dazed";clock260=0.;velocity=Vector3.ZERO;landing_left=.12;hit_area.collision_layer=8;battle.target_minion260(self,true)
  return
 if state260=="dazed":
  _step_response121(delta);_render_legacy(0.);visual.scale*=Vector3(1.12,.75,1.);visual.rotation.z=sin(clock260*15.)*.07;shadow.hide()
  if clock260>=.90:ground260()
  return
 if rest_with_boss260():
  if play_state123!="":clear_play123()
  attack_phase="recover";phase_clock=0.;hopping=false;velocity=Vector3.ZERO
  _step_response121(delta);_render_legacy(absf(sin(clock260*3.))*.035);cue.hide();small_cue.hide();shadow.hide();return
 var source=battle.damage_source226;battle.damage_source226="tuantuan_minion"
 super._physics_process(delta);battle.damage_source226=source;shadow.hide()

func rest_with_boss260() -> bool:return is_instance_valid(battle.boss247) and battle.boss247.phase247 in ["flat","bumper"]
