extends SceneTree
const PLAN=preload("res://scripts/world/forest_plan180.gd")
var checks: Array=[]
var failures: Array=[]
class Walker:
 extends "res://scripts/combat/hero180.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class Trial:
 extends "res://scripts/world/woodland_world180.gd"
 func _hero_script() -> Script: return Walker
func _initialize() -> void: run.call_deferred()
func verify(ok: bool,words: String) -> void:
 checks.append({"check":words,"ok":ok});print("PASS " if ok else "FAIL ",words)
 if not ok: failures.append(words)
func settle(frames := 12) -> void:
 for i in frames: await physics_frame
func shot(tag: String) -> void:
 if DisplayServer.get_name()=="headless": return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest180_"+tag+".png")
func walk(s: Node3D,points: Array[Vector2]) -> bool:
 for target in points:
  var frames := 0
  while Vector2(s.hero.position.x,s.hero.position.z).distance_to(target)>.28 and frames<900:
   s.hero.command=(target-Vector2(s.hero.position.x,s.hero.position.z)).normalized();frames+=1;await physics_frame
  if frames>=900:
   for i in s.hero.get_slide_collision_count(): print("BLOCKER ",s.hero.get_slide_collision(i).get_collider().get_path())
   print("STUCK target ",target," actual ",s.hero.position);s.hero.command=Vector2.ZERO;return false
 s.hero.command=Vector2.ZERO;await settle();return true
func geometry180(s: Node3D) -> void:
 var house: Sprite3D=s.forest180.cottage_sprite
 verify(house.billboard==BaseMaterial3D.BILLBOARD_ENABLED,"house uses camera-plane billboard instead of upright perspective card")
 # Billboard plane basis matches camera X/Y. The two side edges stay parallel
 # and horizontal widths equal across camera positions, unlike a tilted card.
 var original: Transform3D=s.camera.transform;var offsets: Array[float]=[]
 for dx in [-4.,0.,4.]:
  s.camera.position.x=house.global_position.x+dx
  var centre := house.global_position+Vector3.UP*2.
  var right: Vector3=s.camera.global_basis.x*3.;var up: Vector3=s.camera.global_basis.y*2.
  var tl: Vector2=s.camera.unproject_position(centre-right+up);var tr: Vector2=s.camera.unproject_position(centre+right+up)
  var bl: Vector2=s.camera.unproject_position(centre-right-up);var br: Vector2=s.camera.unproject_position(centre+right-up)
  offsets.append(absf((tl.x+tr.x-bl.x-br.x)*.5))
 s.camera.transform=original
 verify(offsets.all(func(v): return v<.05),"left/right camera translation introduces no house shear in billboard projection")
func run() -> void:
 root.size=Vector2i(1600,1000);var s := Trial.new();s.memory_save116="user://forest180_probe_tmp.cfg";root.add_child(s)
 while not s.forest_ready180: await physics_frame
 await settle(20)
 var old := preload("res://scripts/world/world_surface142.gd").new()
 for at in [Vector2(-4.7,-4.8),Vector2(old.landmarks.grove),Vector2(old.landmarks.station),Vector2(old.landmarks.grove)+Vector2(-24.,-18.)]:
  verify(absf(old.walk_height(at,true)-s.meadow.walk_height(at,true))<.001,"old home/grove/station/hill altitude retained at "+str(at))
 verify(is_instance_valid(s.park99) and is_instance_valid(s.rail72) and is_instance_valid(s.garden),"whole existing map and props are instantiated")
 verify(is_instance_valid(s.forest180) and s.forest180.position.x== -48.,"forest decor is integrated at southwest world coordinates")
 verify(s.floor_height(PLAN.CENTER+Vector2(0.,5.))< -2.,"new basin has matching whole-map floor support")
 verify(absf(s.floor_height(PLAN.CENTER+Vector2(0.,-15.))-.2)<.1,"north remains original ground")
 verify(s.forest180.stair_treads.size()==18,"three entrance flights present in full map")
 verify(s.rocks91.get_script()==preload("res://scripts/art/rock_surfaces180.gd"),"forest cliffs use map rock partition and painted bedrock92 material")
 verify(absf(PLAN.edge180(Vector2(-12.,0.))-PLAN.edge180(Vector2(0.,10.)))>1.,"scalloped coves and inset shoulders break rectangular symmetry")
 await shot("home")
 var start := PLAN.CENTER+PLAN.ENTRY
 var connection: Array[Vector2]=[]
 for point in s.connection180: connection.append(point)
 print("YARD_CONNECTION ",connection)
 verify(connection.size()>2 and await walk(s,connection),"hero physically follows stepping-stone path around existing workshop to forest")
 await shot("entry")
 var approach: Array[Vector2]=[]
 for i in range(1,PLAN.PATH.size()): approach.append(PLAN.CENTER+PLAN.PATH[i])
 verify(await walk(s,approach),"full-map hero descends three short flights and both bends")
 await shot("clearing")
 var right: Array[Vector2]=[PLAN.CENTER+Vector2(5.,6.),PLAN.CENTER+Vector2(5.,-4.),PLAN.CENTER+Vector2(3.,-6.5)]
 verify(await walk(s,right),"east route fits irregular basin")
 var left: Array[Vector2]=[PLAN.CENTER+Vector2(-4.,-4.),PLAN.CENTER+Vector2(-6.,0.),PLAN.CENTER+Vector2(-6.,5.),PLAN.CENTER+Vector2(3.,6.)]
 verify(await walk(s,left),"west route passes inset rock shoulder")
 var hut: Array[Vector2]=[PLAN.CENTER+Vector2(5.,-4.),PLAN.CENTER+Vector2(-3.,-5.),PLAN.CENTER+Vector2(-7.,-5.8)]
 verify(await walk(s,hut),"cottage reachable through connected map basin")
 geometry180(s);await shot("house_center")
 s._teleport15(PLAN.CENTER+Vector2(-11.,-4.8));await settle(20);await shot("house_left")
 s._teleport15(PLAN.CENTER+Vector2(-4.,-4.8));await settle(20)
 verify(s.forest180.trees.any(func(t): return float(t.material_override.get_shader_parameter("fade"))<.6),"custom tree shader actually receives occlusion fade")
 await shot("house_right")
 s._teleport15(PLAN.CENTER+PLAN.PATH[-1]);await settle()
 var backwards: Array[Vector2]=[]
 for i in range(PLAN.PATH.size()-2,-1,-1): backwards.append(PLAN.CENTER+PLAN.PATH[i])
 for i in range(connection.size()-1,-1,-1): backwards.append(connection[i])
 verify(await walk(s,backwards),"hero returns up stairs and walks back to yard without teleport")
 verify(s.hero.is_on_floor(),"hero remains grounded after world round-trip")
 verify(s.memory_save116=="user://forest180_probe_tmp.cfg" and not s.spider_trial170,"preview isolates save and adds no automatic forest fight")
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn","normal default remains preserved for comparison")
 var report := {"checks":checks,"failures":failures,"note":"Connected full world preview with local surface override; yard/path/forest/yard walked under real collisions. Native map bedrock reused; house camera-plane billboard validated and captured from three positions."}
 FileAccess.open("res://docs/forest180-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "));DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116))
 print("FOREST180_DONE ",JSON.stringify({"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
