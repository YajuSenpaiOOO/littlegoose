extends "res://scripts/combat/tuantuan76.gd"
var rank110 := 0 # 0 ordinary, 1 elite, 2 king
var max_hp110 := 12.
var body_scale110 := 1.
var speed110 := 1.
var touch110 := 20.
var behaviors110: Array=[]
var role110 := 0
var flower110: Sprite3D
var estate110 := "chase"
var timer110 := 0.
var attack_wait110 := 1.2
var lift110 := 0.
var locked110 := Vector2.ZERO
var strike110 := Vector2.DOWN
var leaps110 := 0
var crashes110 := 0
var force_strike110 := ""
var strikes110 := {"dash":0,"slam":0,"charge":0}
var swept110 := {}
var dodge_wait110 := 0.
var feedback_frame110 := -1
var hop_i110 := 0
var hop_boost110 := 1.
func _ready() -> void:
 super._ready()
 var physical: CapsuleShape3D=get_child(0).shape
 physical.radius=.35*body_scale110;physical.height=.8*body_scale110;get_child(0).position.y=.4*body_scale110
 var target: CapsuleShape3D=hit_area.get_child(0).shape
 target.radius=.52*body_scale110;target.height=1.6*body_scale110
 if rank110>0:
  var spec: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_v2/flowers.json"))["boss" if rank110==2 else "elite"]
  flower110=Sprite3D.new();flower110.texture=load(spec.texture);flower110.pixel_size=float(spec.scale)/24.*body_scale110
  flower110.offset=flower110.texture.get_size()*.5-Vector2(spec.center[0],spec.center[1]);flower110.offset.y=-flower110.offset.y
  flower110.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;flower110.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  add_child(flower110)
 _pose("idle",0.)
func _pose(key: String,lift: float) -> void:
 super._pose(key,lift)
 visual.pixel_size*=body_scale110
 hit_area.position.y=(.8*body_scale110 if not dead else .43)
 health_fill.position=Vector3(-.45*(1.-hp/max_hp110),1.55*body_scale110+lift,0.)
 health_fill.scale.x=maxf(.001,hp/max_hp110)
 if is_instance_valid(flower110):
  flower110.position=visual.position+Vector3(.18*body_scale110,float(poses[key].visible_height)/24.*body_scale110-.09,0.015)
  flower110.modulate=visual.modulate;flower110.rotation=visual.rotation
func receive_hit(damage: float,direction: Vector3) -> void:
 var frame := Engine.get_process_frames()
 if not dead and hp>damage and (frame==feedback_frame110 or not battle.reserve_feedback110()):
  hp-=damage;hit_count+=1;health_time=1.5;flash=Profile.FLASH
  hit_direction=direction.normalized()
  if hit_rearm<=0.: hit_left=Profile.HIT_POSE;hit_rearm=Profile.HIT_REARM
  var before := impulse
  impulse=(impulse*.35+Vector2(direction.x,direction.z).normalized()*Profile.KNOCK).limit_length(Profile.KNOCK_MAX)
  if rank110>0: impulse=before+(impulse-before)*(.08 if rank110==2 else .35)
  battle.feedback_count+=1
  if not battle.cup_contact_active: battle.notify_hit()
  impact_contact=Vector3.INF;return
 feedback_frame110=frame
 var previous := impulse
 super.receive_hit(damage,direction)
 if rank110>0 and not dead: impulse=previous+(impulse-previous)*(.08 if rank110==2 else .35)
func _pursue110(player: Vector2) -> Vector2:
 if "flank" in behaviors110 and role110%2==1:
  var away := (Vector2(position.x,position.z)-player).normalized()
  return player+away.rotated(.95 if role110%4==1 else -.95)*2.5
 return player
