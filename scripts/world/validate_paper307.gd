extends "res://scripts/world/validate_paper306.gd"

class Harness307:
 extends "res://scripts/world/woodland_world307.gd"
 func export_stats226() -> Error:
  return OK

func world_script301() -> Script:
 return Harness307

func report304() -> String:
 return "res://docs/paper307-validation.json"

func shot301(tag: String) -> void:
 for i in 4:
  await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper307-" + tag + ".png")

func extra304() -> void:
 await super.extra304()
 var c = solo303("knight")
 await settle(3)
 var home: Vector2 = Vector2(c.position.x, c.position.z)
 var target := home + Vector2(0, 4.)
 w._teleport15(target)
 c.enter301("warn")
 advance303(c, .8)
 var support: Vector3 = c.operator301.global_position
 check(c.operator_pose306.begins_with("drift"), "operator keeps normal expression during tracking")
 check(Vector2(support.x, support.z).distance_to(target) < .45, "operator reaches above target before release")
 advance303(c, .4)
 check(c.operator_pose306 == "attack1" and c.state301 == "warn", "windup expression appears only in final lock beat")
 var locked: Vector3 = c.operator301.global_position
 var axis := (Vector2(locked.x, locked.z) - home).normalized()
 var distance := (Vector2(locked.x, locked.z) - home).length()
 w._teleport15(home + Vector2(2., 1.))
 var overshoot := false
 var returned := false
 var fixed := true
 for i in 210:
  c._physics_process(1. / 120.)
  fixed = fixed and c.operator301.global_position.is_equal_approx(locked)
  var along: float = c.ring304.dot(axis)
  if c.state301 == "attack":
   if along > distance + .25:overshoot = true
   if overshoot and along < distance - .15:returned = true
 check(fixed, "operator stays fixed through release and return despite player movement")
 check(overshoot and returned, "knight swings on both sides of the fixed support")
 await shot301("fixed-support")
