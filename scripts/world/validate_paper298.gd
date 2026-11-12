extends "res://scripts/world/validate_plush220.gd"
class Harness:
 extends "res://scripts/world/woodland_world298.gd"
 func export_stats226() -> Error:return OK
func shot298(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper298-"+tag+".png")
func run() -> void:
 w=Harness.new();root.add_child(w);current_scene=w
 while not w.available297:await process_frame
 var s=w.stage297;s.set_process(false)
 for i in 15:await physics_frame
 check(w.hero.position.y>10.2,"hero starts on native summit grass")
 check(s.global_position.y>11.,"castle uses upper summit shelf")
 check(s.lanes.is_empty() and s.book==null and s.plinth==null,"no 3D floor, flying book or translating plinth")
 check(is_equal_approx(s.castle.pixel_size*float(s.data.castle.span[0]),9.8),"castle enlarged to9.8m")
 var home=s.girl.position;var previous=Vector3.ZERO
 for state in [[0.,"before"],[2.8,"scenery"],[4.7,"gate"],[6.7,"emerging"],[8.4,"settled"]]:
  s.sample(state[0]);await shot298(state[1])
  check(s.girl.position.is_equal_approx(home),"girl never slides: "+state[1])
  check(s.castle.rotation.is_finite() and s.puppet298.position.is_finite(),"finite poses: "+state[1])
  if state[1]=="gate":
   check(s.gate_open298>.9 and s.door_shape298.disabled,"open gate releases doorway collision")
   previous=s.puppet298.position
  if state[1]=="emerging":
   check(s.puppet298.position.z>previous.z+1. and s.puppet298.visible,"puppet travels out from behind castle")
   check(absf(s.puppet298.global_position.y-w.floor_height(Vector2(s.puppet298.global_position.x,s.puppet298.global_position.z))-.04)<.02,"entry follows summit ground, not underground emergence")
 check(not s.door_shape298.disabled and s.bodies.all(func(b):return not b.disabled),"settled door and wall footprints are solid")
 for i in 3:await physics_frame
 var space=w.get_world_3d().direct_space_state
 var start=s.global_position+Vector3(0,.7,2.);var end=s.global_position+Vector3(0,.7,-.7)
 check(not space.intersect_ray(PhysicsRayQueryParameters3D.create(start,end,2)).is_empty(),"native ray hits closed door")
 s.sample(5.);for i in 3:await physics_frame
 check(space.intersect_ray(PhysicsRayQueryParameters3D.create(start,end,2)).is_empty(),"native ray passes open doorway")
 s.sample(8.6);s._process(.01);check(s.finished and w.hero.controls_enabled and not w.combat_paused,"presentation returns controls")
 s.start();check(s.age==0. and not s.puppet298.visible,"replay hides puppet behind scene")
 s.cancel();check(w.hero.controls_enabled and not w.combat_paused,"cancel restores input")
 FileAccess.open("res://docs/paper298-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"summit":[s.global_position.x,s.global_position.y,s.global_position.z],"scope":"opening and gate entry only; no enemy AI/damage"},"  "))
 quit(0 if checks.all(func(c):return c.pass) else 1)
