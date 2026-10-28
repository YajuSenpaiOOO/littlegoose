extends SceneTree
func _initialize() -> void: run.call_deferred()
func texture199(color: Color) -> Texture2D:
 var img := Image.create(2,2,false,Image.FORMAT_RGBA8);img.fill(color);return ImageTexture.create_from_image(img)
func run() -> void:
 root.size=Vector2i(800,700)
 var scene := Node3D.new();root.add_child(scene)
 var camera := Camera3D.new();camera.position=Vector3(0,1.+7.*tan(deg_to_rad(25.)),7.);camera.rotation.x=deg_to_rad(-25.);scene.add_child(camera);camera.current=true
 var environment := WorldEnvironment.new();var env := Environment.new();env.background_mode=Environment.BG_COLOR;env.background_color=Color.BLACK;env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color.WHITE;env.ambient_light_energy=1.;environment.environment=env;scene.add_child(environment)
 var card := Sprite3D.new();card.texture=texture199(Color.BLUE);card.pixel_size=1.5;card.offset.y=1.;scene.add_child(card)
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/card_depth199.gdshader");ink.set_shader_parameter("paint",card.texture);ink.set_shader_parameter("foot199",Vector3.ZERO);ink.set_shader_parameter("camera199",camera.global_position);ink.set_shader_parameter("plane_normal199",Vector3.BACK);card.material_override=ink
 var actor := Sprite3D.new();actor.texture=texture199(Color.RED);actor.pixel_size=1.;actor.offset.y=1.;actor.shaded=false;scene.add_child(actor)
 var checks := []
 for z in [-.4,.4]:
  actor.position.z=z
  for i in 8: await process_frame
  await RenderingServer.frame_post_draw
  var image := root.get_texture().get_image();image.save_png("res://docs/captures/world_restart/depth199_"+("behind" if z<0. else "front")+".png")
  for y in [.35,1.6]:
   var p := camera.unproject_position(Vector3(0,y,z))*Vector2(image.get_size())/camera.get_viewport().get_visible_rect().size
   var c := image.get_pixel(clampi(roundi(p.x),0,image.get_width()-1),clampi(roundi(p.y),0,image.get_height()-1))
   checks.append({"z":z,"height":y,"color":str(c),"ok":c.b>c.r*2. if z<0. else c.r>c.b*2.})
 var passed := true
 for entry in checks: passed=passed and entry.ok
 FileAccess.open("res://docs/depth199-validation.json",FileAccess.WRITE).store_string(JSON.stringify(checks," "));print("DEPTH199 ",JSON.stringify(checks));quit(0 if passed else 1)
