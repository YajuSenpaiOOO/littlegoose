extends SceneTree
var values := {}
func _initialize() -> void: run.call_deferred()
func capture(tag: String) -> float:
 for i in 8: await process_frame
 await RenderingServer.frame_post_draw
 var image := root.get_texture().get_image();image.save_png("res://docs/captures/world_restart/normal192_"+tag+".png")
 var total := 0.
 for y in range(250,550):
  for x in range(350,650):
   var c := image.get_pixel(x,y);total+=c.r+c.g+c.b
 return total/90000.
func run() -> void:
 root.size=Vector2i(1000,800)
 var scene := Node3D.new();root.add_child(scene)
 var camera := Camera3D.new();scene.add_child(camera);camera.position=Vector3(0,2.8,7.);camera.look_at(Vector3(0,1.1,0));camera.current=true
 var environment := WorldEnvironment.new();var env := Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color.BLACK;env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color.WHITE;env.ambient_light_energy=.04;environment.environment=env;scene.add_child(environment)
 var light := SpotLight3D.new();scene.add_child(light);light.position=Vector3(0,4,.2);light.look_at(Vector3(0,1.,0));light.spot_range=8.;light.spot_angle=30.;light.light_energy=1.;light.shadow_enabled=true;light.light_cull_mask=3;light.shadow_caster_mask=2
 var frames=preload("res://scripts/art/hero_frames.gd").new("hero_pixel","walk_backup.json")
 var sprite := Sprite3D.new();sprite.texture=frames.idle;sprite.position=Vector3(0,1.1,0);sprite.pixel_size=.0025;sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;scene.add_child(sprite)
 var material=preload("res://scripts/combat/hero192.gd").make_receiver192();material.albedo_texture=sprite.texture.atlas if sprite.texture is AtlasTexture else sprite.texture;sprite.material_override=material
 material.normal_enabled=false;values.flat=await capture("flat")
 material.normal_enabled=true;values.normal=await capture("normal")
 var blocker := MeshInstance3D.new();var box := BoxMesh.new();box.size=Vector3(3,.2,2.);blocker.mesh=box;blocker.position=Vector3(0,2.5,.1);blocker.layers=2;blocker.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY;scene.add_child(blocker)
 values.shadow=await capture("shadow")
 values.overhead_works=values.normal>values.flat*1.15;values.shadow_received=values.shadow<values.normal*.8
 FileAccess.open("res://docs/normal192-validation.json",FileAccess.WRITE).store_string(JSON.stringify(values," "))
 print("NORMAL192 ",JSON.stringify(values));quit(0 if values.overhead_works and values.shadow_received else 1)
