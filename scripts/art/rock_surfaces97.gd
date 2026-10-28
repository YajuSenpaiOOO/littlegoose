extends "res://scripts/art/rock_surfaces92.gd"
func _rock_score91(at: Vector3,normal: Vector3) -> float:
	var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
	return minf(.9-normal.y,minf((at.y-2.24)*.75,minf(p.x+46.,minf(25.-p.x,minf(p.y+39.,26.-p.y)))))
func _clean_shader91() -> Shader:
	var shader := super._clean_shader91()
	var code: String=shader.code
	code=code.insert(code.find("\n")+1,"#include \"res://scripts/art/park_path97.gdshaderinc\"\n")
	var g: Vector2=world.meadow.landmarks.grove
	var patch := """
 vec2 p97=world.xz-vec2(%f,%f);
 if(abs(p97.x+10.625)<1.35 && p97.y> -2.75 && p97.y<1.9) discard;
 float edge97=park_path97(p97);
 float ragged97=(soft_noise(world.xz*5.7)-.5)*.22+(soft_noise(world.xz*1.9)-.5)*.20;
 float wear97=(1.-smoothstep(.72+ragged97,1.25+ragged97,edge97))*smoothstep(.88,.98,normal76.y);
 float grit97=(soft_noise(world.xz*17.)-.5)*.055+(soft_noise(world.xz*2.8)-.5)*.04;
 vec3 gravel97=vec3(.48,.37,.245)+vec3(grit97);
 col=mix(col,gravel97,wear97*.88);
"""%[g.x,g.y]
	shader.code=code.replace(" ALBEDO=albedo_view ?",patch+" ALBEDO=albedo_view ?")
	return shader
