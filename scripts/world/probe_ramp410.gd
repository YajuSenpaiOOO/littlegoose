extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var host:=Node3D.new();root.add_child(host)
 var kit=load("res://scripts/room/geometry_kit405.gd").new();host.add_child(kit)
 var yard=load("res://scripts/room/home_yard410.gd").new();host.add_child(yard);yard.build403(kit);yard.set_open404(true)
 kit.collider(host,Vector3(0,-.2,5.5),Vector3(4.,.17,8.))
 var actor:=CharacterBody3D.new();host.add_child(actor);var collider:=CollisionShape3D.new();var capsule:=CapsuleShape3D.new();capsule.radius=.24;capsule.height=1.3;collider.shape=capsule;collider.position.y=.65;actor.add_child(collider);actor.position=Vector3(0,.05,3.6)
 for i in 40:await physics_frame
 for i in 90:actor.velocity=Vector3(0,-.3,-2.5);actor.move_and_slide();await physics_frame
 print("RAMP410 ",actor.position);quit(0 if actor.position.z<2.15 else 1)
