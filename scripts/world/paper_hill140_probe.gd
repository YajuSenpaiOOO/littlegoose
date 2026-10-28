extends "res://scripts/world/paper_hill139_probe.gd"
class Current140:
 extends "res://scripts/world/woodland_world140.gd"
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func shot140(s: Node3D,p: Vector2,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;s._teleport15(p);await settle72(30)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill140_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current140.new();s.memory_save116="user://hill140_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready140: await physics_frame
 s.hill_visited136=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s)
 await settle72(3)
 var g: Vector2=s.meadow.landmarks.grove
 var old := preload("res://scripts/world/world_surface139.gd").new()
 var preserved: bool=s.meadow.world_bounds==old.world_bounds
 for p in [Vector2(10,-45.9),Vector2(5,-45.9),g,g+Vector2(-12,-30),g+Vector2(-26,4),g+Vector2(-10,-23)]:
  preserved=preserved and is_equal_approx(old.height_at(p.x,p.y,true),s.meadow.height_at(p.x,p.y,true))
 verify(preserved,"139 map bounds, station and ground outside the summit retain their heights")
 var before := 0;var after := 0
 for x in range(-34,-13):
  for z in range(-33,-3):
   var p := g+Vector2(x,z)
   # Count the designated meadow, not the whole mountain (which was already
   # high outside the old combat clearing). Both counts use the same grid.
   var old_main := ((Vector2(x,z)-Vector2(-24.5,-16.))/Vector2(8.5,8.)).length()
   var old_nose := ((Vector2(x,z)-Vector2(-30.,-17.))/Vector2(3.3,4.8)).length()
   if minf(old_main,old_nose)<1. and old.height_at(p.x,p.y,true)>10.35: before+=1
   if s.HILL140.radius140(Vector2(x,z))<.92 and s.meadow.height_at(p.x,p.y,true)>10.35: after+=1
 verify(after>before*1.3,"designated playable meadow grows by at least thirty percent on the same grid")
 print("HILL140_AREA before=",before," after=",after)
 verify(s.park99.fence_posts140>=40 and s.park99.fence_spans140>=38,"low wooden rail follows the perimeter and leaves an entrance")
 var post: Vector2=g+s.park99.fence_points140[0]
 var rail_y: float=s.floor_height(post)+.45
 var from := Vector3(post.x+.4,rail_y,post.y)
 var to := Vector3(post.x-.4,rail_y,post.y)
 var rail_hit := s.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,to,2))
 print("RAIL140_COLLISION expected_post=",post," height=",rail_y," hit=",rail_hit)
 verify(not rail_hit.is_empty() and s.park99.rail_bodies97.has(rail_hit.get("collider")),"perimeter wooden rail has actual blocking collision")
 verify(s.park99.closed_bases139==4,"139 closed stair foundations are retained")
 verify(s.coast_edge140.clipped_triangles140>0 and s.coast_edge140.changed_max_z140< -19. and s.coast_edge140.changed_min_radius140>.98,"coastline trims only outside the fenced meadow, beyond both mountain stair flights")
 verify(s.coast_edge140.rock_visual140.mesh!=null and s.coast_edge140.rock_visual140.mesh.get_surface_count()>0,"cliff visual preserves the original non-indexed stone geometry after coastline trim")
 var route: Array[Vector2]=[g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_FOOT+.5)),g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_TOP+.1))]
 for p in s.HILL136.POINTS: route.append(g+p)
 await shot140(s,route[0],"entrance")
 var up := true
 for p in route:
  if not await walk139(s,p): up=false;break
 verify(up,"key-like input climbs all stairs and passes the fence entrance")
 var across := true
 for p in [Vector2(-24,-18),Vector2(-24,-26),Vector2(-27,-22),Vector2(-30,-17),Vector2(-25,-10),Vector2(-24,-18)]:
  if not await walk139(s,g+p): across=false;break
 verify(across,"combat meadow, back rise and lookout connect by walkable slopes")
 await shot140(s,g+Vector2(-24,-18),"meadow")
 verify(s.hero.is_on_floor() and s.hero.position.y>10.3,"main battle meadow is grounded")
 await shot140(s,g+Vector2(-29,-20),"lookout")
 verify(s.coast140.panorama140.get_parent().get_child_count()==1 and s.coast140.horizon_screen140>.15 and s.coast140.horizon_screen140<.3,"one complete panorama preserves the visible horizon near the upper fifth")
 var first_shift: Vector2=s.coast140.shift140
 await shot140(s,g+Vector2(-24,-26),"back_rise")
 verify(s.coast140.shift140.distance_to(first_shift)>.001 and s.coast140.shift140.distance_to(first_shift)<.01,"whole panorama moves subtly across the enlarged meadow")
 var back_height: float=s.floor_height(g+Vector2(-24,-27))
 var middle_height: float=s.floor_height(g+s.HILL140.CENTER)
 verify(back_height-middle_height>.45,"back rim has an actual raised terrain layer")
 s._teleport15(route[-1]);await settle72(4);route.reverse()
 var down := true
 for p in route:
  if not await walk139(s,p): down=false;break
 verify(down,"key-like input returns through the open entrance and down both flights")
 await shot140(s,Vector2(7.5,-44.1),"station")
 verify(s.coast140.opacity140<.001,"station retains original background without ocean underneath")
 s.paper_trial129=true;s.start_combat();disable_enemies(s)
 var paper_ok := s.enemies.size()==6
 for actor in s.enemies:
  paper_ok=paper_ok and actor.home.distance_to(g+s.HILL140.CENTER)<.01 and s.HILL140.radius140(Vector2(actor.position.x,actor.position.z)-g)<.8
 verify(paper_ok,"six paper enemies spread across the new fixed encounter inside the fence")
 await shot140(s,g+Vector2(-24,-18),"paper")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper-hill140-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"designated_meadow_grid_before":before,"designated_meadow_grid_after":after},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL140_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
