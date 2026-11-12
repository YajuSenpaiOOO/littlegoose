extends "res://scripts/world/validate_paper305.gd"

class Harness312:
 extends "res://scripts/world/woodland_world312.gd"
 func export_stats226() -> Error:
  return OK

func world_script301() -> Script:
 return Harness312

func report304() -> String:
 return "user://paper312-validation.json"

func shot301(_tag: String) -> void:
 pass

func extra304() -> void:
 await super.extra304()
 var c = solo303("knight")
 await settle(3)
 c.enter301("rest")
 c.render301()
 var drift: String = c.operator_pose306
 c.age += .22
 c.render301()
 check(drift.begins_with("drift") and c.operator_pose306 != drift, "operator animates authored drift frames")
 c.enter301("warn")
 c.clock301 = 1.35
 c.render301()
 var pulled: Vector3 = c.operator301.global_position
 check(c.operator_pose306 == "attack1" and not c.cue301.visible, "strained pose without ground cue")
 c.enter301("attack")
 c.render301()
 check(c.operator301.global_position.is_equal_approx(pulled) and c.operator_pose306 == "attack2", "release preserves world position and changes pose")
 advance303(c, .2)
 check(c.operator301.global_position.is_equal_approx(pulled) and not c.cue301.visible, "operator stays during release with cue hidden")
 check(c.thread_support302().is_equal_approx(c.operator301.transform * (Vector3.UP * .08)), "rope tracks animated operator")
 clean303()
 w.reset_impact248()
 w._teleport15(c.attack_at301())
 var hp: float = w.player_hp
 c.connected301 = false
 c.contact303(c.attack_at301())
 check(is_equal_approx(hp - w.player_hp, 1.5) and w.stop_duration >= .075 and w.punch >= 1.15, "real hit keeps damage and applies impact feedback")
 var support_before: Vector3 = c.operator301.global_position
 advance303(c, .22)
 check(c.operator301.global_position.distance_to(support_before) > .05, "upper paper has independent motion after the release beat")
 c.enter301("recover")
 c.ring304 = Vector2(2., -1.)
 c.render301()
 var tab: Vector3 = c.to_global(c.visual.transform * c.tab302())
 check(absf(c.operator301.global_position.x - tab.x) > .1, "recovering paper can lag behind the knight")
 for offset in [Vector2(0., -3.8), Vector2(0., 3.8), Vector2(3.8, -3.8), Vector2(-3.8, 3.8)]:
  c = solo303("knight")
  await settle(3)
  var start: Vector2 = w.centre301 + Vector2(0., 4.25)
  c.position = Vector3(start.x, w.floor_height(start) + .04, start.y)
  var target: Vector2 = start + offset
  w._teleport15(target)
  clean303()
  var health: float = w.player_hp
  c.enter301("warn")
  if offset.x != 0.:
   w._teleport15(start + Vector2(-offset.x, offset.y))
   advance303(c, 1.28)
   w._teleport15(target)
   w.hero.velocity.x = -signf(offset.x) * 5.
   advance303(c, .08)
   check(c.target312.is_equal_approx(target) and c.direction301.is_equal_approx(offset.normalized()), "release locks actual diagonal feet after a late reversal")
  else:
   advance303(c, 1.35)
  advance303(c, .35)
  check(w.player_hp < health, "straight lunge hits on open path " + str(offset))