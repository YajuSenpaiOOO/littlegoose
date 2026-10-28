extends Node3D
var world: Node3D
var layers137: Array[Sprite3D]=[]
var anchor137 := Vector3.ZERO
var shifts137: Array[Vector2]=[]
func _ready() -> void:
 name="LayeredDistantCoast137";process_priority=100
 anchor137=Vector3(world.meadow.landmarks.grove.x-27.,10.65,world.meadow.landmarks.grove.y-16.)
 for spec in [["far",2.1,.16],["mid",.9,.08]]:
  var sprite := Sprite3D.new();sprite.texture=load("res://assets/paper_hill137/%s.png"%spec[0])
  var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/coastal_vista137.gdshader")
  material.set_shader_parameter("art",sprite.texture);material.set_shader_parameter("blur_px",spec[1]);material.set_shader_parameter("haze",spec[2])
  sprite.material_override=material;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  sprite.extra_cull_margin=100.;add_child(sprite);layers137.append(sprite)
 world.camera.far=maxf(world.camera.far,500.)
 _process(0.)
func _process(_delta: float) -> void:
 var camera: Camera3D=world.camera
 var moved: Vector3=world.hero.global_position-anchor137
 var day := smoothstep(-.08,.30,sin((world.time55.visual_hour-6.)/12.*PI))
 var tint := Color(.23,.31,.46).lerp(Color.WHITE,day)
 shifts137.clear()
 for i in layers137.size():
  var sprite: Sprite3D=layers137[i]
  var depth := 210. if i==0 else 155.
  var view_height := 2.*depth*tan(deg_to_rad(camera.fov)*.5)
  var overscan := 1.9 if i==0 else 1.9
  sprite.pixel_size=view_height*overscan/float(sprite.texture.get_height())
  sprite.global_basis=camera.global_basis
  var rate := .0013 if i==0 else .0045
  var shift := Vector2(-moved.x*rate,moved.z*rate*.55)
  shifts137.append(shift)
  sprite.global_position=camera.global_position-camera.global_basis.z*depth+camera.global_basis.x*(shift.x*view_height)+camera.global_basis.y*((shift.y+.05)*view_height)
  sprite.material_override.set_shader_parameter("daylight",tint)
