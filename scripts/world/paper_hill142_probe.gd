extends "res://scripts/world/paper_hill139_probe.gd"
class Walker142:
 extends "res://scripts/combat/hero142.gd"
 var wish := Vector2.ZERO
 func movement_input() -> Vector2: return Vector2.ZERO if guarding109 else wish
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class Current142:
 extends "res://scripts/world/woodland_world142.gd"
 func _hero_script() -> Script: return Walker142
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func shot142(s: Node3D,p: Vector2,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;s._teleport15(p);await settle72(30)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill142_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current142.new();s.memory_save116="user://hill142_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready142: await physics_frame
 s.hill_visited136=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s);await settle72(3)
 var g: Vector2=s.meadow.landmarks.grove
 var old := preload("res://scripts/world/world_surface140.gd").new()
 var unchanged: bool=old.world_bounds==s.meadow.world_bounds
 for p in [Vector2(10,-45.9),g,g+Vector2(-26,4),g+Vector2(-10,-23)]:
  unchanged=unchanged and is_equal_approx(old.height_at(p.x,p.y,true),s.meadow.height_at(p.x,p.y,true))
 verify(unchanged,"world bounds, station and lower forest remain unchanged")
 var clear := true
 for tree in s.trees:
  var p := Vector2(tree.root.position.x,tree.root.position.z)-g
  clear=clear and not s.tree_bad142(p)
 verify(clear,"trees stay clear of stair footprints and the new rock shoulders")
 var stable := s.relocated_trees142==3
 for tree in s.trees:
  if tree.root.has_meta("grove142"):
   var p := Vector2(tree.root.position.x,tree.root.position.z)
   stable=stable and s.meadow.normal_at(p.x,p.y,true).y>.97
 verify(stable,"three right-rear trees stand on a flat soil bench, separated from peaks")
 var west := g+Vector2(-31.,-9.5)
 verify(s.meadow.height_at(west.x,west.y,true)>13.4 and s.meadow.height_at(west.x,west.y,true)>old.height_at(west.x,west.y,true)+1.,"south-west hollow is filled with higher rock terrain")
 var view: Vector2=g+s.VIEW141
 verify(absf(s.meadow.height_at(view.x,view.y,true)-old.height_at(view.x,view.y,true))<.02,"lookout follows the original land without the raised stone disk")
 verify(s.park99.closed_bases139==4 and s.park99.visual_treads142.size()>=40,"sealed stair foundations remain and visible treads expose foot heights")
 var route: Array[Vector2]=[g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_FOOT+.5)),g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_TOP+.1))]
 for p in s.HILL136.POINTS: route.append(g+p)
 await shot142(s,route[0],"entrance")
 var up := true
 for p in route:
  if not await walk139(s,p): up=false;break
 verify(up,"key-like input climbs the stairs after clearing trees")
 var aligned := true
 for t in [.15,.45,.75]:
  var p: Vector2=g+s.HILL136.POINTS[2].lerp(s.HILL136.POINTS[3],t)
  s._teleport15(p);await settle72(8)
  var support: float=s.park99.visual_support142(p)
  aligned=aligned and is_finite(support) and s.hero.position.y+s.hero.visual.position.y>=support-.01 and s.hero.stair_visual142<=.24
 verify(aligned,"displayed feet stay above the visible treads while physics follows the smooth ramp")
 var saved: float=s.camera_distance;s.camera_distance=9.
 await shot142(s,g+Vector2(-13.6,-12.9),"stair_close")
 s.camera_distance=saved
 await shot142(s,g+Vector2(-28,-11),"west_rock")
 await shot142(s,g+Vector2(-24,-18),"meadow")
 var across := true
 for p in [Vector2(-24,-22),Vector2(-25.7,-25),s.VIEW141]:
  if not await walk139(s,g+p): across=false;break
 verify(across,"main meadow and low dirt lookout remain connected")
 s.hero.wish=Vector2.ZERO;await settle72(180)
 verify(s.view_weight141>.9,"approved scenic camera lift is retained")
 await shot142(s,view,"lookout")
 verify(s.hill_plants142.clusters142==6 and s.hill_plants142.grass_count107>40 and s.hill_plants142.fern_count107>=10,"six edge plant pockets add actual upright grass and fern depth")
 s._teleport15(route[-1]);await settle72(4);route.reverse()
 var down := true
 for p in route:
  if not await walk139(s,p): down=false;break
 verify(down,"key-like input descends both stair flights")
 await shot142(s,Vector2(7.5,-44.1),"station")
 verify(s.coast141.opacity141<.001 and s.view_weight141<.001,"station keeps its normal background and camera")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper-hill142-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"tree_grove":s.relocated_trees142,"edge_grass":s.hill_plants142.grass_count107,"edge_ferns":s.hill_plants142.fern_count107},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL142_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
