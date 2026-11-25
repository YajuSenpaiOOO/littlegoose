extends "res://scripts/combat/goose383.gd"
# Physical primary actor; phantom bird copies keep the existing goose168 behavior.
const MAX_SPEED384:=4.6
const ACCEL384:=12.0
var body384: CharacterBody3D
var velocity384:=Vector3.ZERO
var route384:=PackedVector2Array()
var route_clock384:=0.0
var route_goal384:=Vector2.INF
var nav384: RefCounted
var travelled384:=0.0
var peak384:=0.0
func _ready() -> void:
 super._ready()
 body384=CharacterBody3D.new();body384.name="FlightCollision384";body384.top_level=true
 body384.collision_layer=0;body384.collision_mask=1|2;body384.motion_mode=CharacterBody3D.MOTION_MODE_FLOATING
 var shape:=CollisionShape3D.new();var capsule:=CapsuleShape3D.new();capsule.radius=.22;capsule.height=1.1;shape.shape=capsule;shape.position.y=.62
 body384.add_child(shape);add_child(body384);body384.global_position=global_position
func wish384(target: Vector3) -> Vector2:
 var center:=Vector2(battle.hero.global_position.x,battle.hero.global_position.z)
 var toward:=Vector2(target.x,target.z)-center if target.is_finite() else offset_xz
 if cup_phone:return center+toward.limit_length(flight_radius())
 if toward.length()<.01:toward=Vector2(0,1)
 return center+toward.normalized()*clampf(toward.length(),.45,1.05)
func update_follow(delta: float,target: Vector3,snap := false) -> void:
 if not is_instance_valid(body384):super.update_follow(delta,target,snap);return
 if battle.combat_paused and not snap:return
 var wish:=wish384(target)
 if snap:
  var at:=wish
  if is_instance_valid(battle.navigation):at=battle.navigation.origin+Vector2(battle.navigation.nearest(wish))*battle.navigation.CELL
  global_position=Vector3(at.x,battle.floor_height(at)+.43,at.y);body384.global_position=global_position
  velocity384=Vector3.ZERO;spring_velocity=Vector2.ZERO;route384.clear();route_clock384=0.;route_goal384=Vector2.INF
  reset_physics_interpolation()
 else:
  var dt:=maxf(0.,delta)
  if dt<=0.:return
  age+=dt;contact_clock+=dt;route_clock384-=dt
  var feet:=Vector2(global_position.x,global_position.z)
  var waypoint:=wish
  if is_instance_valid(battle.navigation):
   if nav384!=battle.navigation or route_clock384<=0. or route_goal384.distance_to(wish)>.8:
    nav384=battle.navigation;route384=nav384.path(feet,wish);route_goal384=wish;route_clock384=.35
    if route384.size()>1:route384.remove_at(0)
   while not route384.is_empty() and feet.distance_to(route384[0])<.24:route384.remove_at(0)
   if not route384.is_empty():waypoint=route384[0]
   else:waypoint=battle.navigation.origin+Vector2(battle.navigation.nearest(wish))*battle.navigation.CELL
  var toward: Vector2=waypoint-feet
  var desired:=toward*3.5
  if toward.length()<.08:desired=Vector2.ZERO
  desired=(desired+spring_velocity.limit_length(.8)).limit_length(MAX_SPEED384)
  var flat:=Vector2(velocity384.x,velocity384.z).move_toward(desired,ACCEL384*dt)
  var floor_next: float=battle.floor_height(feet+flat*dt)+.43
  var vertical:=clampf((floor_next-global_position.y)*8.,-2.4,2.4)
  velocity384=Vector3(flat.x,vertical,flat.y).limit_length(MAX_SPEED384)
  var before:=global_position
  var motion:=velocity384*dt
  for i in 3:
   if motion.length_squared()<.00000001:break
   var hit:=body384.move_and_collide(motion,false,.001,true)
   if hit==null:break
   motion=hit.get_remainder().slide(hit.get_normal());velocity384=velocity384.slide(hit.get_normal())
  global_position=body384.global_position
  var step:=global_position.distance_to(before);travelled384+=step;peak384=maxf(peak384,step/dt)
  spring_velocity*=exp(-dt*10.)
 offset_xz=Vector2(global_position.x-battle.hero.global_position.x,global_position.z-battle.hero.global_position.z)
 _remember_direction(target);_update_follow_visual(global_position+last_shot_direction*2.,snap);_update_wing_pose(delta,target)
 if not snap:step_contact()
