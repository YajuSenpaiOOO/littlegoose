extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var host:=Node3D.new();root.add_child(host)
 var kit=load("res://scripts/room/geometry_kit405.gd").new();host.add_child(kit)
 var yard=load("res://scripts/room/home_yard413.gd").new();host.add_child(yard);yard.build403(kit)
 var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-48,-155,0);sun.light_energy=.7;sun.shadow_enabled=true;host.add_child(sun)
 var env:=WorldEnvironment.new();env.environment=Environment.new();env.environment.background_mode=Environment.BG_COLOR;env.environment.background_color=Color("93a086");env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.environment.ambient_light_color=Color("e9e1ca");env.environment.ambient_light_energy=.7;host.add_child(env)
 var camera:=Camera3D.new();camera.rotation_degrees.x=-25;camera.fov=42;host.add_child(camera);camera.position=Vector3(0,3.4,0)+camera.basis.z*23.;camera.make_current()
 for i in 10:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/home413-structure.png")
 print("HOUSE413_PROBE_OK ",yard.tiles413);quit()
