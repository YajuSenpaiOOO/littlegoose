extends "res://scripts/world/validate_motion384.gd"
func run() -> void:
 var w:=Fixture.new();root.add_child(w);current_scene=w
 w.hero=CharacterBody3D.new();w.add_child(w.hero)
 w.camera=Camera3D.new();w.add_child(w.camera);w.camera.position=Vector3(0,5,8);w.camera.look_at(Vector3.UP)
 w.sun=DirectionalLight3D.new();w.add_child(w.sun);w.sun.rotation_degrees=Vector3(-55,30,0)
 var wall:=StaticBody3D.new();wall.collision_layer=2;w.add_child(wall)
 var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(.2,3,4);shape.shape=box;wall.add_child(shape);wall.position.y=1.5
 var g=preload("res://scripts/combat/goose385.gd").new();g.battle=w;w.add_child(g)
 await physics_frame
 check(g.find_children("*","CollisionObject3D",true,false).is_empty(),"no physical body remains")
 g.cup_phone=true;g.update_follow(0.,Vector3(-2,0,0),true)
 var peak:=0.0;var detour:=0.0
 for i in 240:
  await physics_frame;var before: Vector3=g.global_position;g.update_follow(1./60.,Vector3(2,0,0))
  peak=maxf(peak,before.distance_to(g.global_position)*60.);detour=maxf(detour,absf(g.position.z))
 check(peak<=g.MAX_SPEED385+.001,"actual world displacement cap retained")
 check(g.position.x>1.8 and detour<.001,"free flight passes scenery without detour")
 var before: Vector3=g.global_position;w.hero.position.x=20;g.recoil(Vector3.LEFT);g.update_follow(1./60.,Vector3(40,0,0))
 check(before.distance_to(g.global_position)<=g.MAX_SPEED385/60.+.0001,"hero movement/recoil cannot bypass cap")
 w.combat_paused=true;var hold: Vector3=g.global_position;g.update_follow(.5,Vector3(40,0,0));check(g.global_position==hold,"paused position holds")
 var f:=FileAccess.open("res://docs/motion385-validation.json",FileAccess.WRITE);f.store_string(JSON.stringify({"failures":failures,"peak_speed":peak,"detour":detour},"\t"));f.close()
 print("MOTION385_DONE ",failures);quit(0 if failures.is_empty() else 1)
