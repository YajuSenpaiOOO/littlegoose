extends Node3D
var world: Node3D
var panorama139: Sprite3D
var opacity139 := 0.
func _ready() -> void:
 process_priority=100;name="HillPanorama139"
 panorama139=Sprite3D.new();panorama139.texture=load("res://assets/paper_hill136/coast.png")
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/coastal_vista139.gdshader");ink.set_shader_parameter("art",panorama139.texture)
 panorama139.material_override=ink;panorama139.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;panorama139.extra_cull_margin=100.
 add_child(panorama139);world.camera.far=maxf(world.camera.far,500.);_process(0.)
func _process(_delta: float) -> void:
 var camera: Camera3D=world.camera
 var p: Vector2=Vector2(world.hero.position.x,world.hero.position.z)-Vector2(world.meadow.landmarks.grove)
 # Broad continuous falloff: keep the hill and its approaches covered, while
 # retaining the original station/home background instead of blue through cuts.
 opacity139=(1.-smoothstep(-12.,-2.,p.x))*smoothstep(-52.,-38.,p.y)*(1.-smoothstep(8.,22.,p.y))
 var height := 2.*210.*tan(deg_to_rad(camera.fov)*.5)
 panorama139.pixel_size=height*1.9/float(panorama139.texture.get_height());panorama139.global_basis=camera.global_basis
 var shift := Vector2(-(p.x+23.)*.0007,(p.y+16.)*.00035)
 panorama139.global_position=camera.global_position-camera.global_basis.z*210.+camera.global_basis.x*(shift.x*height)+camera.global_basis.y*((shift.y+.05)*height)
 var day := smoothstep(-.08,.30,sin((world.time55.visual_hour-6.)/12.*PI))
 var color := Color(.23,.31,.46).lerp(Color.WHITE,day);color.a=opacity139
 panorama139.material_override.set_shader_parameter("tint",color)
