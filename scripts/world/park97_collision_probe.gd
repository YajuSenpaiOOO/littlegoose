extends "res://scripts/world/woodland97_probe.gd"
func run() -> void:
 var sample := Sample97.new();root.add_child(sample)
 while not sample.woodland_ready97: await physics_frame
 await settle72(20)
 var g: Vector2=sample.meadow.landmarks.grove
 sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(-7.5,0));await settle72(10)
 var reached := await walk_to(sample,g+Vector2(-8.75,0))
 print("COLLISION97 reached=",reached," hero=",sample.hero.position)
 for i in sample.hero.get_slide_collision_count():
  var hit: KinematicCollision3D=sample.hero.get_slide_collision(i)
  print("SLIDE97 ",hit.get_collider().get_path()," normal=",hit.get_normal()," at=",hit.get_position())
 var sphere := SphereShape3D.new();sphere.radius=.42
 var query := PhysicsShapeQueryParameters3D.new();query.shape=sphere;query.collision_mask=3
 query.transform=Transform3D(Basis.IDENTITY,Vector3(g.x-8.75,sample.floor_height(g+Vector2(-8.75,0))+.65,g.y))
 for hit in sample.get_world_3d().direct_space_state.intersect_shape(query,20): print("OVERLAP97 ",hit.collider.get_path())
 for x in [-9.5,-9.25,-9.,-8.75,-8.5,-8.25,-8.]: print("FLOOR97 ",x," ",sample.floor_height(g+Vector2(x,0))," ",sample.floor_normal(g+Vector2(x,0)))
 quit()
