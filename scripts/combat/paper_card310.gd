extends "res://scripts/combat/paper_card305.gd"

const LOCK310 := 1.15
const LINE_HEIGHT310 := 3.9
var support310 := Vector3.ZERO
var axis310 := Vector2.ZERO
var outgoing310 := false
var speed310 := 0.

func _physics_process(delta: float) -> void:
 if ready303 and not dead and battle.active114 and not battle.combat_paused and state301 == "warn" and clock301 < LOCK310:
  var start := Vector2(position.x, position.z)
  var lead := Vector2(battle.hero.velocity.x, battle.hero.velocity.z).limit_length(4.) * .16
  var target: Vector2 = battle.paper_clamp301(Vector2(battle.hero.position.x, battle.hero.position.z) + lead)
  target = start + (target - start).limit_length(7.)
  var progress := smoothstep(0., LOCK310, clock301 + delta)
  var goal := start.lerp(target, progress)
  var height: float = battle.floor_height(goal) + lerpf(3.55, LINE_HEIGHT310, progress)
  move_support310(Vector3(goal.x, height, goal.y), delta)
 super._physics_process(delta)

func enter301(next: String) -> void:
 if ready303:
  if next == "warn":
   support310 = operator301.global_position
  elif next == "attack":
   var pull := support_offset310()
   axis310 = pull.normalized()
   if axis310 != Vector2.ZERO:
    direction301 = axis310
   outgoing310 = pull.length() >= .35
   speed310 = 0.
  elif next == "rest" and state301 in ["recover", "stunned"]:
   var at := Vector2(position.x, position.z) + ring304
   position = Vector3(at.x, battle.floor_height(at) + .04, at.y)
   ring304 = Vector2.ZERO
 super.enter301(next)
 if next == "attack" and not outgoing310:
  ring_velocity304 = Vector2.ZERO

func pose302() -> void:
 super.pose302()
 if ready303 and state301 in ["warn", "attack", "recover", "stunned"]:
  operator301.global_position = support310
  var tension := smoothstep(.3, LOCK310, clock301) if state301 == "warn" else .18
  operator301.rotation.z = -direction301.x * .27 * tension

func thread_support302() -> Vector3:
 return operator301.transform * (Vector3.UP * .08)

func support_offset310() -> Vector2:
 return Vector2(support310.x - global_position.x, support310.z - global_position.z)

func step_ring304(delta: float) -> void:
 var previous := ring304
 var pivot := support_offset310()
 var steps := maxi(1, int(ceil(delta * 120.)))
 var dt := delta / steps
 for i in steps:
  if not outgoing310:
   ring_velocity304 += ((pivot - ring304) * 28. - ring_velocity304 * 2.8) * dt
  ring304 += ring_velocity304 * dt
  if outgoing310 and (ring304 - pivot).dot(axis310) >= 0.:
   outgoing310 = false
 var swing_limit := maxf(4., pivot.length() + 1.5)
 var goal := ring304 if outgoing310 else pivot + (ring304 - pivot).limit_length(swing_limit)
 # Clip along the path so a diagonal strike cannot slide sideways at the edge.
 var root_at := Vector2(position.x, position.z)
 var start := root_at + previous
 var travel := root_at + goal - start
 var bounded: Vector2 = battle.paper_clamp301(start + travel)
 var fraction := 1.
 for axis in 2:
  if absf(travel[axis]) > .00001:
   fraction = minf(fraction, clampf((bounded[axis] - start[axis]) / travel[axis], 0., 1.))
 var end := start + travel * fraction
 var ray_start := Vector3(start.x, strike_height310(start), start.y)
 var ray_end := Vector3(end.x, strike_height310(end), end.y)
 if not ray_start.is_equal_approx(ray_end):
  var wall := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_start, ray_end, 1 | 2))
  if not wall.is_empty():
   var offset := Vector2(wall.position.x, wall.position.z) - start
   end = start + offset.limit_length(maxf(0., offset.length() - .15))
 if end.distance_squared_to(root_at + ring304) > .000001:
  outgoing310 = false
  ring_velocity304 *= -.3
 ring304 = end - root_at
 speed310 = previous.distance_to(ring304) / maxf(delta, .001)

func settle_ring304(delta: float) -> void:
 outgoing310 = false
 step_ring304(delta)

func can_ring_contact304() -> bool:
 return speed310 >= 4.5

func deflect(contact: Vector3) -> void:
 if dead or state301 != "attack":
  return
 var incoming := ring_velocity304
 if incoming.length_squared() < 1.:
  incoming = direction301 * 8.
 var previous: float = battle.parry_threat306
 battle.parry_threat306 = battle.HEAVY_PARRY_DAMAGE306
 super.deflect(contact)
 battle.parry_threat306 = previous
 if not dead:
  outgoing310 = false
  ring_velocity304 = -incoming.normalized() * clampf(incoming.length(), 12., 24.)

func move_support310(goal: Vector3, delta: float) -> void:
 support310 = support310.move_toward(goal, delta * 9.)

func strike_height310(_at: Vector2) -> float:
 return position.y + .8
