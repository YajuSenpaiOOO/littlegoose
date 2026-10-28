extends Node
var world: Node3D
var shaders := {}
func _ready() -> void: process_priority=120
func enroll(actor: Node) -> void:
 if not is_instance_valid(actor): return
 var ink: Variant=actor.get("soft_ink")
 if not ink is ShaderMaterial or ink.shader==null: return
 var source: Shader=ink.shader
 if source.get_meta("enemy_grade193",false): return
 if not source.code.contains("ALBEDO=color.rgb;"): return
 if not shaders.has(source):
  var shader := Shader.new()
  var receiver := "#include \"res://scripts/combat/world_effect_grade159.gdshaderinc\"\nvec3 grade_enemy193(vec3 color){\n vec3 shade=mix(vec3(1.),combat_world_tint159.rgb,environment_grade159);\n shade.b=min(shade.b,max(shade.r,shade.g)*1.25);\n return color*shade;\n}\n"
  shader.code=source.code.replace("void fragment()",receiver+"void fragment()").replace("ALBEDO=color.rgb;","ALBEDO=grade_enemy193(color.rgb);")
  shader.set_meta("enemy_grade193",true);shaders[source]=shader
 var saved := {}
 for uniform in source.get_shader_uniform_list():
  var value=ink.get_shader_parameter(uniform.name)
  if value!=null: saved[uniform.name]=value
 ink.shader=shaders[source]
 for key in saved: ink.set_shader_parameter(key,saved[key])
func _process(_delta: float) -> void:
 if not is_instance_valid(world.combat_tint111): return
 RenderingServer.global_shader_parameter_set("combat_world_tint159",world.combat_tint111.color)
 for actor in world.enemies+world.roamers122: enroll(actor)
