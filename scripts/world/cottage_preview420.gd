extends Node3D

const COTTAGE := preload("res://scripts/room/cottage420.gd")
var camera: Camera3D
var sun: DirectionalLight3D
var world_light: Environment
var label: Label
var view:=0
var night:=false

func _ready() -> void:
 DisplayServer.window_set_title("小白鹅 · 420 · A稿新屋外观")
 var house:=COTTAGE.new()
 house.name="Cottage420"
 add_child(house)
 world_light=Environment.new()
 world_light.background_mode=Environment.BG_COLOR
 world_light.background_color=Color("ded2b6")
 world_light.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 var lighting:=WorldEnvironment.new()
 lighting.environment=world_light
 add_child(lighting)
 sun=DirectionalLight3D.new()
 sun.rotation_degrees=Vector3(-52,-32,0)
 sun.shadow_enabled=true
 sun.directional_shadow_max_distance=40.
 sun.light_angular_distance=4.
 sun.shadow_bias=.075
 sun.shadow_normal_bias=.6
 add_child(sun)
 var ground:=PlaneMesh.new()
 ground.size=Vector2(500,500)
 var lawn:=ShaderMaterial.new()
 var lawn_shader:=Shader.new()
 lawn_shader.code="""
shader_type spatial;
varying vec3 ground;
void vertex() { ground = VERTEX; }
void fragment() {
 vec2 uv = ground.xz;
 float grain = fract(sin(dot(floor(uv * 33.0), vec2(127.1, 311.7))) * 43758.5453);
 float patch = sin(uv.x * 1.8 + cos(uv.y * 1.1)) * sin(uv.y * 1.55);
 ALBEDO = mix(vec3(.25,.30,.16), vec3(.47,.49,.27), .36 + .19*patch + .12*grain);
 ROUGHNESS = 1.0;
}
"""
 lawn.shader=lawn_shader
 house.mesh_at(self,ground,Vector3(0,-.01,0),lawn)
 for i in 9:
  var z:=4.40+i*.31
  var x:=sin(i*1.6)*.18+(.37 if i%2==0 else -.37)
  var slab:=CylinderMesh.new()
  slab.top_radius=.28
  slab.bottom_radius=.30
  slab.height=.065
  slab.radial_segments=7
  var tread:=house.mesh_at(self,slab,Vector3(x,.026,z),house.stone)
  tread.scale.z=.70
  tread.rotation.y=i*.7
 camera=Camera3D.new()
 add_child(camera)
 camera.make_current()
 var hud:=CanvasLayer.new()
 add_child(hud)
 label=Label.new()
 label.position=Vector2(20,16)
 label.add_theme_color_override("font_color",Color("fff0ce"))
 label.add_theme_color_override("font_outline_color",Color("333323"))
 label.add_theme_constant_override("outline_size",5)
 hud.add_child(label)
 apply_view()
 apply_light()
 assert(COTTAGE.LEFT.size.x-.24>2.55 and COTTAGE.LEFT.size.y-.24>3.0+.85)
 assert(COTTAGE.HALL.size.x-.24>2.5 and COTTAGE.RIGHT.size.x-.24>1.5+1.0)
 if "--capture420" in OS.get_cmdline_user_args():
  capture_views()

func apply_view() -> void:
 var pitch: float=[-25.,-5.,-24.,-24.][view]
 var yaw: float=[0.,0.,34.,-145.][view]
 var target:=Vector3(0,2.85,.25)
 var basis:=Basis.from_euler(Vector3(deg_to_rad(pitch),deg_to_rad(yaw),0))
 camera.projection=Camera3D.PROJECTION_ORTHOGONAL if view==1 else Camera3D.PROJECTION_PERSPECTIVE
 camera.size=10.5
 camera.fov=42.
 camera.transform=Transform3D(basis,target+basis.z*(45. if view==1 else 19.5))
 label.text="420 · "+["游戏镜头 25°","近正立面","侧前方","后侧"][view]+"   1 / 2 / 3 / 4 切换镜头   F2 昼夜"

func apply_light() -> void:
 sun.light_energy=.14 if night else .87
 sun.light_color=Color("aebfee") if night else Color("ffedcf")
 world_light.ambient_light_color=Color("869ac4") if night else Color("e6e6dd")
 world_light.ambient_light_energy=.41 if night else .66

func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_4:
   view=event.physical_keycode-KEY_1
   apply_view()
  elif event.physical_keycode==KEY_F2:
   night=not night
   apply_light()

func capture_views() -> void:
 for i in 5:
  view=mini(i,3) if i<4 else 0
  night=i==4
  apply_view()
  apply_light()
  for frame in 4:
   await get_tree().process_frame
  await RenderingServer.frame_post_draw
  var shot:=get_viewport().get_texture().get_image()
  assert(shot.save_png("res://docs/cottage420-%s.png" % ["game","front","side","rear","night"][i])==OK)
 print("COTTAGE420_DONE")
 get_tree().quit()
