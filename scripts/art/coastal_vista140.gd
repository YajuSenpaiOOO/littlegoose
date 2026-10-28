extends Node3D
var world: Node3D
var panorama140: Sprite3D
var opacity140 := 0.
var overscan140 := 1.
var shift140 := Vector2.ZERO
var horizon_screen140 := .2
func _ready() -> void:
 process_priority=100;name="WholeCoast140_WithSkyAndHorizon"
 panorama140=Sprite3D.new();panorama140.texture=load("res://assets/paper_hill136/coast.png")
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/coastal_vista140.gdshader");ink.set_shader_parameter("art",panorama140.texture)
 panorama140.material_override=ink;panorama140.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;panorama140.extra_cull_margin=100.
 add_child(panorama140);world.camera.far=maxf(world.camera.far,500.);_process(0.)
func _process(_delta: float) -> void:
 var camera: Camera3D=world.camera
 var p: Vector2=Vector2(world.hero.position.x,world.hero.position.z)-Vector2(world.meadow.landmarks.grove)
 opacity140=(1.-smoothstep(-12.,-2.,p.x))*smoothstep(-55.,-39.,p.y)*(1.-smoothstep(8.,22.,p.y))
 var viewport_size := world.get_viewport().get_visible_rect().size
 var aspect := viewport_size.x/maxf(1.,viewport_size.y)
 var texture_aspect := float(panorama140.texture.get_width())/float(panorama140.texture.get_height())
 overscan140=maxf(1.14,aspect/texture_aspect*1.10)
 var height := 2.*210.*tan(deg_to_rad(camera.fov)*.5)
 panorama140.pixel_size=height*overscan140/float(panorama140.texture.get_height());panorama140.global_basis=camera.global_basis
 # Viewport-filling card stays distant and stable. All islands move WITH water.
 shift140=Vector2(-(p.x+24.)*.00045,(p.y+18.)*.00022)
 # Preserve the horizon around the top fifth, even on a wide viewport.
 var offset_y := .28-.30*overscan140
 horizon_screen140=.5+(.20-.5)*overscan140-offset_y-shift140.y
 panorama140.global_position=camera.global_position-camera.global_basis.z*210.+camera.global_basis.x*(shift140.x*height)+camera.global_basis.y*((shift140.y+offset_y)*height)
 var day := smoothstep(-.08,.30,sin((world.time55.visual_hour-6.)/12.*PI))
 var color := Color(.23,.31,.46).lerp(Color.WHITE,day);color.a=opacity140
 panorama140.material_override.set_shader_parameter("tint",color)
