extends "res://scripts/world/validate_paper305.gd"

class Harness308:
 extends "res://scripts/world/woodland_world308.gd"
 func export_stats226() -> Error:
  return OK

func run() -> void:
 w = Harness308.new()
 root.add_child(w)
 current_scene = w
 while not w.ready301:
  await process_frame
 var c = solo303("knight")
 await settle(3)
 c.set_physics_process(false)
 var start := Vector2(c.position.x, c.position.z)
 var target := start + Vector2(0., 4.)
 w._teleport15(target)
 var wall := StaticBody3D.new()
 wall.collision_layer = 1
 var collision := CollisionShape3D.new()
 var box := BoxShape3D.new()
 box.size = Vector3(1.6, 1.2, .2)
 collision.shape = box
 wall.add_child(collision)
 wall.position = c.position + Vector3(0., .65, 1.5)
 w.add_child(wall)
 await physics_frame
 await physics_frame
 c.enter301("warn")
 advance303(c, 1.25)
 var pivot: Vector3 = c.operator301.global_position
 check(Vector2(pivot.x, pivot.z).distance_to(target) < .45, "airborne operator tracks past a low wall")
 check(c.state301 == "warn" and c.operator_pose306.begins_with("drift"), "early charge keeps neutral face and does not release")
 advance303(c, .17)
 check(c.state301 == "warn" and c.operator_pose306 == "attack1", "final charge shows tense face")
 var locked: Vector3 = c.operator301.global_position
 w._teleport15(start + Vector2(2., 2.))
 advance303(c, .25)
 check(c.ring304.y < 1.45 and absf(c.ring304.x) < .05, "low wall blocks knight along locked line")
 check(c.operator301.global_position.is_equal_approx(locked), "launch does not move the operator")
 wall.queue_free()
 await process_frame
 await physics_frame
 c.enter301("warn")
 w._teleport15(target)
 advance303(c, 1.42)
 locked = c.operator301.global_position
 w._teleport15(start + Vector2(2., 2.))
 advance303(c, .25)
 check(c.ring304.y > 1.5 and absf(c.ring304.x) < .05, "knight moves directly toward fixed support")
 check(c.can_ring_contact304(), "fast outgoing sweep remains dangerous")
 advance303(c, 1.9)
 c.ring304 = Vector2(locked.x, locked.z) - start
 c.ring_velocity304 = Vector2.ZERO
 c.contact_gate304 = 0.
 c.pose302()
 w._teleport15(c.attack_at301())
 clean303()
 var hp: float = w.player_hp
 var launches: int = c.launches304
 c._physics_process(1. / 120.)
 check(c.state301 == "attack" and not c.can_ring_contact304() and w.player_hp == hp and c.launches304 == launches, "walking into a stopped knight during attack timer does not damage or launch")
 FileAccess.open("res://docs/paper308-validation.json", FileAccess.WRITE).store_string(JSON.stringify({"checks": checks}, "  "))
 quit(0 if checks.all(func(v): return v.pass) else 1)
