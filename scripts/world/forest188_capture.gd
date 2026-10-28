extends "res://scripts/world/forest180_probe.gd"
const P188=preload("res://scripts/world/forest_plan188.gd")
const D188=preload("res://scripts/world/forest_dressing188.gd")
const BASE188=preload("res://scripts/world/world_surface142.gd")
class Walker188:
 extends "res://scripts/combat/hero188.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class Trial188:
 extends "res://scripts/world/woodland_world188.gd"
 func _hero_script() -> Script: return Walker188
func shot188(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest188_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial188.new();s.memory_save116="user://forest188_capture_tmp.cfg";root.add_child(s)
 while not s.forest_ready188: await physics_frame
 var baseline := BASE188.new()
 verify(s.meadow.world_bounds.position.is_equal_approx(baseline.world_bounds.position),"south expansion preserves established world origin")
 verify(is_equal_approx(s.meadow.world_bounds.size.x,baseline.world_bounds.size.x) and s.meadow.world_bounds.end.y>baseline.world_bounds.end.y+29.,"only south world edge expands by thirty metres")
 for p in [Vector2(-48.,0.),Vector2(-58.,-8.),Vector2(-34.,7.)]:
  verify(is_equal_approx(s.meadow.height_at(p.x,p.y,true),baseline.height_at(p.x,p.y,true)),"former forest site keeps original terrain at "+str(p))
 var cliff_grass := 0
 for batch in s.grass_batches:
  for i in batch.points.size():
   var at: Vector3=batch.points[i].origin;var p := Vector2(at.x,at.z)
   if not P188.region188(p) or s.meadow.normal_at(p.x,p.y,true).y>=.90: continue
   var pose: Transform3D=batch.node.multimesh.get_instance_transform(i)
   if pose.basis.x.length_squared()>.001: cliff_grass+=1
 verify(cliff_grass==0,"no grass multimesh remains on relocated rock faces")
 var cliff_trees := 0
 for tree in s.trees:
  var p := Vector2(tree.root.position.x,tree.root.position.z)
  if tree.root.visible and P188.region188(p) and s.meadow.normal_at(p.x,p.y,true).y<.92: cliff_trees+=1
 verify(cliff_trees==0,"no inherited trees remain on relocated rock faces")
 verify(not s.hero.visual.shaded,"hero card ignores roaming per-lamp 3D face lighting")
 for path in ["res://assets/forest188/yarn_craft_corner_pixel.png","res://assets/forest188/post_top_nightlight_pixel.png","res://assets/forest188/lilac_ground_clump_pixel.png"]:
  var image: Image=load(path).get_image()
  verify(image.get_pixel(0,0).a<.05 and image.get_pixel(image.get_width()-1,image.get_height()-1).a<.05,"redrawn prop keeps transparent corners: "+path.get_file())
 var lamps_before: Array[Vector3]=[]
 for lamp in s.forest188.hanging_lamps184: lamps_before.append(lamp.global_position)
 await settle(90)
 var stable := true
 for i in lamps_before.size(): stable=stable and lamps_before[i].distance_to(s.forest188.hanging_lamps184[i].global_position)<.0001 and s.forest188.hanging_lamps184[i].visible
 verify(stable,"branch lamps stay at a fixed visible anchor instead of flickering with tree fade")
 var route: Array[Vector2]=[]
 for p in D188.TRAIL: route.append(P188.CENTER+p)
 var walked := await walk(s,route)
 if not walked:
  for i in s.hero.get_slide_collision_count():
   var collider: Node3D=s.hero.get_slide_collision(i).get_collider()
   print("FOREST188_BLOCKER_DETAIL path=",collider.get_path()," at=",collider.global_position," name=",collider.name," parent=",collider.get_parent().name," script=",collider.get_script())
 verify(walked,"hero walks through relocated inner forest route")
 s._teleport15(Vector2(-4.7,-2.6));await settle(120);await shot188("home_separation")
 s._teleport15(P188.CENTER+P188.ENTRY);await settle(100);await shot188("long_approach")
 s._teleport15(P188.CENTER+Vector2(4.,3.));s.hero.facing="down";s.hero.render_pose();await settle(100);await shot188("central_redraw")
 s._teleport15(P188.CENTER+Vector2(-10.4,-7.5));await settle(100);await shot188("cottage_redraw")
 verify(s.forest_mood188.amount>.95,"relocated core reaches full forest grade")
 FileAccess.open("res://docs/forest188-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"cliff_grass":cliff_grass,"cliff_trees":cliff_trees,"connection_points":s.connection188.size()}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("FOREST188_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
