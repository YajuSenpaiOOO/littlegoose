extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world139.gd"
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func walk139(s: Node3D,at: Vector2) -> bool:
 for i in 420:
  var diff: Vector2=at-Vector2(s.hero.position.x,s.hero.position.z)
  if diff.length()<.18: s.hero.wish=Vector2.ZERO;return true
  var wish := Vector2(signf(diff.x),signf(diff.y))
  if absf(diff.x)>absf(diff.y)*2.1: wish.y=0.
  elif absf(diff.y)>absf(diff.x)*2.1: wish.x=0.
  s.hero.wish=wish.normalized();await physics_frame
 s.hero.wish=Vector2.ZERO;print("HILL139_STUCK at=",at," hero=",s.hero.position);return false
func shot139(s: Node3D,at: Vector2,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;s._teleport15(at);await settle72(25)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill139_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://hill139_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready139: await physics_frame
 s.hill_visited136=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove
 var baseline := preload("res://scripts/world/world_surface136.gd").new()
 verify(s.meadow.world_bounds==baseline.world_bounds,"136 map bounds and terrain grid origin are unchanged")
 var preserved := true
 for at in [Vector2(10,-45.9),Vector2(5,-45.9),g,g+Vector2(-20,-31),g+Vector2(-26,4),g+Vector2(-10,-23)]:
  preserved=preserved and is_equal_approx(s.meadow.height_at(at.x,at.y,true),baseline.height_at(at.x,at.y,true))
 verify(preserved,"station, lower forest and mountain outside local extension retain 136 heights")
 verify(s.park99.closed_bases139==4,"all mountain stair sections have closed stone foundations")
 verify(s.rocks91.get_script().resource_path=="res://scripts/art/rock_surfaces103.gd","136 terrain rendering is retained without new discard masks")
 verify(s.coast139.get_child_count()==1,"sea and islands share a single panorama")
 await shot139(s,Vector2(7.5,-44.1),"station")
 verify(s.coast139.opacity139<.001,"station keeps the original background")
 var route: Array[Vector2]=[g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_FOOT+.5)),g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_TOP+.1))]
 for p in s.HILL136.POINTS: route.append(g+p)
 await shot139(s,route[0],"entrance")
 var up := true
 for at in route:
  if not await walk139(s,at): up=false;break
 verify(up,"key-like input climbs the complete mountain connection")
 var reverse := route.duplicate();reverse.reverse();s._teleport15(reverse[0]);await settle72(5)
 var down := true
 for at in reverse:
  if not await walk139(s,at): down=false;break
 verify(down,"key-like input descends the complete mountain connection")
 await shot139(s,g+Vector2(-10.8,-11.8),"connection")
 await shot139(s,g+Vector2(-25,-16),"summit")
 verify(s.hero.is_on_floor() and s.hero.position.y>10.4,"expanded summit supports the player")
 await shot139(s,g+Vector2(-31,-17),"nose")
 verify(s.hero.is_on_floor() and s.hero.position.y>10.4,"new west-facing nose has solid ground")
 var visible := true
 for p in [Vector2(-28,-31),Vector2(-28,1)]:
  s._teleport15(g+p);await settle72(3);visible=visible and s.coast139.opacity139>.99
 verify(visible,"panorama remains visible beyond the previous north and south cutoffs")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper-hill139-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL139_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
