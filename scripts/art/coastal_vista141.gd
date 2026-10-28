extends Node3D
## One distant panorama, fixed in WORLD space. Camera translation and optics
## produce its screen movement; no per-frame billboard reposition or resizing.
var world: Node3D
var panorama141: MeshInstance3D
var opacity141 := 0.
var anchor141 := Vector3.ZERO
var world_size141 := 0.
func _ready() -> void:
 name="WorldAnchoredDistantCoast141";process_priority=100
 var camera: Camera3D=world.camera
 var g: Vector2=world.meadow.landmarks.grove
 var offset: Vector3=camera.global_position-world.hero.global_position
 var reference := Vector3(g.x-24.,11.7,g.y-18.)+offset
 var depth := 360.
 var height := 2.*depth*tan(deg_to_rad(camera.fov)*.5)
 var size := world.get_viewport().get_visible_rect().size
 var aspect := size.x/maxf(1.,size.y)
 var overscan := maxf(1.55,aspect/1.5*1.35)
 var texture: Texture2D=load("res://assets/paper_hill136/coast.png")
 panorama141=MeshInstance3D.new();panorama141.name="CoastAt360Metres141"
 var quad := QuadMesh.new();quad.size=Vector2(height*overscan*1.5,height*overscan*1.8);panorama141.mesh=quad
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/coastal_vista141.gdshader");ink.set_shader_parameter("art",texture)
 panorama141.material_override=ink;panorama141.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;panorama141.extra_cull_margin=200.
 add_child(panorama141);panorama141.global_basis=camera.global_basis
 anchor141=reference-camera.global_basis.z*depth+camera.global_basis.y*((.28-.30*overscan)*height)
 panorama141.global_position=anchor141;world_size141=height*overscan
 camera.far=maxf(camera.far,800.);_process(0.)
func _process(_delta: float) -> void:
 var p: Vector2=Vector2(world.hero.position.x,world.hero.position.z)-Vector2(world.meadow.landmarks.grove)
 opacity141=(1.-smoothstep(-12.,-2.,p.x))*smoothstep(-55.,-39.,p.y)*(1.-smoothstep(8.,22.,p.y))
 var day := smoothstep(-.08,.30,sin((world.time55.visual_hour-6.)/12.*PI))
 var color := Color(.23,.31,.46).lerp(Color.WHITE,day);color.a=opacity141
 panorama141.material_override.set_shader_parameter("tint",color)
