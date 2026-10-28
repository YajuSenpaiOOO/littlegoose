extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world136.gd"
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func picture136(s: Node3D,name: String) -> void:
 s.hero.wish=Vector2.ZERO;await settle72(20)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill136_%s.png"%name)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Sample.new();s.memory_save116="user://hill136_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready136: await physics_frame
 s.hill_visited136=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s)
 var g: Vector2=s.meadow.landmarks.grove
 var hill := s.HILL136
 verify(s.park99.hill_treads136>35,"two rising flights and turning landing use authored stone treads")
 verify(absf(s.floor_height(g+hill.CENTER)-hill.LEVEL)<.15,"summit has a stable high playable surface")
 var original := preload("res://scripts/world/world_surface107.gd").new()
 verify(absf(s.meadow.height_at(g.x,g.y,true)-original.height_at(g.x,g.y,true))<.001,"lower Tuantuan clearing retains its ground height")
 s._teleport15(g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_FOOT+.6)))
 await picture136(s,"entrance")
 var route: Array[Vector2]=[g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_TOP+.15))]
 for point in hill.POINTS: route.append(g+point)
 var uphill := true
 for at in route:
  if not await walk_to(s,at): uphill=false;print("HILL136_STUCK_UP target=",at," hero=",s.hero.position);break
 verify(uphill,"real movement climbs existing stairs, lower flight, landing and upper flight")
 await picture136(s,"summit")
 verify(s.hero.position.y>10.4 and s.hero.is_on_floor(),"player reaches the summit while grounded")
 verify(s.vista136.visible and s.vista136.texture!=null,"coastal background appears near the high lookout")
 var downhill := true
 route.reverse()
 for at in route:
  if not await walk_to(s,at): downhill=false;print("HILL136_STUCK_DOWN target=",at," hero=",s.hero.position);break
 verify(downhill,"real movement returns down both flights without teleporting")
 s._teleport15(g+hill.CENTER+Vector2(2.,3.5));s.hill_visited136=false;await settle72(10);disable_enemies(s)
 verify(s.paper_trial129 and s.enemies.size()==6,"walking into the summit starts the separate six-paper encounter")
 var on_hill := true
 for actor in s.enemies: on_hill=on_hill and actor.home.distance_to(g+hill.CENTER)<.01 and actor.position.y>10.
 verify(on_hill,"paper homes and spawn heights belong to the summit")
 await picture136(s,"paper")
 s.paper_count131=10;s.start_combat();disable_enemies(s)
 verify(s.enemies.size()==10,"ten-paper comparison also spawns at the new fixed site")
 s.paper_trial129=false;s.start_combat();disable_enemies(s)
 verify(s.hero.position.y<4. and not s.paper_trial129,"Tuantuan shortcut still uses its lower forest site")
 s.hill_visited136=false;s._teleport15(g+hill.CENTER);await settle72(10);disable_enemies(s)
 verify(s.paper_trial129 and s.enemies.size()==10,"ascending from an unfinished lower trial switches to the separate summit group")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper-hill136-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL136_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
