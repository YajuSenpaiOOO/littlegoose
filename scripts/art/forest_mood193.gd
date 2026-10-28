extends "res://scripts/art/forest_mood192.gd"
func _ready() -> void:
 super._ready()
 var saved := {}
 for uniform in focus.shader.get_shader_uniform_list():
  var value=focus.get_shader_parameter(uniform.name)
  if value!=null: saved[uniform.name]=value
 var shader := Shader.new()
 var code: String=focus.shader.code.replace(".xyz)*.65)",".xyz)*.80)").replace("light_relief191(hit186)*.55","light_relief191(hit186)*.72")
 # Correct the night grade's blue cast inside registered light volumes only.
 # Preserve luminance: native lamps and their shadows still determine brightness.
 var end := code.rfind("}")
 var warmth := "\n vec3 hit193=(INV_VIEW_MATRIX*vec4(point.xyz/point.w,1.)).xyz;\n float pool193=light_relief191(hit193)*night_mix56;\n vec3 warm193=ALBEDO*vec3(1.24,1.,.76);\n warm193*=dot(ALBEDO,vec3(.2126,.7152,.0722))/max(dot(warm193,vec3(.2126,.7152,.0722)),.00001);\n ALBEDO=mix(ALBEDO,warm193,pool193);\n"
 shader.code=code.substr(0,end)+warmth+"\n}"
 focus.shader=shader
 for key in saved: focus.set_shader_parameter(key,saved[key])
