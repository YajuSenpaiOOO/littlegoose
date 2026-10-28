extends Node3D
var world: Node3D
var panorama138: Sprite3D
var anchor138 := Vector3.ZERO
var shift138 := Vector2.ZERO
func _ready() -> void:
 name="UnifiedCoastalPanorama138";process_priority=100
 anchor138=Vector3(world.meadow.landmarks.grove.x-27.,10.65,world.meadow.landmarks.grove.y-16.)
 panorama138=Sprite3D.new();panorama138.texture=load("res://assets/paper_hill136/coast.png")
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/coastal_vista137.gdshader")
 material.set_shader_parameter("art",panorama138.texture);material.set_shader_parameter("blur_px",1.35);material.set_shader_parameter("haze",.08)
 panorama138.material_override=material;panorama138.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 panorama138.extra_cull_margin=100.;add_child(panorama138)
 world.camera.far=maxf(world.camera.far,500.);_process(0.)
func _process(_delta: float) -> void:
 var camera: Camera3D=world.camera
 var moved: Vector3=world.hero.global_position-anchor138
 var height := 2.*210.*tan(deg_to_rad(camera.fov)*.5)
 panorama138.pixel_size=height*1.9/float(panorama138.texture.get_height())
 panorama138.global_basis=camera.global_basis
 # The whole seascape has one transform: islands cannot slide over their water.
 shift138=Vector2(-moved.x*.0007,moved.z*.00035)
 panorama138.global_position=camera.global_position-camera.global_basis.z*210.+camera.global_basis.x*(shift138.x*height)+camera.global_basis.y*((shift138.y+.05)*height)
 var day := smoothstep(-.08,.30,sin((world.time55.visual_hour-6.)/12.*PI))
 panorama138.material_override.set_shader_parameter("daylight",Color(.23,.31,.46).lerp(Color.WHITE,day))
