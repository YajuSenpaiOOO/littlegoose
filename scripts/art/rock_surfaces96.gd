extends "res://scripts/art/rock_surfaces92.gd"
func _clean_shader91() -> Shader:
	var shader := super._clean_shader91()
	var code: String=shader.code
	code=code.insert(code.find("\n")+1,"#include \"res://scripts/art/rest_trail96.gdshaderinc\"\n")
	var g: Vector2=world.meadow.landmarks.grove
	var patch := """
 float trail96=rest_trail96(world.xz-vec2(%f,%f))*smoothstep(.92,.98,normal76.y);
 float gray96=dot(col,vec3(.2126,.7152,.0722));
 vec3 flat96=mix(col,vec3(gray96)*vec3(1.05,1.11,.86),.3)*1.06;
 col=mix(col,flat96,trail96*.7);
"""%[g.x,g.y]
	shader.code=code.replace(" ALBEDO=albedo_view ?",patch+" ALBEDO=albedo_view ?")
	return shader
