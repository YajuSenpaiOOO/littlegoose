extends "res://scripts/combat/tuantuan_boss256.gd"
var sweep_hits257 := 0
var slam_hits257 := 0
func lock247() -> void:
 if reverse_pending249:super.lock247();return
 if phase247=="pounce":
  reflected248=false;wall_armed256=false;from247=Vector2(position.x,position.z)
  var target=Vector2(battle.hero.position.x,battle.hero.position.z)
  var velocity=Vector2(battle.hero.velocity.x,battle.hero.velocity.z)
  var toward=target+(velocity*.48*.8).limit_length(1.6)-from247
  if toward.length()>.05:forward247=toward.normalized()
  goal247=battle.safe_goal247(from247,from247+toward.limit_length(5.6))
  flights247.append({"jump":jump247,"from":from247,"goal":goal247,"height":.6,"duration":.48,"reflected":false})
  marker247.show();draw_marker247();return
 reflected248=false;wall_armed256=false;from247=Vector2(position.x,position.z)
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 var velocity=Vector2(battle.hero.velocity.x,battle.hero.velocity.z)
 var toward=player+(velocity*duration248()*.8).limit_length(1.6)-from247
 if toward.length()>.05:
  var desired=toward.normalized()
  # Re-aim between pairs of low hops; retain a committed path while airborne.
  if jump247>=2 and jump247 not in [3,5,7,9] and not turn_reset256:
   forward247=forward247.rotated(clampf(forward247.angle_to(desired),-1.05,1.05)).normalized()
  else:forward247=desired
 turn_reset256=false
 var speed=10.5 if boost248>0 else maxf(8.4,9.3-float(jump247)*.15)
 var distance=minf(toward.length(),speed*duration248())
 goal247=battle.safe_goal247(from247,from247+forward247*distance)
 flights247.append({"jump":jump247,"from":from247,"goal":goal247,"height":height248(),"duration":duration248(),"reflected":false,"speed":speed})
 marker247.show();draw_marker247()
func strike257(damage: float,at: Vector2,source: String) -> bool:
 if battle.hero.can_parry():
  deflect(battle.hero.position+Vector3.UP*.65);return true
 attack_connected=true
 var before=battle.player_hp
 battle.boss_hurt257(damage,at,source)
 if battle.player_hp<before:
  if source=="tuantuan_sweep":sweep_hits257+=1
  else:slam_hits257+=1
 return false
func move247(motion: Vector2,delta: float) -> void:
 var start=Vector2(position.x,position.z)
 super.move247(motion,delta)
 if dead or attack_connected or phase247 not in ["flight","pounce"] or not battle.active114:return
 if lift247>.65 or (phase247=="flight" and jump247<3):return
 var duration=.48 if phase247=="pounce" else duration248()
 if jump247<3 and clock247<duration*.55:return
 var at=Vector2(position.x,position.z)
 var hero=Vector2(battle.hero.position.x,battle.hero.position.z)
 var nearest=Geometry2D.get_closest_point_to_segment(hero,start,at)
 if nearest.distance_to(hero)<1.6 and absf(position.y-battle.hero.position.y)<.8:
  strike257(2.,nearest,"tuantuan_sweep")
func land247() -> void:
 var was_reflected=reflected248
 var attacking=phase247=="flight"
 var index=jump247;var forward=forward247
 reflected248=false;lift247=0.;landing_left=.14;landing_count+=1;tuft_velocity+=.75
 var at=Vector2(position.x,position.z)
 landings247.append({"jump":jump247,"at":at,"goal":goal247,"phase":phase247,"reflected":was_reflected})
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 if not attack_connected and at.distance_to(player)<RADIUS248+.3 and absf(position.y-battle.hero.position.y)<.8:
  if strike257(touch110,at,"tuantuan_slam"):return
 battle.trauma=minf(1.,battle.trauma+.10)
 if is_instance_valid(battle.jelly_fx):battle.jelly_fx._play(battle.jelly_fx.landing_clip,position,-8.,.85)
 if phase247=="pounce":cycle247+=1;enter247("flat");return
 jump247+=1;boost248=maxi(0,boost248-1)
 if jump247<total248:enter247("rebound")
 else:enter247("flat")
 if was_reflected:turn_reset256=true
 if attacking and chains256>=2 and index in [0,2] and phase247=="rebound" and not dead:battle.emit_echoes256(at,forward)
