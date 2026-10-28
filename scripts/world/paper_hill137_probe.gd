extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world137.gd"
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func walk137(s: Node3D,at: Vector2) -> bool:
 for i in 420:
  var diff: Vector2=at-Vector2(s.hero.position.x,s.hero.position.z)
  if diff.length()<.18: s.hero.wish=Vector2.ZERO;return true
  # Eight-direction key-like input, instead of aiming perfectly along a slope.
  var wish := Vector2(signf(diff.x),signf(diff.y))
  if absf(diff.x)>absf(diff.y)*2.1: wish.y=0.
  elif absf(diff.y)>absf(diff.x)*2.1: wish.x=0.
  s.hero.wish=wish.normalized();await physics_frame
 s.hero.wish=Vector2.ZERO;print("HILL137_STUCK at=",at," hero=",s.hero.position);return false
func picture137(s: Node3D,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;await settle72(20)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill137_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://hill137_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready137: await physics_frame
 s.hill_visited137=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove
 var plan := s.HILL137
 verify(s.park99.ramp_treads137>=42,"entry and new stair risers no longer have per-step blocking collision")
 var baseline := preload("res://scripts/world/world_surface107.gd").new()
 verify(absf(s.meadow.world_bounds.position.x-baseline.world_bounds.position.x+24.)<.01,"western terrain extends beyond the old rectangle")
 verify(absf(s.floor_height(g)-baseline.height_at(g.x,g.y,true))<.08,"lower forest elevation is retained")
 verify(s.floor_height(g+Vector2(-41.,-18.5))>10.3 and g.x-41.>s.meadow.world_bounds.position.x+3.,"new walkable rocky nose extends west with real terrain beyond it")
 var route: Array[Vector2]=[g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_FOOT+.5)),g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_TOP+.1))]
 for p in plan.POINTS: route.append(g+p)
 s._teleport15(route[0]);await picture137(s,"entrance")
 var up := true
 for at in route:
  if not await walk137(s,at): up=false;break
 verify(up,"eight-direction input climbs the entry, both flights and turn without lifting assistance")
 s._teleport15(route[-1]);await settle72(5)
 var down := true;var reverse := route.duplicate();reverse.reverse()
 for at in reverse:
  if not await walk137(s,at): down=false;break
 verify(down,"eight-direction input descends the whole connection")
 var sides := true
 for sign_value in [-1.,1.]:
  for segment in [0,2]:
   var a: Vector2=plan.POINTS[segment];var b: Vector2=plan.POINTS[segment+1]
   var crosswise := (b-a).normalized().orthogonal()
   s._teleport15(g+a.lerp(b,.10)+crosswise*sign_value*.76);await settle72(5)
   if not await walk137(s,g+a.lerp(b,.88)+crosswise*sign_value*.76): sides=false
 verify(sides,"both side lanes of both flights remain climbable with key-like steering")
 s._teleport15(g+plan.CENTER);await settle72(12)
 verify(s.hero.is_on_floor() and s.hero.position.y>10.3,"expanded meadow is grounded and gently graded")
 var far_shift: Vector2=s.coast137.shifts137[0];var mid_shift: Vector2=s.coast137.shifts137[1]
 s._teleport15(g+Vector2(-40.,-18.));await settle72(15)
 var far_delta: float=s.coast137.shifts137[0].distance_to(far_shift)
 var mid_delta: float=s.coast137.shifts137[1].distance_to(mid_shift)
 verify(mid_delta>far_delta*2.5 and far_delta>.001,"near islands have stronger motion than the far ocean")
 await picture137(s,"headland")
 s.hero.wish=Vector2.LEFT;await settle72(120);s.hero.wish=Vector2.ZERO
 verify(s.hero.position.y>10. and s.cliff_guard137.get_child_count()>60,"cliff contour prevents accidentally walking off the new headland")
 for p in [Vector2(-28,-31),Vector2(-28,1),Vector2(-41,-18)]:
  s._teleport15(g+p);await settle72(3)
  verify(s.coast137.layers137[0].visible and s.coast137.layers137[1].visible,"layered background persists across former hide boundary "+str(p))
 s._teleport15(g+plan.CENTER);s.hill_visited137=false;await settle72(10);disable_enemies(s)
 verify(s.paper_trial129 and s.enemies.size()==6,"separate paper encounter still starts on the expanded summit")
 var correct := true
 for actor in s.enemies: correct=correct and actor.home.distance_to(g+plan.CENTER)<.01 and actor.position.y>10.
 verify(correct,"paper spawns are spread across the new meadow")
 await picture137(s,"paper")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper-hill137-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL137_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
