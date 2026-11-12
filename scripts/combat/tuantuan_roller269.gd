extends "res://scripts/combat/tuantuan_minion268.gd"
var roll_state269 := "wait"
var timer269 := 0.
var direction269 := Vector2.RIGHT
var distance269 := 0.
var bounces269 := 0
var wall_gate269 := 0.
var stuck269 := 0.
var reflected269 := false
func _ready() -> void:
 super._ready()
 compose_flower270("boss");_render_legacy(0.)
func enter269(next: String) -> void:
 roll_state269=next;timer269=0.;play_state123="";hopping=false;attack_phase="recover";phase_clock=0.
 if next=="charge":
  direction269=(Vector2(battle.hero.position.x,battle.hero.position.z)-Vector2(position.x,position.z)).normalized()
  if direction269.length()<.5:direction269=Vector2.RIGHT
  attack_direction=direction269;attack_phase="windup";distance269=0.;bounces269=0;reflected269=false;attack_connected=false;stuck269=0.;wall_gate269=0.
 if next=="rolling":attack_phase="lunge";play_state123="roll"
 battle.telemetry260.event("roller_state",{"state":next})
func deflect(contact: Vector3) -> void:
 if roll_state269!="rolling":super.deflect(contact);return
 super.deflect(contact);direction269=-direction269;reflected269=true;distance269=maxf(distance269,10.);impulse=Vector2.ZERO
 attack_phase="lunge";play_state123="roll";battle.roller_stats269.parries+=1
func actor_contact271(_actor: Object,_normal: Vector2) -> bool:return false
func _physics_process(delta: float) -> void:
 if dead or state260!="ground":super._physics_process(delta);return
 if battle.combat_paused or not battle.active114:return
 timer269+=delta;wall_gate269=maxf(0.,wall_gate269-delta);_step_response121(delta)
 var before=position;var motion=Vector2.ZERO
 if roll_state269=="wait" and timer269>=1.1:enter269("charge")
 elif roll_state269=="charge":
  phase_clock=timer269;attack_direction=direction269
  if timer269>=.8:enter269("rolling")
 elif roll_state269=="rolling":
  play_state123="roll";attack_phase="lunge"
  motion=direction269*lerpf(7.2,5.8,clampf(distance269/14.,0.,1.));attack_direction=direction269
 elif roll_state269=="dizzy" and timer269>=1.8:enter269("wait")
 velocity=Vector3(motion.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y);move_and_slide()
 if roll_state269=="rolling":
  var travelled=Vector2(position.x-before.x,position.z-before.z).length();distance269+=travelled
  stuck269=stuck269+delta if travelled<.005 else 0.
  if wall_gate269<=0.:
   for i in get_slide_collision_count():
    var normal=get_slide_collision(i).get_normal()
    if absf(normal.y)>.4:continue
    var planar=Vector2(normal.x,normal.z).normalized()
    if direction269.dot(planar)>=-.1:continue
    if actor_contact271(get_slide_collision(i).get_collider(),planar):break
    direction269=direction269.bounce(planar).normalized();bounces269+=1;wall_gate269=.14
    battle.roller_stats269.bounces+=1;break
  if roll_state269!="rolling":_render_legacy(0.);return
  if not reflected269 and not attack_connected:
   if not _try_parry_attack(before):
    var player=Vector2(battle.hero.position.x,battle.hero.position.z)
    if absf(position.y-battle.hero.position.y)<.65 and battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,.82)<INF:
     attack_connected=true
     var source=battle.damage_source226;battle.damage_source226="tuantuan_roller"
     battle.hurt_player(1.,Vector2(position.x,position.z));battle.damage_source226=source
  play_clock123=fmod(timer269,.52);hop_clock=.1;hopping=true
  if distance269>=14. or bounces269>=2 or timer269>=3.5 or stuck269>.3:
   enter269("dizzy");battle.roller_stats269.stuns+=1
 _render_legacy(.06 if roll_state269=="rolling" else 0.);shadow.hide()
 if roll_state269=="charge":visual.rotation.z+=sin(timer269*30.)*.025
 if roll_state269=="dizzy":
  visual.rotation.z=sin(timer269*8.)*.10
