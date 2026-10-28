extends "res://scripts/art/hill_plants142.gd"
var shrub_bodies143: Array[StaticBody3D]=[]
func _ready() -> void:
 super._ready()
 for batch in batches107:
  batch.material_override=batch.material_override.duplicate()
  var mat: ShaderMaterial=batch.material_override
  var shader := Shader.new();var code: String=mat.shader.code
  if code.contains("float wind=sin"):
   code=code.replace("vec2(wind+echo*.035,wind*.35)","normalize(vec2(.95,-.31))*(.038+wind*1.6)+vec2(echo*.035)")
  else:
   code=code.replace("vec3 wind=vec3(sin(clock*1.45+root.x*1.8+root.z)*.018,0.,cos(clock*1.1+root.z)*.007);","float gust=.045+.022*sin(clock*1.45+root.x*.35+root.z*.2); vec3 wind=vec3(.95,0.,-.31)*gust;")
   for i in batch.multimesh.instance_count:
    var pose := batch.multimesh.get_instance_transform(i)
    var body := StaticBody3D.new();body.collision_layer=2;body.collision_mask=0
    var shape := CylinderShape3D.new();shape.radius=.19*pose.basis.y.length();shape.height=.48
    var collider := CollisionShape3D.new();collider.shape=shape;body.add_child(collider)
    add_child(body);body.position=pose.origin+Vector3.UP*.24;shrub_bodies143.append(body)
  shader.code=code;mat.shader=shader
func _process(_delta: float) -> void:
 if not is_instance_valid(world.hero): return
 for batch in batches107:
  batch.material_override.set_shader_parameter("clock",world.clock)
  batch.material_override.set_shader_parameter("walker",world.hero.global_position)
  batch.material_override.set_shader_parameter("trail",world.trail)
