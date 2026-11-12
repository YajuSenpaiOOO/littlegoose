extends "res://scripts/combat/paper_card310.gd"

func charge_duration304() -> float:
 return 1.58

func move_support310(_goal: Vector3, delta: float) -> void:
 var start := Vector2(global_position.x, global_position.z)
 var target: Vector2 = battle.paper_clamp301(Vector2(battle.hero.global_position.x, battle.hero.global_position.z))
 var progress := smoothstep(0., LOCK310 - .008, clock301 + delta)
 var at := start.lerp(target, progress)
 support310 = Vector3(at.x, battle.floor_height(at) + lerpf(3.55, LINE_HEIGHT310, progress), at.y)

func strike_height310(at: Vector2) -> float:
 return battle.floor_height(at) + .8

func pose302() -> void:
 super.pose302()
 if not ready303 or state301 not in ["warn", "attack", "recover", "stunned"]:
  return
 var at := Vector2(global_position.x, global_position.z)
 var offset := Vector2.ZERO if state301 == "warn" else ring304
 visual.position.x = offset.x
 visual.position.z = offset.y
 visual.position.y += battle.floor_height(at + offset) - battle.floor_height(at)
 if state301 == "warn" and clock301 >= LOCK310:
  var side := signf(support310.x - global_position.x)
  visual.rotation.z = side * .24
  operator301.rotation.z = -side * .32
 hit_area.position = visual.transform * Vector3(0., height301 * .5, 0.)
 hit_area.rotation.z = visual.rotation.z

func draw_cue301() -> void:
 if state301 != "warn" or clock301 < LOCK310:
  cue301.hide()
  return
 var start := Vector2(global_position.x, global_position.z)
 var end := Vector2(support310.x, support310.z)
 var along := (end - start).normalized()
 if along == Vector2.ZERO:
  cue301.hide()
  return
 var cross := along.orthogonal()
 var mesh := SurfaceTool.new()
 mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 # Lay the warning onto the terrain in short sections, even on a diagonal slope.
 var segments := maxi(1, ceili(start.distance_to(end) / .45))
 for i in segments:
  var a := start.lerp(end, float(i) / segments)
  var b := start.lerp(end, float(i + 1) / segments)
  for p in [a-cross*.32, b-cross*.32, b+cross*.32, a-cross*.32, b+cross*.32, a+cross*.32]:
   mesh.set_color(Color(1., .52, .11, .62))
   mesh.add_vertex(Vector3(p.x, battle.floor_height(p) + .09, p.y))
 cue301.mesh = mesh.commit()
 cue301.global_transform = Transform3D.IDENTITY
