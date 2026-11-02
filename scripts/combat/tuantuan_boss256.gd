extends "res://scripts/combat/tuantuan_boss251.gd"
const TIMES256=[.68,.58,.47,.39,.33,.29,.26]
const HEIGHTS256=[2.8,2.1,1.5,1.05,.72,.48,.32]
var chains256 := 0
var wall_crashes256 := 0
var wall_armed256 := false
var turn_reset256 := false
func enter247(next: String) -> void:
 super.enter247(next)
 if next=="angry":chains256+=1;turn_reset256=false
 if next=="flat" and battle.has_method("clear_echoes256"):battle.clear_echoes256()
func duration248() -> float:
 return TIMES256[mini(jump247,6)]*(1.08 if boost248>0 else 1.)
func height248() -> float:
 return HEIGHTS256[mini(jump247,6)]*(1.25 if boost248>0 else 1.)
func rebound_delay256() -> float:return [.10,.075,.055,.04,.03,.025,.025][mini(jump247,6)]
func lock247() -> void:
 if phase247=="pounce":super.lock247();wall_armed256=false;return
 if reverse_pending249:
  reflected248=true;reverse_pending249=false;wall_armed256=true
  from247=Vector2(position.x,position.z)
  goal247=battle.safe_goal247(from247,from247+forward247*11.*duration248())
  flights247.append({"jump":jump247,"from":from247,"goal":goal247,"height":height248(),"duration":duration248(),"reflected":true})
  marker247.show();draw_marker247();return
 wall_armed256=false;reflected248=false;from247=Vector2(position.x,position.z)
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 var velocity=Vector2(battle.hero.velocity.x,battle.hero.velocity.z)
 var lead=(velocity*duration248()*.65).limit_length(1.6)
 var toward=player+lead-from247
 if toward.length()>.05:
  var desired=toward.normalized()
  if jump247>=2 and not turn_reset256:
   forward247=forward247.rotated(clampf(forward247.angle_to(desired),-.62,.62)).normalized()
  else:forward247=desired
 turn_reset256=false
 var speed=10.5 if boost248>0 else maxf(8.4,9.3-float(jump247)*.15)
 var travel=forward247*speed*duration248() if jump247>=2 else toward.limit_length(speed*duration248())
 goal247=battle.safe_goal247(from247,from247+travel)
 flights247.append({"jump":jump247,"from":from247,"goal":goal247,"height":height248(),"duration":duration248(),"reflected":false,"lead":lead,"speed":speed})
 marker247.show();draw_marker247()
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if dead:marker247.hide();super._physics_process(delta);return
 if not battle.active114 or battle.player_hp<=0.:
  lift247=0.;marker247.hide();velocity=Vector3.ZERO;render247();return
 clock247+=delta;age+=delta;_step_soft_response(delta);_step_squeeze(delta)
 for key in ["hit_left","hit_rearm","landing_left","flash","health_time","juice_gate","parry_stun"]:set(key,maxf(0.,float(get(key))-delta))
 var motion=Vector2.ZERO
 match phase247:
  "rest":
   if clock247>=1.05:
    if cycle247%2==0:enter247("angry")
    else:enter247("pounce_wait")
  "angry":
   # Three impatient little hops on one footprint, visibly separate from attack landings.
   lift247=absf(sin(clampf(clock247/.60,0.,1.)*PI*3.))*.32
   if clock247>=.60:enter247("squat");lift247=0.
  "squat":
   if clock247>=.65:enter247("flight");lock247()
  "rebound":
   if clock247>=rebound_delay256():enter247("flight");lock247()
  "deflected":
   if clock247>=.20:enter247("flight");lock247()
  "bumper":
   if clock247>=.42:
    if jump247<total248:enter247("flight");lock247()
    else:enter247("flat")
  "flight","pounce":
   var duration=.48 if phase247=="pounce" else duration248()
   var height=.6 if phase247=="pounce" else height248()
   var t=clampf(clock247/duration,0.,1.);lift247=4.*height*t*(1.-t)
   motion=(from247.lerp(goal247,t)-Vector2(position.x,position.z))/maxf(delta,.001)
   if t>=1.:
    move247(motion,delta)
    if not dead and phase247 in ["flight","pounce"]:land247()
    render247();return
  "pounce_wait":
   if clock247>=.65:enter247("pounce");lock247()
  "flat":
   if clock247>=2.65:enter247("rest")
 move247(motion,delta);render247()
func land247() -> void:
 var was_reflected=reflected248
 var attacking=phase247=="flight"
 var index=jump247
 var forward=forward247
 super.land247()
 if was_reflected:turn_reset256=true
 if attacking and chains256>=2 and index in [0,2] and phase247=="rebound" and not dead:
  battle.emit_echoes256(Vector2(position.x,position.z),forward)
func move247(motion: Vector2,delta: float) -> void:
 super.move247(motion,delta)
 if wall_armed256 and phase247=="flight":
  for i in get_slide_collision_count():
   var normal=get_slide_collision(i).get_normal()
   if absf(normal.y)<.5:
    crash256();break
  # safe_goal stops short of the physical wall; reaching this clipped goal is a crash too.
  if wall_armed256 and clock247>=duration248() and from247.distance_to(goal247)<11.*duration248()*.65:crash256()
func crash256() -> void:
 if not wall_armed256 or dead:return
 wall_armed256=false;wall_crashes256+=1;lift247=0.;reverse_pending249=false;reflected248=false
 receive_hit(5.,Vector3.ZERO)
 battle.trauma=minf(1.,battle.trauma+.17)
 if dead:return
 jump247+=2;boost248=0;turn_reset256=true;enter247("bumper")
func render247() -> void:
 super.render247()
 if phase247=="flat":
  var weight=1.-smoothstep(1.65,2.65,clock247)
  visual.scale*=Vector3(1.+.08*weight,1.+.28*weight,1.)
  visual.rotation.z=sin(clock247*8.)*.018*weight
 elif phase247=="bumper":visual.scale*=Vector3(1.25,.62,1.)
