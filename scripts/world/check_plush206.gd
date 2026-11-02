extends SceneTree
class HeroFixture:
 extends CharacterBody3D
 var dodge_invulnerability=0.
 var parry_t=0.
 var guarding109=false
 func can_parry() -> bool: return parry_t>0.
 func consume_parry() -> void: parry_t=0.
class WorldFixture:
 extends Node3D
 var hero: CharacterBody3D
 var camera: Camera3D
 var sun: DirectionalLight3D
 var contact_enabled=false
 var combat_budget105=true
 var preview_hearts206=5
 func _ready() -> void:
  hero=HeroFixture.new();add_child(hero)
  camera=Camera3D.new();camera.position=Vector3(0,5,8);add_child(camera);camera.look_at(Vector3.ZERO)
  sun=DirectionalLight3D.new();sun.rotation_degrees.x=-50.;add_child(sun)
 func floor_height(at: Vector2) -> float: return at.x*.02
 func notice206(_value: String) -> void: pass
class RigFixture:
 extends Node3D
 var body: AnimatableBody3D
 var running=true
 func _ready() -> void: body=AnimatableBody3D.new();add_child(body)
 func opaque_bounds(image: Image) -> Rect2i: return preload("res://scripts/art/sister_transport205.gd").opaque_bounds(image)
var checks: Array[Dictionary]=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,name206: String) -> void:
 checks.append({"name":name206,"pass":ok});print("206_TARGETED ","PASS " if ok else "FAIL ",name206)
func run() -> void:
 var world=WorldFixture.new();root.add_child(world)
 var rig=RigFixture.new();world.add_child(rig)
 var drops=preload("res://scripts/combat/plush_drop206.gd").new();drops.world=world;drops.rig=rig;drops.manual206=true;world.add_child(drops)
 world.hero.position=Vector3(1.,.02,0.)
 drops.spawn206(Vector2.ZERO,Vector3.UP)
 drops.advance206(1.7);drops._process(0.)
 var item=drops.records[0]
 var grounded=item.lane.visible and item.lane.mesh!=null
 if grounded:
  for vertex in item.lane.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
   var point: Vector3=item.lane.to_global(vertex)
   if absf(point.y-world.floor_height(Vector2(point.x,point.z))-.045)>.001: grounded=false
 check(grounded,"windup direction lane follows terrain instead of HUD overlay")
 world.hero.parry_t=.15;drops.resolve206(item)
 var stopped: Vector2=item.at;drops.advance206(.1)
 check(item.age>=2.65 and item.at.is_equal_approx(stopped) and drops.parries206==1,"parry interrupts pounce and makes plush flop in place")
 var age: float=item.age;rig.running=false;drops.manual206=false;drops._physics_process(.5)
 check(item.age==age,"paused transport freezes live toy attacks")
 drops.clear206();world.queue_free();await process_frame
 var failures=checks.filter(func(c): return not c["pass"])
 FileAccess.open("res://docs/sister206-targeted.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failed":failures.size()},"\t"))
 quit(0 if failures.is_empty() else 1)
