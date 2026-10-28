extends SceneTree
const PLAN=preload("res://scripts/world/forest_plan177.gd")
var checks: Array=[]
var failures: Array=[]
class Walker:
 extends "res://scripts/combat/hero30.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command
 func dash_key_down() -> bool: return false
class Trial:
 extends "res://scripts/world/forest_graybox177.gd"
 func hero_script() -> Script: return Walker
func _initialize() -> void: run.call_deferred()
func verify(ok: bool,words: String) -> void:
 checks.append({"ok":ok,"check":words});print("PASS " if ok else "FAIL ",words)
 if not ok: failures.append(words)
func settle(frames := 10) -> void:
 for i in frames: await physics_frame
func shot(tag: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest177_"+tag+".png")
func walk(s: Node3D,points: Array[Vector2]) -> bool:
 for p in points:
  var target := PLAN.CENTER+p;var frames := 0
  while Vector2(s.hero.position.x,s.hero.position.z).distance_to(target)>.27 and frames<900:
   s.hero.command=(target-Vector2(s.hero.position.x,s.hero.position.z)).normalized();frames+=1;await physics_frame
  if frames>=900:
   print("STUCK ",p," actual ",s.hero.position);s.hero.command=Vector2.ZERO;return false
 s.hero.command=Vector2.ZERO;await settle();return true
func ray(s: Node3D,a: Vector3,b: Vector3,mask := 2) -> Dictionary:
 return s.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(a,b,mask))
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial.new();root.add_child(s)
 while not s.ready177: await physics_frame
 await settle()
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn","normal main scene remains world169")
 verify(s.get_children().all(func(n): return not n.name.to_lower().contains("woodland")),"sandbox does not instantiate old world or its terrain")
 verify(PLAN.CENTER==Vector2(-48.,0.) and s.terrain.position.x== -48.,"geometry uses surveyed southwest world coordinates")
 verify(PLAN.CLEARING.size==Vector2(28.,24.) and PLAN.path_length()>25. and PLAN.path_length()<35.,"28x24 clearing and 25-35m approach")
 verify(s.geese.size()==3 and s.enemies.is_empty(),"three scale geese and no enemies in terrain preview")
 verify(s.hero.is_on_floor(),"entry has physical floor support")
 await shot("entry")
 s.overview=true;s.update_camera(0.,true);await shot("overview");s.overview=false;s.update_camera(0.,true)
 var approach: Array[Vector2]=[]
 for i in range(1,PLAN.PATH.size()): approach.append(PLAN.PATH[i])
 verify(await walk(s,approach),"hero physically walks both bends from entry to lowland")
 verify(absf(s.hero.position.y-PLAN.BASE)<.1,"approach ends on lower forest floor")
 await shot("clearing")
 verify(await walk(s,[Vector2(5.,7.),Vector2(5.,-4.),Vector2(3.,-8.)]),"hero walks east route around central roots")
 await shot("north")
 verify(await walk(s,[Vector2(-4.,-4.),Vector2(-6.,-1.),Vector2(-6.,5.),Vector2(3.,7.)]),"hero walks west outer route and returns around roots")
 await shot("west")
 verify(await walk(s,[Vector2(8.,5.),Vector2(12.,0.),Vector2(12.,-5.),Vector2(12.,-10.),Vector2(12.,-15.)]),"hero walks east ramp up to north terrace without teleporting")
 verify(s.hero.is_on_floor() and absf(s.hero.position.y-PLAN.BASE-PLAN.RISE)<.12,"north terrace has real support 2.4m above clearing")
 await shot("terrace")
 verify(await walk(s,[Vector2(3.,-15.),Vector2(-10.,-15.),Vector2(3.,-15.),Vector2(12.,-15.),Vector2(12.,-10.),Vector2(12.,-4.),Vector2(7.,-3.)]),"upper terrace traverses both directions and ramp returns to lowland")
 verify(absf(s.hero.position.y-PLAN.BASE)<.12,"ramp descent returns to original low floor height")
 verify(await walk(s,[Vector2(3.,-7.),Vector2(-3.,-5.),Vector2(-8.,-5.8)]),"cottage doorway approach is reachable on lower level")
 await shot("cottage")
 var origin := Vector3(PLAN.CENTER.x-1.,1.,0.)
 verify(not ray(s,origin+Vector3(-5.,0.,0.),origin+Vector3(5.,0.,0.)).is_empty(),"central tree blocks direct horizontal movement/projectiles")
 verify(not ray(s,Vector3(-48.,1.,-10.),Vector3(-48.,1.,-15.)).is_empty(),"north bank is solid instead of a walk-through visual")
 s.teleport(PLAN.CENTER+Vector2(-1.,-3.));await settle(25)
 verify(s.terrain.fading.any(func(n): return n.transparency>.4),"foreground occluder fades around hero")
 var collision := s.hero.test_move(s.hero.global_transform,Vector3(0.,0.,4.))
 verify(collision,"tree/root collision remains solid while visual fades")
 s.teleport(PLAN.CENTER+Vector2(12.,9.));await settle();s.hero.request_dash(Vector2.RIGHT);await settle(20)
 verify(s.hero.position.x<=PLAN.CENTER.x+14.1,"dash cannot escape finite clearing boundary")
 s.teleport(PLAN.CENTER+PLAN.ENTRY);await settle();verify(s.hero.is_on_floor() and s.hero.position.y>0.,"return-to-entry resets movement and preserves grounded actor")
 s.overview=true;s.update_camera(0.,true);await shot("overview_final")
 var report := {"checks":checks,"failures":failures,"approach_meters":PLAN.path_length(),"clearing_size":"28x24m","north_rise":PLAN.RISE,"note":"Standalone geometry in surveyed coordinates; real input-driven walking through approach, both root routes and raised terrace. No old scenes, default config, saves or combat modified."}
 FileAccess.open("res://docs/forest177-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "))
 print("FOREST177_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
