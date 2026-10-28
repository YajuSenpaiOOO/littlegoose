extends "res://scripts/art/rock_surfaces103.gd"
func clipped137(code: String,position_name: String) -> String:
 var g: Vector2=world.meadow.landmarks.grove
 var cut := "\n vec3 coast_p137=%s-vec3(%f,0.0,%f);\n if(coast_p137.x < -16.0 && coast_p137.z < 8.0 && coast_p137.y < -6.0){discard;}\n if(coast_p137.x < -4.0 && coast_p137.z < -28.5){discard;}\n"%[position_name,g.x,g.y]
 return code.replace("void fragment(){","void fragment(){"+cut)
func _clean_shader91() -> Shader:
 var source := super._clean_shader91()
 var shader := Shader.new();shader.code=clipped137(source.code,"world");return shader
func _stone_shader91() -> Shader:
 var source := super._stone_shader91()
 var shader := Shader.new();shader.code=clipped137(source.code,"rock_position91");return shader
