extends SceneTree
const PLAN=preload("res://scripts/world/forest_plan179.gd")
var checks: Array=[]
var failures: Array=[]
class Walker:
 extends "res://scripts/combat/hero179.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command
 func dash_key_down() -> bool: return false
class Trial:
 extends "res://scripts/world/forest_graybox179.gd"
 func hero_script() -> Script: return Walker
func _initialize() -> void: run.call_deferred()
func verify(ok: bool,words: String) -> void:
 checks.append({"check":words,"ok":ok});print("PASS " if ok else "FAIL ",words)
 if not ok: failures.append(words)
func settle(frames := 12) -> void:
 for i in frames: await physics_frame
func shot(tag: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest179_"+tag+".png")
func walk(s: Node3D,points: Array[Vector2]) -> bool:
 for p in points:
  var target := PLAN.CENTER+p;var frames := 0
  while Vector2(s.hero.position.x,s.hero.position.z).distance_to(target)>.25 and frames<800:
   s.hero.command=(target-Vector2(s.hero.position.x,s.hero.position.z)).normalized();frames+=1;await physics_frame
  if frames>=800:
   print("STUCK target ",p," actual ",s.hero.position);s.hero.command=Vector2.ZERO;return false
 s.hero.command=Vector2.ZERO;await settle();return true
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial.new();root.add_child(s)
 while not s.ready179: await physics_frame
 await settle()
 verify(absf(s.camera.rotation_degrees.x+25.)<.01,"actual following camera looks down 25 degrees")
 verify(absf(PLAN.height(Vector2(0.,-15.))-.2)<.001,"north remains at original 0.2m altitude")
 verify(absf(PLAN.height(Vector2(0.,5.))+2.2)<.001,"forest floor is lowered 2.4m rather than raising north")
 verify(PLAN.FLIGHTS.size()==3 and s.terrain.stair_treads.size()==18,"three short stone flights with six treads each")
 for p in [9.5,17.,24.5]: verify(absf(PLAN.path_y(p)-PLAN.path_y(p+.4))<.001,"flat landing at approach distance %.1fm"%p)
 verify(s.hero.is_on_floor() and absf(s.hero.position.y-PLAN.TOP)<.1,"entry stays grounded on original altitude")
 verify(s.terrain.trees.size()>15 and s.terrain.ribbons.size()==2,"existing tree art reused and ribbon meshes remain independent")
 verify(s.terrain.cottage_sprite.texture.get_image().get_pixel(0,0).a<.1,"corrected right-facing cottage preserves alpha")
 await shot("entry")
 verify(await walk(s,[PLAN.path_point(7.)]),"hero walks down first short stair flight")
 await shot("stairs_first")
 var approach: Array[Vector2]=[PLAN.PATH[2],PLAN.PATH[3],PLAN.PATH[4],PLAN.PATH[5]]
 verify(await walk(s,approach),"hero descends all flights and both bends into forest")
 verify(absf(s.hero.position.y-PLAN.BASE)<.12,"approach reaches physical sunken floor")
 await shot("clearing")
 verify(await walk(s,[Vector2(5.,7.),Vector2(5.,-4.),Vector2(3.,-8.)]),"east root route remains passable")
 verify(await walk(s,[Vector2(-4.,-4.),Vector2(-6.,0.),Vector2(-6.,5.),Vector2(3.,7.)]),"west root route remains passable")
 verify(await walk(s,[Vector2(8.,5.),Vector2(12.,0.),Vector2(12.,-5.),Vector2(12.,-10.),Vector2(12.,-15.)]),"east return ramp reaches original north ground")
 verify(s.hero.is_on_floor() and absf(s.hero.position.y-PLAN.TOP)<.12,"north support is unchanged original altitude")
 await shot("north")
 verify(await walk(s,[Vector2(12.,-10.),Vector2(12.,-4.),Vector2(7.,-3.),Vector2(3.,-7.),Vector2(-3.,-5.),Vector2(-8.,-5.8)]),"hero returns to lowland and reaches cottage")
 await shot("cottage")
 s.teleport(PLAN.CENTER+Vector2(-8.,-11.1));await settle(40);verify(s.terrain.cottage_sprite.transparency>.6,"house fades when hero is behind")
 s.teleport(PLAN.CENTER+PLAN.PATH[-1]);await settle()
 var backwards: Array[Vector2]=[]
 for i in range(PLAN.PATH.size()-2,-1,-1): backwards.append(PLAN.PATH[i])
 verify(await walk(s,backwards),"hero walks UP all three stair flights back to entrance")
 verify(s.hero.is_on_floor() and absf(s.hero.position.y-PLAN.TOP)<.12,"return stairs restore entry altitude")
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn" and s.enemies.is_empty(),"normal default unchanged; no new enemy encounter or progression")
 s.overview=true;s.update_camera(0.,true);await shot("overview")
 var report := {"checks":checks,"failures":failures,"camera_down_degrees":25,"original_ground_y":PLAN.TOP,"forest_floor_y":PLAN.BASE,"short_stair_flights":3,"note":"Standalone first terrain pass. Native terrain collision and visible 13cm treads with smooth collision support per short flight; existing tree art reused, cloth independent; new cottage pixels need user direction/elevation review."}
 FileAccess.open("res://docs/forest179-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "))
 print("FOREST179_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
