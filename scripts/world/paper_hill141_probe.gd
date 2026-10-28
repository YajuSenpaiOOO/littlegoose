extends "res://scripts/world/paper_hill139_probe.gd"
class Current141:
 extends "res://scripts/world/woodland_world141.gd"
 var shooting141 := false
 func _hero_script() -> Script: return Fighter
 func fire_input_held() -> bool: return shooting141
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func shot141(s: Node3D,p: Vector2,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;s._teleport15(p);await settle72(35)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill141_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current141.new();s.memory_save116="user://hill141_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not s.hill_ready141: await physics_frame
 s.hill_visited136=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s);await settle72(3)
 var g: Vector2=s.meadow.landmarks.grove
 var old := preload("res://scripts/world/world_surface140.gd").new()
 var preserved: bool=old.world_bounds==s.meadow.world_bounds
 for p in [Vector2(10,-45.9),Vector2(5,-45.9),g,g+Vector2(-26,4),g+Vector2(-10,-23)]:
  preserved=preserved and is_equal_approx(old.height_at(p.x,p.y,true),s.meadow.height_at(p.x,p.y,true))
 verify(preserved,"140 world bounds, station and lower forest heights are retained")
 verify(s.park99.fence_posts140>5 and s.park99.fence_posts140<25,"full perimeter ring is replaced by a few short decorative rail runs")
 var opening := true
 for p in s.park99.fence_points140: opening=opening and p.distance_to(s.VIEW141)>1.9
 verify(opening,"north mossy lookout remains free of railing")
 verify(s.border_trees141>=2,"new rooted trees frame the approach and natural field edges")
 var ridge := g+Vector2(-16.6,-23.)
 verify(s.meadow.height_at(ridge.x,ridge.y,true)-old.height_at(ridge.x,ridge.y,true)>2.8,"east boundary is formed by an actual raised mountain shoulder")
 verify(s.park99.closed_bases139==4,"sealed stair foundations remain unchanged")
 var edge := g+Vector2(-27.5,-31.5);var normal := Vector2(-2.,-3.).normalized()
 var ray_y: float=s.floor_height(edge)+1.1
 var edge_hit := s.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(edge.x+normal.x*.5,ray_y,edge.y+normal.y*.5),Vector3(edge.x-normal.x*.5,ray_y,edge.y-normal.y*.5),2))
 verify(edge_hit.get("collider")==s.cliff_stops141,"open decorative boundaries retain blocking collision at the actual cliff contour")
 var route: Array[Vector2]=[g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_FOOT+.5)),g+s.PARK99.from_stair99(Vector2(s.PARK99.STAIR_X,s.PARK99.STAIR_TOP+.1))]
 for p in s.HILL136.POINTS: route.append(g+p)
 await shot141(s,route[0],"entrance")
 var up := true
 for p in route:
  if not await walk139(s,p): up=false;break
 verify(up,"key-like input climbs the unchanged stair route through the wooded entrance")
 await shot141(s,g+s.HILL140.CENTER,"meadow")
 var anchor: Transform3D=s.coast141.panorama141.global_transform
 var physical_size: Vector2=s.coast141.panorama141.mesh.size
 var far_world: Vector3=s.coast141.anchor141
 var near_world := Vector3(g.x-24.,11.5,g.y-22.)
 var far_before: Vector2=s.camera.unproject_position(far_world);var near_before: Vector2=s.camera.unproject_position(near_world)
 await shot141(s,g+s.HILL140.CENTER+Vector2(-2.,0.),"meadow_shift")
 var far_delta: float=s.camera.unproject_position(far_world).distance_to(far_before)
 var near_delta: float=s.camera.unproject_position(near_world).distance_to(near_before)
 verify(s.coast141.panorama141.global_transform.is_equal_approx(anchor) and s.coast141.panorama141.mesh.size.is_equal_approx(physical_size),"distant panorama remains fixed in world position, orientation and physical size")
 verify(far_delta>.1 and far_delta<near_delta*.25,"camera motion produces much slower distant movement than nearby world geometry")
 print("PARALLAX141 distant_pixels=",far_delta," near_pixels=",near_delta)
 var across := true
 for p in [Vector2(-24,-22),Vector2(-25.7,-25.0),s.VIEW141]:
  if not await walk139(s,g+p): across=false;break
 verify(across,"meadow and mossy high viewpoint connect through walkable slopes")
 s.hero.wish=Vector2.ZERO;await settle72(180)
 verify(s.hero.is_on_floor() and s.hero.position.y>12.3,"future narrative seat is a real elevated grounded surface")
 verify(s.view_weight141>.9,"approaching the scenic opening gently opens the view without locking controls")
 var pitch: float=s.camera.rotation.x;await settle72(60)
 verify(absf(s.camera.rotation.x-pitch)<.002,"scenic camera rotation settles without accumulating tilt")
 await shot141(s,g+s.VIEW141,"lookout")
 s.shooting141=true;await settle72(100)
 verify(s.view_weight141<.5,"firing smoothly disengages scenic camera framing")
 s.shooting141=false;await settle72(160)
 await shot141(s,g+Vector2(-24,-23),"approach")
 s._teleport15(route[-1]);await settle72(4);route.reverse()
 var down := true
 for p in route:
  if not await walk139(s,p): down=false;break
 verify(down,"key-like input returns through the wooded opening and down both stair flights")
 await shot141(s,Vector2(7.5,-44.1),"station")
 verify(s.coast141.opacity141<.001 and s.view_weight141<.001,"station retains its original background and normal camera")
 s.home116();await settle72(2)
 FileAccess.open("res://docs/paper-hill141-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"distant_motion_pixels":far_delta,"near_motion_pixels":near_delta,"rail_posts":s.park99.fence_posts140,"rail_spans":s.park99.fence_spans140},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL141_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