func _steer110(wish: Vector2) -> Vector2:
 var at := Vector2(position.x,position.z);var direction := wish
 if "pack" in behaviors110:
  for other in battle.near_enemies110(at,2.):
   if other==self: continue
   var away := at-Vector2(other.position.x,other.position.z)
   if away.length_squared()>.01: direction+=away.normalized()*.35
 if "sidestep" in behaviors110:
  for shot in battle.shots:
   var incoming := at-Vector2(shot.node.position.x,shot.node.position.z)
   var forward := Vector2(shot.velocity.x,shot.velocity.z).normalized()
   if incoming.length()<3. and incoming.dot(forward)>0. and absf(incoming.cross(forward))<.75:
    direction+=forward.orthogonal()*(1. if role110%2 else -1.);break
 return direction.normalized()
func _physics_process(delta: float) -> void:
 if rank110>0 and not dead:
  _rank_step110(delta);return
 if not battle.tactical_combat or dead:
  super._physics_process(delta)
  return
 if battle.combat_paused: return
 parry_stun=maxf(0.,parry_stun-delta)
 _step_soft_response(delta)
 _step_squeeze(delta)
 age+=delta; phase_clock+=delta
 hit_left=maxf(0.,hit_left-delta); hit_rearm=maxf(0.,hit_rearm-delta)
 landing_left=maxf(0.,landing_left-delta); flash=maxf(0.,flash-delta)
 health_time=maxf(0.,health_time-delta); juice_gate=maxf(0.,juice_gate-delta)
 var at := Vector2(global_position.x,global_position.z)
 var player := Vector2(battle.hero.global_position.x,battle.hero.global_position.z)
 var pursue := _pursue110(player)
 var engaged: bool=active_ai and battle.player_hp>0. and player.distance_to(home)<_engagement_radius33() and battle.wave_state=="fighting"
 var motion := Vector2.ZERO
 var lift := 0.
 if not engaged:
  attack_phase="approach"; phase_clock=0.; hopping=false
 elif attack_phase=="approach":
  if not hopping and phase_clock>=0. and at.distance_to(player)<=4.6 and battle.reserve_attack(self):
   _begin_windup(player)
  else:
   path_clock-=delta
   if path_clock<=0.: route=battle.navigation.path(at,pursue); path_clock=.35
   while route.size()>1 and at.distance_to(route[0])<.65: route.remove_at(0)
   if not hopping and phase_clock>=.12:
    hop_direction=(route[0]-at).normalized() if not route.is_empty() else (pursue-at).normalized()
    hop_direction=_steer110(hop_direction);hop_i110+=1;hop_boost110=_hop_boost110()
    hopping=true; hop_clock=0.
   if hopping:
    hop_clock+=delta
    var progress := clampf(hop_clock/.40,0.,1.)
    motion=hop_direction*Profile.HOP_SPEED*speed110*hop_boost110*sin(progress*PI)*float(get_meta("locomotion_scale153",1.))
    lift=sin(progress*PI)*.24
    if progress>=1.:
     hopping=false; phase_clock=0.; landing_left=.09
     squeeze=minf(.16,squeeze+.045); squeeze_velocity=-.2
 elif attack_phase=="windup":
  _update_windup_target(player)
  if phase_clock>=WINDUP:
   attack_phase="lunge"; phase_clock=0.
   battle.Audio.play("dash",.8)
 elif attack_phase=="lunge":
  var progress := clampf(phase_clock/LUNGE,0.,1.)
  motion=attack_direction*attack_distance/LUNGE
  lift=sin(progress*PI)*.60
  if phase_clock>=LUNGE:
   attack_phase="recover"; phase_clock=0.; motion=Vector2.ZERO; lift=0.
   landing_left=.12; landing_count+=1; attack_landings+=1
   squeeze=minf(.19,squeeze+.10); squeeze_velocity=-.35; tuft_velocity+=.35
   if is_instance_valid(battle.jelly_fx): battle.jelly_fx._play(battle.jelly_fx.landing_clip,global_position,-11.,.85)
 elif attack_phase=="recover":
  if phase_clock>=RECOVER: attack_phase="approach"; phase_clock=0.
 var before := global_position
 velocity.x=motion.x+impulse.x; velocity.z=motion.y+impulse.y
 impulse*=maxf(0.,1.-Profile.KNOCK_DECAY*delta)
 velocity.y=-.3 if is_on_floor() else velocity.y-20.*delta
 move_and_slide()
 if engaged and attack_phase=="lunge" and not attack_connected:
  if _try_parry_attack(before):
   _render_legacy(lift)
   return
  var t: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(global_position.x,global_position.z),player,.82)
  if t<INF and absf(global_position.y-battle.hero.global_position.y)<.65:
   attack_connected=true
   battle.hurt_player(touch110,Vector2(global_position.x,global_position.z))
 _render_legacy(lift)

