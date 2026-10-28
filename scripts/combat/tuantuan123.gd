extends "res://scripts/combat/tuantuan122.gd"
# Ordinary actors only. Peer damage bypasses player-hit rewards and cannot defeat.
const ROLL_TIME := .52
const CHEER_TIME := .65
const SHOVE_TIME := 3.2
const PEER_DAMAGE := .08
var play_state123 := ""
var play_clock123 := 0.
var peer123: CharacterBody3D
var peer_cooldown123 := 0.
var shove_tick123 := 0
var roll_count123 := 0
var quarrel_count123 := 0
var player_breaks123 := 0

func available123() -> bool:
 return not dead and not roam122 and rank110==0 and mode119=="playing" and active_ai

func clear_play123() -> void:
 play_state123="";play_clock123=0.;peer123=null
 visual.rotation=Vector3.ZERO;attack_phase="recover";phase_clock=0.;hopping=false
 peer_cooldown123=1.8;collision_mask=1|2|16

func receive_hit(damage: float,direction: Vector3) -> void:
 if available123() and damage>0. and play_state123!="":
  player_breaks123+=1;clear_play123()
 super.receive_hit(damage,direction)

func deflect(contact: Vector3) -> void:
 if play_state123!="": clear_play123()
 super.deflect(contact)

func _begin_windup(target: Vector2) -> void:
 super._begin_windup(target)
 # Actor separation must not stop a lunge before its swept peer contact is tested.
 collision_mask=1|2

func begin_roll123() -> void:
 play_state123="roll";play_clock123=0.;roll_count123+=1
 attack_phase="recover";hopping=true;hop_clock=.1;landing_left=0.;collision_mask=1|2|16

func begin_quarrel123(other: CharacterBody3D) -> void:
 peer123=other;play_state123="cheer";play_clock123=0.;shove_tick123=0
 quarrel_count123+=1;attack_phase="recover";hopping=false;impulse=Vector2.ZERO
 collision_mask=1|2|16
 if is_instance_valid(cue): cue.hide()
 if is_instance_valid(small_cue): small_cue.hide()

func peer_contact123(before: Vector3) -> bool:
 if peer_cooldown123>0.: return false
 for other in battle.enemies:
  if other==self or not is_instance_valid(other) or not other.has_method("available123"): continue
  if not other.available123() or other.play_state123!="" or other.peer_cooldown123>0.: continue
  if absf(position.y-other.position.y)>.65: continue
  var t: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),Vector2(other.position.x,other.position.z),.78)
  if t<INF:
   begin_quarrel123(other);other.begin_quarrel123(self);return true
 return false

func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 peer_cooldown123=maxf(0.,peer_cooldown123-delta)
 if not available123():
  if play_state123!="": clear_play123()
  super._physics_process(delta);return
 if play_state123!="":
  if battle.wave_state!="fighting" or battle.player_hp<=0.:
   clear_play123();super._physics_process(delta);return
  _step_play123(delta);return
 var previous := attack_phase
 var before := position
 super._physics_process(delta)
 if not available123(): return
 if previous=="lunge" and parry_stun<=0.:
  if not attack_connected and peer_contact123(before): return
  if attack_phase=="recover" and not attack_connected: begin_roll123()
 if attack_phase!="lunge": collision_mask=1|2|16

func _step_play123(delta: float) -> void:
 _step_response121(delta);play_clock123+=delta
 var motion := Vector2.ZERO
 var lift := 0.
 if play_state123=="roll":
  var t := clampf(play_clock123/ROLL_TIME,0.,1.)
  motion=attack_direction*4.2*(1.-t)
  lift=sin(t*PI)*.14;hopping=true;hop_clock=.1
  var before := position
  _move_play123(motion,delta);_render_legacy(lift)
  if peer_contact123(before): return
  # The bounded roll always settles even when scenery blocks translation.
  if t>=1.: clear_play123();_render_legacy(0.)
  return
 if not is_instance_valid(peer123) or not peer123.available123() or peer123.peer123!=self or peer123.play_state123 not in ["cheer","shove"]:
  clear_play123();_render_legacy(0.);return
 var offset := Vector2(peer123.position.x-position.x,peer123.position.z-position.z)
 if offset.length()>3.:
  clear_play123();_render_legacy(0.);return
 if play_state123=="cheer":
  lift=absf(sin(play_clock123/CHEER_TIME*TAU))* .19
  hopping=true;hop_clock=.1
  if play_clock123>=CHEER_TIME: play_state123="shove";play_clock123=0.;hopping=false
 else:
  var cycle := fmod(play_clock123,.62)/.62
  var push := sin(cycle*TAU)
  motion=offset.normalized()*push*.65 if offset.length()<1.1 else offset.normalized()*1.1
  var tick := int(play_clock123/.62)
  if tick>shove_tick123:
   shove_tick123=tick
   if offset.length()<1.3:
    peer123.hp=maxf(minf(peer123.hp,1.),peer123.hp-PEER_DAMAGE)
    peer123.health_time=.7;peer123.squeeze=minf(.16,peer123.squeeze+.06)
  if play_clock123>=SHOVE_TIME: clear_play123();_render_legacy(0.);return
 _move_play123(motion,delta);_render_legacy(lift)

func _move_play123(motion: Vector2,delta: float) -> void:
 velocity=Vector3(motion.x+impulse.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y+impulse.y)
 impulse*=maxf(0.,1.-Profile.KNOCK_DECAY*delta);move_and_slide()

func _render_legacy(lift: float) -> void:
 if is_instance_valid(visual):
  visual.rotation=Vector3.ZERO;visual.billboard=BaseMaterial3D.BILLBOARD_FIXED_Y
 if soft_ink!=null:
  var ink: Shader=preload("res://scripts/combat/soft_body123.gdshader") if play_state123=="roll" and not dead else preload("res://scripts/combat/soft_body32.gdshader")
  if soft_ink.shader!=ink: soft_ink.shader=ink
 super._render_legacy(lift)
 if dead or play_state123=="": return
 if play_state123=="roll":
  var t := clampf(play_clock123/ROLL_TIME,0.,1.)
  var screen_right: Vector3=battle.camera.global_basis.x
  var sign_roll := -1. if Vector3(attack_direction.x,0.,attack_direction.y).dot(screen_right)>=0. else 1.
  var angle := sign_roll*TAU*(1.-pow(1.-t,1.5))
  var entry: Dictionary=poses.airborne
  var size := visual.texture.get_size()
  var centre := Vector2(float(entry.foot[0]),float(entry.foot[1])-float(entry.visible_height)/48./visual.pixel_size)/size
  soft_ink.set_shader_parameter("roll_angle123",angle)
  soft_ink.set_shader_parameter("roll_center123",centre)
  visual.scale*=Vector3(1.+sin(t*PI)*.08,1.-sin(t*PI)*.08,1.)
 elif play_state123=="shove":
  var beat := sin(play_clock123/.62*TAU)
  visual.scale*=Vector3(1.+maxf(0.,beat)*.12,1.-maxf(0.,beat)*.1,1.)
  if is_instance_valid(peer123):
   var screen: float= battle.camera.global_basis.x.dot(peer123.position-position)
   visual.rotation.z=(-1. if screen>0. else 1.)*(.10+beat*.06)

