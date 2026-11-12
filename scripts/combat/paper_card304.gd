extends "res://scripts/combat/paper_card303.gd"
var support304 := 0.
var previous_support304 := 0.
var ring304 := Vector2.ZERO
var ring_velocity304 := Vector2.ZERO
var contact_gate304 := 0.
var launches304 := 0
var ring_limit304 := 4.
func launch_speed304() -> float:return 23.
func fire_script303() -> Script:return preload("res://scripts/art/paper_fire304.gd")
func enter301(next: String) -> void:
 super.enter301(next)
 if not ready303:return
 if next=="warn" and kind301=="dinosaur":direction301=Vector2(1. if battle.hero.position.x>mouth303().x else -1.,0.)
 if next=="attack" and kind301=="knight":ring304=Vector2.ZERO;ring_velocity304=direction301*launch_speed304();contact_gate304=0.
func pose302() -> void:
 super.pose302()
 if not ready303:return
 if kind301=="monster":operator301.position.y+=support304
 if kind301=="knight" and state301=="warn":
  var tension=smoothstep(0.,1.35,clock301)
  visual.position.y=.04;visual.rotation.z=0.
  operator301.position+=Vector3(direction301.x, .32,direction301.y)*tension*3.
 if kind301=="knight" and state301 in ["attack","stunned","recover"]:
  visual.position+=Vector3(ring304.x,0,ring304.y)
 hit_area.position=visual.transform*Vector3(0,height301*.5,0);hit_area.rotation.z=visual.rotation.z
func vertical_step303(delta: float) -> void:
 # The moving upper paper drives a slack/tension spring; no self-jump pulses.
 var driving=state301 in ["warn","attack"]
 var count=maxi(1,int(ceil(delta*120.)));var dt=delta/count
 for i in count:
  var target_support=(sin(age*20.)*.38+sin(age*31.+.6)*.13) if driving else 0.
  var support_speed=(target_support-support304)/maxf(dt,.001)
  support304=target_support
  var extension=HOVER302+support304-height303
  var pull=maxf(0.,extension*145.+(support_speed-vertical303)*2.8)
  vertical303+=(pull-18.-vertical303*1.4)*dt;height303+=vertical303*dt
  if height303<.12:
   height303=.12;vertical303=maxf(0.,vertical303)*.15
   if driving and contact_gate304<=0.:
    landings303+=1;connected301=false
    if Vector2(battle.hero.position.x,battle.hero.position.z).distance_to(attack_at301())<1.5:contact303(attack_at301())
    contact_gate304=.45
  height303=minf(height303,1.55)
 phase303="driven"
 if state301=="attack" and height303<.45 and vertical303< -1.6 and contact_gate304<=0.:
  connected301=false;landings303+=1;contact_gate304=.45
  if Vector2(battle.hero.position.x,battle.hero.position.z).distance_to(attack_at301())<1.5:contact303(attack_at301())
func _physics_process(delta: float) -> void:
 if not ready303 or dead or battle.combat_paused:
  super._physics_process(delta);return
 contact_gate304=maxf(0.,contact_gate304-delta)
 if kind301=="dinosaur":
  if state301=="rest" and absf(position.z-battle.hero.position.z)>.6:clock301=minf(clock301,.9)
  super._physics_process(delta);return
 if kind301=="monster":
  super._physics_process(delta)
  if state301=="attack" and clock301>monster_attack_duration304():enter301("recover")
  return
 if not battle.active114:cue301.hide();return
 clock301+=delta;age+=delta;flash=maxf(0.,flash-delta);health_time=maxf(0.,health_time-delta);juice_gate=maxf(0.,juice_gate-delta)
 var motion=Vector2.ZERO
 match state301:
  "enter":
   if clock301>.85:hit_area.collision_layer=8;enter301("rest")
  "rest":
   var player=Vector2(battle.hero.position.x,battle.hero.position.z);var at=Vector2(position.x,position.z)
   motion=(player+(at-player).normalized()*3.-at).limit_length(1.)*1.6
   if clock301>1.3:enter301("warn")
  "warn":
   if clock301>=charge_duration304() and can_release303():enter301("attack")
  "attack":
   step_ring304(delta)
   if clock301>2.8:enter301("recover")
  "recover","stunned":
   settle_ring304(delta)
   if clock301>1.5:enter301("rest")
 var before=attack_at301();move301(motion,delta);pose302()
 if state301=="attack" and contact_gate304<=0. and can_ring_contact304():
  var player=Vector2(battle.hero.position.x,battle.hero.position.z)
  if battle.aim_model.sweep_circle(before,attack_at301(),player,.85)<=1.:
   connected301=false;contact303(attack_at301());contact_gate304=.65
 render301()
func contact303(at: Vector2) -> void:
 var before=battle.player_hp
 super.contact303(at)
 if kind301=="knight" and battle.player_hp<before:
  var away=ring_velocity304.normalized()
  if away.length()<.1:away=direction301
  battle.launch_player304(away);launches304+=1
func draw_cue301() -> void:
 if kind301=="knight" and state301=="attack":returned303=false
 super.draw_cue301()

func step_ring304(delta: float) -> void:
 var n=maxi(1,int(ceil(delta*120.)));var dt=delta/n
 for i in n:
  ring_velocity304+=(-ring304*28.-ring_velocity304*1.5)*dt;ring304+=ring_velocity304*dt
 ring304=ring304.limit_length(ring_limit304)
 var end=position+Vector3(ring304.x,.8,ring304.y)
 var wall=get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position+Vector3.UP*.8,end,1|2))
 if not wall.is_empty():
  var offset=wall.position-position;ring304=Vector2(offset.x,offset.z).limit_length(maxf(0.,Vector2(offset.x,offset.z).length()-.65));ring_velocity304*=-.25

func settle_ring304(delta: float) -> void:
 ring304*=exp(-delta*4.)

func monster_attack_duration304() -> float: return 2.2
func charge_duration304() -> float:return 1.35
func can_ring_contact304() -> bool:return true
