extends "res://scripts/art/rest_cushion265.gd"
var support266: StaticBody3D
var ink266: ShaderMaterial
func _ready() -> void:
 super._ready()
 # Source pixel (1028.5,325) is the top-surface centre, not the frontmost seam.
 visual.offset=Vector2(visual.texture.get_width()*.5-1028.5,325.-visual.texture.get_height()*.5);visual.position.y=.22
 ink266=ShaderMaterial.new();ink266.shader=preload("res://scripts/art/cushion_depth266.gdshader");ink266.set_shader_parameter("paint",visual.texture);visual.material_override=ink266
 support266=StaticBody3D.new();support266.name="CushionSupport266";support266.collision_layer=2;support266.collision_mask=0
 var collision=CollisionShape3D.new();var shape=BoxShape3D.new();shape.size=Vector3(4.,.22,2.6);collision.shape=shape;collision.position.y=.11;support266.add_child(collision);add_child(support266)
func _process(_delta: float) -> void:
 ink266.set_shader_parameter("centre266",global_position);ink266.set_shader_parameter("camera266",battle.camera.global_position)
