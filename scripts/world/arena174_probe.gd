extends "res://scripts/world/web173_probe.gd"
const PLAN=preload("res://scripts/world/arena_layout174.gd")
class Walker174:
 extends "res://scripts/combat/hero173.gd"
 var command174 := Vector2.ZERO
 func movement_input() -> Vector2: return command174 if controls_enabled else Vector2.ZERO
 func dash_key_down() -> bool: return false
 func parry_key_down() -> bool: return false
class Trial174:
 extends "res://scripts/world/woodland_world174.gd"
 func _hero_script() -> Script: return Walker174
func shot174(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/arena174_"+tag+".png")
func route_length174(path: PackedVector2Array) -> float:
 var length := 0.
 for i in range(1,path.size()): length+=path[i-1].distance_to(path[i])
 return length
func walk174(s: Node3D,points: Array[Vector2]) -> bool:
 for point in points:
  var target := PLAN.CENTER+point;var frames := 0
  while Vector2(s.hero.position.x,s.hero.position.z).distance_to(target)>.38 and frames<480:
   s.hero.command174=(target-Vector2(s.hero.position.x,s.hero.position.z)).normalized();frames+=1;await physics_frame
  if frames>=480: s.hero.command174=Vector2.ZERO;return false
 s.hero.command174=Vector2.ZERO;await settle(8);return true
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Trial174.new();s.memory_save116="user://arena174_probe_tmp.cfg";root.add_child(s)
 while not s.arena_ready174: await physics_frame
 await settle(8);freeze171(s)
 verify(PLAN.CENTER.distance_to(s.original_grove174)>300. and s.meadow.landmarks.grove==s.original_grove174,"arena is detached and original grove coordinates remain unchanged")
 var unchanged := s.trees.size()==s.original_trees174.size()
 for i in s.trees.size(): unchanged=unchanged and s.trees[i].root.position==s.original_trees174[i]
 verify(unchanged,"all existing world tree positions remain unchanged")
 verify(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/world/world169.tscn","normal main scene remains world169")
 verify(Vector2(s.hero.position.x,s.hero.position.z).distance_to(PLAN.CENTER+PLAN.ENTRY)<.2,"preview starts in the wide entry pocket")
 verify(s.enemies.size()==3 and s.enemies.all(func(e): return e.get_script().resource_path.ends_with("spider173.gd")),"same three-spider implementation reused without new control skill")
 var nav: RefCounted=s.navigation
 var right: PackedVector2Array=nav.path(PLAN.CENTER+PLAN.ENTRY,PLAN.CENTER+Vector2(3.5,0.));right.append_array(nav.path(PLAN.CENTER+Vector2(3.5,0.),PLAN.CENTER+PLAN.NORTH))
 var left: PackedVector2Array=nav.path(PLAN.CENTER+PLAN.ENTRY,PLAN.CENTER+PLAN.LEFT_BAY);left.append_array(nav.path(PLAN.CENTER+PLAN.LEFT_BAY,PLAN.CENTER+PLAN.NORTH))
 verify(right.size()>2 and left.size()>2,"navigation finds both sides of the central trunk")
 verify(route_length174(left)>route_length174(right),"left outer route is longer than the short right route")
 await shot174("entry")
 var short_points: Array[Vector2]=[Vector2(3.5,5.),Vector2(3.5,-4.),PLAN.NORTH]
 verify(await walk174(s,short_points),"actual hero walks the short route without collision traps")
 await shot174("north")
 var long_points: Array[Vector2]=[Vector2(-6.,-4.),Vector2(-6.,5.),PLAN.ENTRY]
 verify(await walk174(s,long_points),"actual hero walks the wide outer return route")
 verify(absf(s.hero.position.y-PLAN.HEIGHT)<.2,"hero stays grounded on isolated floor")
 s._teleport15(PLAN.CENTER+PLAN.LEFT_BAY);await settle(5);verify(s.hero.is_on_floor(),"left output bay has real floor support")
 await shot174("left_bay")
 s._teleport15(PLAN.CENTER+PLAN.RIGHT_BAY);await settle(5);verify(s.hero.is_on_floor(),"right rear output bay has real floor support")
 await shot174("right_bay")
 var from := PLAN.CENTER+Vector2(-4.,0.);var to := PLAN.CENTER+Vector2(2.,0.)
 verify(not s.line_clear110(from,to),"central trunk actually blocks straight projectiles")
 verify(s.line_clear110(PLAN.CENTER+Vector2(3.5,4.),PLAN.CENTER+Vector2(3.5,-4.)),"short route retains a usable firing line")
 var gel: int=s.memory_kit116.gel119;var event: int=s.memory_kit116.next_event119
 await key(KEY_F6);freeze171(s);verify(s.enemies.size()==1 and Vector2(s.hero.position.x,s.hero.position.z).distance_to(PLAN.CENTER+PLAN.ENTRY)<.3,"F6 single spider restarts inside isolated arena")
 await key(KEY_F6);await key(KEY_3);freeze171(s);verify(s.enemies.size()==3 and s.buffs.level("paper_plane")==1 and s.skills110.geese110.size()==2,"three-geese aircraft preset remains available")
 await key(KEY_F4);verify(s.spider_trial170 and not s.paper_trial129,"legacy region-switch hotkeys cannot leave the isolated preview")
 s._clear_combat_shots()
 for e in s.enemies: e.set_physics_process(true)
 var saw_web := false;var saw_ball := false
 for i in 660:
  saw_web=saw_web or not s.pads172.is_empty();saw_ball=saw_ball or not s.silk171.is_empty()
  await physics_frame
 verify(saw_web and saw_ball,"natural AI navigates arena and uses existing webs and rolling balls")
 await shot174("combat")
 verify(s.memory_kit116.gel119==gel and s.memory_kit116.next_event119==event,"preview neither awards materials nor advances formal events")
 s._clear_combat_shots();verify(s.pads172.is_empty() and s.silk171.is_empty(),"restart cleanup clears arena hazards")
 var report := {"checks":checks,"failures":failures,"right_route_length":route_length174(right),"left_route_length":route_length174(left),"note":"New detached test region only: original trees/landmarks/default entry unchanged, both routes physically walked, old combat presets and natural hazards reused."}
 FileAccess.open("res://docs/arena174-validation.json",FileAccess.WRITE).store_string(JSON.stringify(report," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path("user://arena174_probe_tmp.cfg"));print("ARENA174_DONE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
