extends "res://scripts/art/forest_mood191.gd"
func _ready() -> void:
 super._ready()
 var saved: Dictionary={}
 for uniform in focus.shader.get_shader_uniform_list():
  var value=focus.get_shader_parameter(uniform.name)
  if value!=null: saved[uniform.name]=value
 var shader := Shader.new()
 shader.code=focus.shader.code.replace(".xyz)*.94)",".xyz)*.65)").replace("light_relief191(hit186)*.88","light_relief191(hit186)*.55")
 focus.shader=shader
 for id in saved: focus.set_shader_parameter(id,saved[id])
