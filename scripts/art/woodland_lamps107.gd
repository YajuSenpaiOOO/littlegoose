extends "res://scripts/art/woodland_lamps106.gd"
func _ready() -> void:
 name="WoodlandBranchLanterns107"
 var g: Vector2=world.meadow.landmarks.grove
 for local in [world.PARK99.DECK+Vector2(-1.3,-.5),world.PARK99.BENCH+Vector2(1.15,-.5)]:
  var at: Vector2=g+local;var root := Node3D.new();root.position=Vector3(at.x,world.floor_height(at),at.y);add_child(root)
  var sprite: Sprite3D=world._sprite(preload("res://assets/woodland107/branch_lantern107.png"),Vector2(512,1518),3.1,1510.)
  sprite.billboard=BaseMaterial3D.BILLBOARD_DISABLED;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON;sprite.visibility_range_end=35.
  var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/lantern107.gdshader");ink.set_shader_parameter("paint",sprite.texture);world.porch49.shade_material(ink);sprite.material_override=ink;root.add_child(sprite)
  var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0;root.add_child(body)
  var shape := CylinderShape3D.new();shape.radius=.13;shape.height=3.0
  var collider := CollisionShape3D.new();collider.shape=shape;collider.position.y=1.5;body.add_child(collider)
  var light := OmniLight3D.new();light.position=Vector3(.47,2.04,.12);light.light_color=Color("ffd18e");light.omni_range=3.3;light.omni_attenuation=1.5;light.shadow_enabled=false;root.add_child(light)
  world.garden._contact(root,at,Vector2(.40,.25),.017,.18)
  lamps106.append({"root":root,"light":light,"ink":ink,"sprite":sprite,"body":body})
 update106()
