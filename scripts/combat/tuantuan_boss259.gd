extends "res://scripts/combat/tuantuan_boss258.gd"
var group259 := -1
var committed259 := Vector2.ZERO
func enter247(next: String) -> void:
 super.enter247(next)
 if next in ["angry","flat","rest"]:group259=-1
func lock247() -> void:
 # Retain the two readable high pursuits, pounce, and the harmless parry return.
 if jump247<2 or phase247=="pounce" or reverse_pending249:
  group259=-1;super.lock247();return
 reflected248=false;wall_armed256=false;from247=Vector2(position.x,position.z)
 var group=int((jump247-2)/3)
 var sampled=group!=group259 or turn_reset256
 if sampled:
  var player=Vector2(battle.hero.position.x,battle.hero.position.z)
  var velocity=Vector2(battle.hero.velocity.x,battle.hero.velocity.z)
  var toward=player+(velocity*duration248()*.3).limit_length(.65)-from247
  if toward.length()>.05:
   var desired=toward.normalized()
   # A parry return is followed by one fresh pursuit, rather than several reverse hops.
   forward247=desired if turn_reset256 else forward247.rotated(clampf(forward247.angle_to(desired),-.60,.60)).normalized()
  committed259=battle.safe_goal247(from247,from247+forward247*minf(toward.length(),5.8))
  group259=group;turn_reset256=false
 # All three hops share this world-space commitment, even if the hero dashes away.
 var toward=committed259-from247
 var speed=10.5 if boost248>0 else maxf(8.4,9.3-float(jump247)*.15)
 goal247=battle.safe_goal247(from247,from247+toward.limit_length(speed*duration248()))
 flights247.append({"jump":jump247,"from":from247,"goal":goal247,"height":height248(),"duration":duration248(),"reflected":false,"speed":speed,"group":group259,"committed":committed259,"sampled":sampled})
 marker247.show();draw_marker247()