func _rank_enter110(next: String,duration: float) -> void:
 estate110=next;timer110=duration;attack_phase="approach" if next=="chase" else ("recover" if next=="tired" else ("lunge" if next in ["dash","charge","leap","hang","crash"] else "windup"))
 phase_clock=0.;attack_connected=false
 collision_mask=1|2 if next not in ["chase","tired"] else 1|2|16
func _rank_step110(delta: float) -> void:
 if battle.combat_paused: return
 _step_soft_response(delta);_step_squeeze(delta);age+=delta;phase_clock+=delta
 for key in ["hit_left","hit_rearm","landing_left","flash","health_time","juice_gate","parry_stun"]: set(key,maxf(0.,float(get(key))-delta))
 var at := Vector2(position.x,position.z);var player := Vector2(battle.hero.position.x,battle.hero.position.z)
 var motion := Vector2.ZERO;timer110-=delta
 if not active_ai or battle.wave_state!="fighting" or battle.player_hp<=0.:
  _rank_enter110("chase",0.);lift110=0.;_rank_move110(Vector2.ZERO,delta);return
 match estate110:
  "chase":
   attack_wait110-=delta
   path_clock-=delta
   if path_clock<=0.: route=battle.navigation.path(at,player);path_clock=.4
   while route.size()>1 and at.distance_to(route[0])<.65: route.remove_at(0)
   if not route.is_empty(): motion=(route[0]-at).normalized()*(1.4 if rank110==2 else 2.1)*speed110
   lift110=absf(sin(age*3.))* .16
   if attack_wait110<=0. and battle.reserve_attack(self):
    _rank_enter110("rage",.9 if rank110==2 else .55);motion=Vector2.ZERO;lift110=0.;squeeze=.2;battle.Audio.play("parry_on",.75)
  "rage":
   if timer110<=0.:
    strike110=(player-at).normalized();locked110=player;swept110.clear()
    var clear: bool=battle.line_clear110(at,player)
    var charge: bool=rank110==2 and at.distance_to(player)>3.1 and battle.weapon_rng.randf()<(.65 if clear else .1)
    if force_strike110!="": charge=force_strike110=="charge"
    if charge: _rank_enter110("lean",1.);strikes110.charge+=1
    elif (rank110==1 and at.distance_to(player)>8.9 and force_strike110!="slam") or force_strike110=="dash": _rank_enter110("dash",.34);strikes110.dash+=1
    else: leaps110=0;crashes110=0;locked110=at+(player-at).limit_length(9.4 if rank110==2 else 7.85);_rank_enter110("leap",.5 if rank110==2 else .30)
  "lean":
   if timer110<=0.: _rank_enter110("charge",1.1)
  "dash","charge":
   motion=strike110*(27.2 if estate110=="charge" else 17.3)
   for other in battle.near_enemies110(at,2.1):
    if other==self or swept110.has(other.get_instance_id()): continue
    swept110[other.get_instance_id()]=true;other.impulse+=strike110*8.
   if timer110<=0. or not battle.line_clear110(at,at+strike110*.9): _rank_enter110("tired",2.2 if rank110==2 else 1.3);motion=Vector2.ZERO
  "leap":
   var duration := .5 if rank110==2 else .30
   lift110=sin(clampf(1.-timer110/duration,0.,1.)*PI)*1.78
   motion=(locked110-at).limit_length((9.4 if rank110==2 else 7.85)*delta)/maxf(delta,.001)
   if timer110<=0.:
    leaps110+=1;lift110=0.;landing_left=.1
    if leaps110>=2: _rank_enter110("squat",.7 if rank110==2 else .45)
    else: locked110=at+(player-at).limit_length(9.4 if rank110==2 else 7.85);_rank_enter110("leap",duration)
  "squat":
   lift110=0.;squeeze=.26
   if timer110<=0.: locked110=player;_rank_enter110("hang",.8 if rank110==2 else .55)
  "hang":
   var hang := .8 if rank110==2 else .55
   lift110=pow(clampf(1.-timer110/hang,0.,1.),2.)*(3.14 if rank110==2 else 4.19)
   motion=(locked110-at).limit_length(13.6*delta)/maxf(delta,.001)
   if timer110<=0.: _rank_enter110("crash",.24 if rank110==2 else .18)
  "crash":
   lift110=maxf(0.,lift110-(3.14 if rank110==2 else 4.19)*delta/(.24 if rank110==2 else .18))
   motion=(locked110-at).limit_length(20.9*delta)/maxf(delta,.001)
   if timer110<=0.:
    lift110=0.;crashes110+=1;strikes110.slam+=1;landing_left=.15;squeeze=.3
    battle.rank_land110(self)
    if rank110==1 and crashes110<3: _rank_enter110("squat",.34)
    else: _rank_enter110("tired",2.2 if rank110==2 else 1.3)
  "tired":
   lift110=0.
   if timer110<=0.: _rank_enter110("chase",0.);attack_wait110=(5.5 if rank110==2 else 4.)*(.6 if hp<max_hp110*.4 else 1.)
 var before := position
 _rank_move110(motion,delta)
 if estate110 in ["dash","charge"] and not attack_connected:
  var crossed: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,.6+.35*body_scale110)
  if crossed<INF and absf(position.y-battle.hero.position.y)<1.:
   if battle.hero.can_parry(): deflect(battle.hero.position+Vector3.UP*.65)
   else: attack_connected=true;battle.hurt_player(touch110*(2. if rank110==2 else 1.5),at)
