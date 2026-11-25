extends SceneTree
class ScaleProfile:
 const PPM:=48.0
class DirectNav:
 extends RefCounted
 const CELL:=.05
 var origin:=Vector2(-50,-50)
 func nearest(at: Vector2) -> Vector2i:return Vector2i(((at-origin)/CELL).round())
 func path(from: Vector2,to: Vector2) -> PackedVector2Array:return PackedVector2Array([from,to])
class Surface:
 extends RefCounted
 func walk_height(_at: Vector2,_terrain: bool) -> float:return 0.
class Fixture:
 extends Node3D
 const Profile=ScaleProfile
 var hero: CharacterBody3D
 var camera: Camera3D
 var sun: DirectionalLight3D
 var navigation: RefCounted=DirectNav.new()
 var contact_enabled:=true
 var combat_paused:=false
 var combat_budget105:=true
 var auto114:=false
 var target114: CharacterBody3D
 var legacy_feel:=true
 var player_hp:=100.
 var wave_state:="fighting"
 var enemies: Array=[]
 func floor_height(_at: Vector2) -> float:return 0.
 func goose_recoil_strength() -> float:return 2.
 func cup_contact_enemy(_enemy: Node,_direction: Vector3) -> void:pass
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w:=Fixture.new();root.add_child(w);current_scene=w
 w.hero=CharacterBody3D.new();w.add_child(w.hero)
 w.camera=Camera3D.new();w.add_child(w.camera);w.camera.position=Vector3(0,5,8);w.camera.look_at(Vector3.UP)
 w.sun=DirectionalLight3D.new();w.add_child(w.sun);w.sun.rotation_degrees=Vector3(-55,30,0)
 var wall:=StaticBody3D.new();wall.collision_layer=2;w.add_child(wall)
 var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(.2,3,4);shape.shape=box;wall.add_child(shape);wall.position.y=1.5
 var g=preload("res://scripts/combat/goose384.gd").new();g.battle=w;w.add_child(g)
 await physics_frame
 g.cup_phone=true;g.update_follow(0.,Vector3(-2,0,0),true)
 var peak:=0.0
 for i in 240:
  await physics_frame
  var before: Vector3=g.global_position;g.update_follow(1./60.,Vector3(2,0,0))
  peak=maxf(peak,before.distance_to(g.global_position)*60.)
 check(peak<=g.MAX_SPEED384+.001,"actual displacement respects 4.6m/s")
 check(g.global_position.x<-.31 and g.global_position.x>-.8,"capsule stops at real wall")
 var hold: Vector3=g.global_position;w.combat_paused=true
 g.update_follow(.5,Vector3(20,0,0));check(g.global_position==hold,"paused collision actor holds")
 w.combat_paused=false;w.hero.position.x=20
 g.recoil(Vector3.LEFT);var before: Vector3=g.global_position;g.update_follow(1./60.,Vector3(40,0,0))
 check(before.distance_to(g.global_position)<=g.MAX_SPEED384/60.+.0001,"moving hero and recoil cannot bypass cap")
 w.hero.position=Vector3.ZERO
 var nav=preload("res://scripts/combat/woodland_navigation21.gd").new();nav.bake(w.get_world_3d().direct_space_state,Surface.new(),Vector2.ZERO);w.navigation=nav
 g.update_follow(0.,Vector3(-2,0,0),true)
 var around:=false
 for i in 600:
  await physics_frame;g.update_follow(1./60.,Vector3(2,0,0))
  if absf(g.position.z)>2.3:around=true
  if g.position.x>1.6 and absf(g.position.z)<.4:break
 check(around and g.position.x>1.6,"real baked navigation routes around wall")
 var f:=FileAccess.open("res://docs/motion384-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"failures":failures,"peak_speed":peak,"end":g.position,"detour":around},"\t"));f.close()
 print("MOTION384_DONE ",failures);quit(0 if failures.is_empty() else 1)
