extends SceneTree
func _initialize() -> void: run.call_deferred()
func capture199(tag: String) -> Image:
 for i in 12: await process_frame
 await RenderingServer.frame_post_draw
 var image := root.get_texture().get_image();image.save_png("res://docs/captures/world_restart/shadow199_"+tag+".png");return image
func run() -> void:
 root.size=Vector2i(800,700)
 var scene := Node3D.new();root.add_child(scene)
 var camera := Camera3D.new();scene.add_child(camera);camera.position=Vector3(0,6,8);camera.look_at(Vector3.ZERO);camera.current=true
 var environment := WorldEnvironment.new();var env := Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color.BLACK;env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_energy=.15;environment.environment=env;scene.add_child(environment)
 var sun := DirectionalLight3D.new();sun.rotation_degrees=Vector3(-45,-25,0);sun.shadow_enabled=true;sun.shadow_bias=.02;scene.add_child(sun)
 var ground := MeshInstance3D.new();var plane := PlaneMesh.new();plane.size=Vector2(10,10);ground.mesh=plane;var material := StandardMaterial3D.new();material.albedo_color=Color(.65,.65,.65);ground.material_override=material;scene.add_child(ground)
 var image := Image.create(2,2,false,Image.FORMAT_RGBA8);image.fill(Color.WHITE)
 var tree := Sprite3D.new();tree.texture=ImageTexture.create_from_image(image);tree.pixel_size=1.;tree.position.y=1.1;tree.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/forest_wind46.gdshader");ink.set_shader_parameter("paint",tree.texture);tree.material_override=ink;scene.add_child(tree)
 ink.set_shader_parameter("fade",1.);var solid := await capture199("solid")
 ink.set_shader_parameter("fade",.01);var faded := await capture199("faded")
 var lifted := 0
 for y in solid.get_height():
  for x in solid.get_width():
   if faded.get_pixel(x,y).r-solid.get_pixel(x,y).r>.04: lifted+=1
 var result := {"shadow_pixels_lightened":lifted,"passed":lifted>100}
 FileAccess.open("res://docs/shadow199-validation.json",FileAccess.WRITE).store_string(JSON.stringify(result," "));print("SHADOW199 ",JSON.stringify(result));quit(0 if result.passed else 1)
