extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
 root.size=Vector2i(1000,800)
 var scene := Node3D.new();root.add_child(scene)
 var camera := Camera3D.new();scene.add_child(camera);camera.position=Vector3(0,2.8,7.);camera.look_at(Vector3(0,1.1,0));camera.current=true
 var environment := WorldEnvironment.new();var env := Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color(.1,.12,.15);env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color.WHITE;env.ambient_light_energy=.4;environment.environment=env;scene.add_child(environment)
 var light := OmniLight3D.new();light.position=Vector3(0,4,2);light.omni_range=9.;light.light_energy=.7;scene.add_child(light)
 for i in 4:
  var frames=preload("res://scripts/art/hero_frames.gd").new("hero_pixel",["walk_backup.json","walk_back_v1.json","walk_left_v1.json","walk_right_v1.json"][i])
  var sprite := Sprite3D.new();sprite.texture=frames.idle;sprite.position=Vector3((i-1.5)*1.25,1.1,0);sprite.pixel_size=.0025;sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;scene.add_child(sprite)
  var material=preload("res://scripts/combat/hero192.gd").make_receiver192();material.albedo_texture=sprite.texture.atlas if sprite.texture is AtlasTexture else sprite.texture;sprite.material_override=material
 for i in 12: await process_frame
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("res://docs/captures/world_restart/material192_atlas.png");quit()
