extends "res://scripts/world/paper_hill139_probe.gd"
class Walker143:
 extends "res://scripts/combat/hero142.gd"
 var wish := Vector2.ZERO
 func movement_input() -> Vector2: return Vector2.ZERO if guarding109 else wish
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class Current143:
 extends "res://scripts/world/woodland_world143.gd"
 func _hero_script() -> Script: return Walker143
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func shot143(s: Node3D,p: Vector2,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;s._teleport15(p);await settle72(30)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill143_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current143.new();s.memory_save116="user://hill143_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready143: await physics_frame
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
 await shot143(s,route[0],"entrance")
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
 await shot143(s,g+Vector2(-13.6,-12.9),"stair_close")
 s.camera_distance=saved
 await shot143(s,g+Vector2(-28,-11),"west_rock")
 await shot143(s,g+Vector2(-24,-18),"meadow")
 var across := true
 for p in [Vector2(-24,-22),Vector2(-25.7,-25),s.VIEW141]:
  if not await walk139(s,g+p): across=false;break
 verify(across,"main meadow and low dirt lookout remain connected")
 s.hero.wish=Vector2.ZERO;await settle72(180)
 verify(s.view_weight141>.9,"approved scenic camera lift is retained")
 await shot143(s,view,"lookout")
 verify(s.hill_plants142.clusters142==6 and s.hill_plants142.grass_count107>40 and s.hill_plants142.fern_count107>=10,"six edge plant pockets add actual upright grass and fern depth")
 s._teleport15(route[-1]);await settle72(4);route.reverse()
 var down := true
 for p in route:
  if not await walk139(s,p): down=false;break
 verify(down,"key-like input descends both stair flights")
 await shot143(s,Vector2(7.5,-44.1),"station")
 verify(s.coast141.opacity141<.001 and s.view_weight141<.001,"station keeps its normal background and camera")
 verify(s.painted_rocks143==5,"five summit stones reuse painted forest art with standard rock colliders")
 verify(s.hill_plants142.shrub_bodies143.size()==s.hill_plants142.fern_count107,"upright fern cores have narrow collision footprints")
 var hits := true
 for body in s.hill_plants142.shrub_bodies143:
  var query := PhysicsRayQueryParameters3D.create(body.global_position+Vector3.UP,body.global_position-Vector3.UP,2)
  hits=hits and not s.get_world_3d().direct_space_state.intersect_ray(query).is_empty()
 verify(hits,"physics rays actually hit every fern core")
 verify(s.coast_edge140.score140(Vector3(g.x-17.,10.,g.y-40.))<0.,"old rear rectangular terrain corner is outside the new coast")
 verify(s.breeze143.clipped_materials143.size()>10,"projected shadow materials obey the visible coastline")
 var rail := true
 var rail_mesh: ArrayMesh=s.rail72.rail_mesh72.mesh
 for surface in rail_mesh.get_surface_count():
  var arrays: Array=rail_mesh.surface_get_arrays(surface)
  var ids: PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
  var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
  var worst := INF
  for i in range(0,ids.size(),3):
   var a: Vector3=vertices[ids[i]];var b: Vector3=vertices[ids[i+1]];var c: Vector3=vertices[ids[i+2]]
   if (b-a).cross(c-a).length_squared()<.00000001: continue
   for at in [a,b,c]: worst=minf(worst,s.coast_edge140.score140(at))
  print("RAIL143 minimum_coast_score=",worst)
  rail=rail and worst>=-.003 # Three millimetres: intersection rounding on world-space rail faces.
 verify(rail,"exposed old railway end is trimmed to the same coastline")
 var rock_hits := true
 for rock in s.forest87.rocks87.slice(s.forest87.rocks87.size()-5):
  var at := Vector3(rock.at.x,s.floor_height(rock.at)+.25,rock.at.y)
  var query := PhysicsRayQueryParameters3D.create(at+Vector3.UP*2.,at-Vector3.UP,2)
  rock_hits=rock_hits and not s.get_world_3d().direct_space_state.intersect_ray(query).is_empty()
 verify(rock_hits,"painted stones have working physics footprints")
 verify(s.breeze143.ribbons143.size()==2,"two fixed rail knots carry wind ribbons")
 s.time55.preview_at(18.);s.time55.visual_hour=18.;s.time55.apply_look()
 await shot143(s,g+Vector2(-31.,-17.),"dusk_edge")
 await shot143(s,g+s.VIEW141,"dusk_view")
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look()
 s.breeze143.next_bird143=0.;await settle72(120)
 verify(s.breeze143.flight_count143>0 and s.breeze143.birds143[0].visible,"occasional birds enter an actual world-space flight")
 await shot143(s,g+s.VIEW141,"wind_view")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper-hill143-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"tree_grove":s.relocated_trees142,"edge_grass":s.hill_plants142.grass_count107,"edge_ferns":s.hill_plants142.fern_count107},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL143_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)

