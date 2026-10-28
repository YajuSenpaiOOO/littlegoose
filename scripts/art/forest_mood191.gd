extends "res://scripts/art/forest_mood190.gd"
func _ready() -> void:
 super._ready()
 var code := focus.shader.code
 var saved: Dictionary={}
 for uniform in focus.shader.get_shader_uniform_list():
  var value=focus.get_shader_parameter(uniform.name)
  if value!=null: saved[uniform.name]=value
 code=code.replace("void vertex()",FileAccess.get_file_as_string("res://scripts/art/light_relief191.gdshaderinc")+"\nvoid vertex()")
 # Keep the native illuminated source; do not manufacture illumination in post.
 code=code.replace("emitter_mask190(SCREEN_UV,distance)*.94", "max(emitter_mask190(SCREEN_UV,distance)*.94,light_relief191((INV_VIEW_MATRIX*vec4(point.xyz/point.w,1.)).xyz)*.94)")
 code=code.replace("ALBEDO=mix(original186,cool186,region186);", "ALBEDO=mix(original186,cool186,region186*(1.-light_relief191(hit186)*.88));")
 var shader := Shader.new();shader.code=code;focus.shader=shader
 for id in saved: focus.set_shader_parameter(id,saved[id])
