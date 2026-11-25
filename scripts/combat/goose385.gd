extends "res://scripts/combat/goose383.gd"
# Free airborne follower again. Cap actual world motion, not only a relative offset.
const MAX_SPEED385:=4.6
var velocity385:=Vector3.ZERO
var peak385:=0.0
var scenery_motion385: Callable
func update_follow(delta: float,target: Vector3,snap := false) -> void:
 if battle.combat_paused and not snap:return
 var center:=Vector2(battle.hero.global_position.x,battle.hero.global_position.z)
 var toward:=Vector2(target.x,target.z)-center if target.is_finite() else offset_xz
 var wish: Vector2
 if cup_phone:wish=center+toward.limit_length(flight_radius())
 else:
  if toward.length()<.01:toward=Vector2(0,1)
  wish=center+toward.normalized()*clampf(toward.length(),.45,1.05)
 if snap:
  global_position=Vector3(wish.x,battle.floor_height(wish)+.43,wish.y)
  velocity385=Vector3.ZERO;spring_velocity=Vector2.ZERO;reset_physics_interpolation()
 elif delta>0.:
  age+=delta;contact_clock+=delta
  var error:=wish-Vector2(global_position.x,global_position.z)
  # Retain the old spring's pull/damping without collision slides or grid waypoints.
  var flat:=Vector2(velocity385.x,velocity385.z)+error*26.*delta
  flat*=maxf(0.,1.-6.5*delta)
  flat+=spring_velocity.limit_length(.8)*delta*6.
  var floor_next: float=battle.floor_height(Vector2(global_position.x,global_position.z)+flat.limit_length(MAX_SPEED385)*delta)+.43
  velocity385=Vector3(flat.x,clampf((floor_next-global_position.y)*8.,-2.4,2.4),flat.y).limit_length(MAX_SPEED385)
  var before:=global_position
  if scenery_motion385.is_valid():scenery_motion385.call(delta)
  else:global_position+=velocity385*delta
  peak385=maxf(peak385,global_position.distance_to(before)/delta)
  spring_velocity*=exp(-delta*10.)
 offset_xz=Vector2(global_position.x-battle.hero.global_position.x,global_position.z-battle.hero.global_position.z)
 _remember_direction(target);_update_follow_visual(global_position+last_shot_direction*2.,snap);_update_wing_pose(delta,target)
 if not snap:step_contact()
