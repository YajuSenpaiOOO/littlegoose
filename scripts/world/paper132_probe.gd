extends "res://scripts/world/combat111_probe.gd"
class Sample:
 extends "res://scripts/world/woodland_world132.gd"
func run() -> void:
 var s := Sample.new();s.memory_save116="user://paper132_probe_%d.cfg"%Time.get_ticks_msec();root.add_child(s)
 while not is_instance_valid(s.drops120): await physics_frame
 s.paper_trial129=true;s.start_combat();disable_enemies(s);s.hero.set_physics_process(false)
 var a: CharacterBody3D=s.enemies[0];var b: CharacterBody3D=s.enemies[1]
 a.play119();b.play119();a.set_physics_process(false);b.set_physics_process(false)
 var g: Vector2=s.meadow.landmarks.grove
 var centre := Vector3(g.x,s.floor_height(g)+.05,g.y)
 a.position=centre;b.position=centre;a.drift130=Vector2.ZERO;b.drift130=Vector2.ZERO;a.paper_lift129=.7;b.paper_lift129=.7
 verify((a.collision_mask&16)==0 and (b.collision_mask&16)==0,"paper peers no longer have hard body collision")
 verify((a.collision_mask&3)==3 and a.hit_area.collision_layer==8,"world collision and projectile hurt areas remain enabled")
 var force_a: Vector2=a.separation132(g);var force_b: Vector2=b.separation132(g)
 verify(force_a.length()>.01 and force_a.dot(force_b)<0.,"coincident sheets receive stable opposing separation")
 verify(force_a.length()<=.721,"soft separation is bounded rather than an explosive push")
 b.paper_lift129=1.5
 verify(a.separation132(g)==Vector2.ZERO,"different floating levels can pass through without artificial repulsion")
 b.paper_lift129=.7;a.paper_state129="gust"
 verify(a.separation132(g)==Vector2.ZERO,"gust attacks keep their advertised curve instead of dodging peers")
 a.paper_state129="drift"
 a.position=centre+Vector3(-.85,0.,0.);b.position=centre+Vector3(.85,0.,0.)
 a.velocity=Vector3(2.,0.,0.);b.velocity=Vector3(-2.,0.,0.)
 for i in 55:
  await physics_frame
  a.velocity=Vector3(2.,-.3,0.);b.velocity=Vector3(-2.,-.3,0.);a.move_and_slide();b.move_and_slide()
 verify(a.position.x>b.position.x,"two sheets physically cross instead of locking against each other")
 a.position=centre;b.position=centre;a.drift130=Vector2.ZERO;b.drift130=Vector2.ZERO;a.gust_wait130=99.;b.gust_wait130=99.
 a.set_physics_process(true);b.set_physics_process(true)
 await settle72(110)
 verify(a.position.distance_to(b.position)>.3,"overlapping active sheets naturally disperse under wind and soft avoidance")
 s.home116();await settle72(2)
 var data := {"checks":checks,"failures":failures}
 FileAccess.open("res://docs/paper132-validation.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER132_DONE ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