func _rank_move110(motion: Vector2,delta: float) -> void:
 velocity=Vector3(motion.x+impulse.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y+impulse.y)
 impulse*=maxf(0.,1.-Profile.KNOCK_DECAY*delta);move_and_slide()
 hopping=estate110 in ["leap","hang","crash"];hop_clock=.1 if hopping else 0.
 _render_legacy(lift110)
 if estate110 in ["rage","squat"]: visual.scale*=Vector3(1.13,.87,1.)
 if estate110=="lean": visual.rotation.z=-strike110.x*.14
func deflect(contact: Vector3) -> void:
 super.deflect(contact)
 if rank110>0: lift110=0.;_rank_enter110("tired",1.2 if rank110==1 else 1.6)

func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if is_instance_valid(flower110):
  var key := "defeated" if dead else ("airborne" if estate110 in ["leap","hang","crash"] else "idle")
  flower110.position=visual.position+visual.basis*Vector3(.18*body_scale110,float(poses[key].visible_height)/24.*body_scale110-.09,.015)
  flower110.rotation=visual.rotation;flower110.scale=visual.scale;flower110.modulate=visual.modulate

func _hop_boost110() -> float:
 var boost := 1.
 if "pack" in behaviors110:
  var near := 0;var at := Vector2(position.x,position.z)
  for other in battle.near_enemies110(at,6.81):
   if other!=self and at.distance_to(Vector2(other.position.x,other.position.z))>2.62: near+=1
  boost*=1.+.07*minf(near,4)
 if "double_hop" in behaviors110 and hop_i110%3==0: boost*=1.7
 return boost
