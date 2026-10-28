extends Node3D
var world: Node3D
var lamps106: Array[Dictionary]=[]
var enabled106 := true
var tick106 := 0.
var active106 := 0
func _ready() -> void:
 name="TwoQuietParkLamps106"
 var g: Vector2=world.meadow.landmarks.grove
 for local in [world.PARK99.DECK+Vector2(-1.3,-.5),world.PARK99.BENCH+Vector2(1.15,-.5)]:
  var at: Vector2=g+local;var root := Node3D.new();root.position=Vector3(at.x,world.floor_height(at),at.y);add_child(root)
  var sprite: Sprite3D=world._sprite(preload("res://assets/woodland46/lantern.png"),Vector2(435,1458),1.8,1376.)
  sprite.billboard=BaseMaterial3D.BILLBOARD_DISABLED;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;sprite.visibility_range_end=35.
  var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/lantern106.gdshader");ink.set_shader_parameter("paint",sprite.texture);world.porch49.shade_material(ink);sprite.material_override=ink;root.add_child(sprite)
  var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0;root.add_child(body)
  var shape := CylinderShape3D.new();shape.radius=.10;shape.height=1.8
  var collider := CollisionShape3D.new();collider.shape=shape;collider.position.y=.9;body.add_child(collider)
  var light := OmniLight3D.new();light.position=Vector3(.39,1.0,.12);light.light_color=Color("ffd18e");light.omni_range=3.3;light.omni_attenuation=1.5;light.shadow_enabled=false;root.add_child(light)
  world.garden._contact(root,at,Vector2(.28,.20),.017,.18)
  lamps106.append({"root":root,"light":light,"ink":ink})
 update106()
func update106() -> void:
 var hour: float=world.time55.visual_hour
 var night := maxf(smoothstep(16.,19.,hour),1.-smoothstep(5.,8.,hour));active106=0
 for lamp in lamps106:
  var near: bool=enabled106 and world.hero.position.distance_squared_to(lamp.root.global_position)<30.*30. and world.effect_scope95.near_view95(lamp.root.global_position,5.)
  lamp.light.visible=near;lamp.light.light_energy=lerpf(.05,1.6,night) if near else 0.
  lamp.ink.set_shader_parameter("glow106",lerpf(.18,1.7,night) if enabled106 else 0.)
  if near: active106+=1
func _process(delta: float) -> void:
 tick106-=delta
 if tick106>0.: return
 tick106=.2;update106()
