extends "res://scripts/art/rock_surfaces142.gd"
const FOREST182=preload("res://scripts/world/forest_plan182.gd")
func _rock_score91(at: Vector3,normal: Vector3) -> float:
 if FOREST182.affects182(Vector2(at.x,at.z)): return .90-normal.y
 return super._rock_score91(at,normal)
func _clean_shader91() -> Shader:
 var shader := super._clean_shader91()
 var patch := """
 vec2 f182=world.xz-vec2(-48.,0.);
 float local182=(1.-smoothstep(12.,19.,length(f182*vec2(.8,1.))))*(1.-smoothstep(.4,1.0,world.y));
 float lum182=dot(col,vec3(.299,.587,.114));
 vec3 cool182=mix(col,vec3(lum182*.66,lum182*.84,lum182*1.06),.62)*vec3(.70,.76,.85);
 col=mix(col,cool182,local182*.8);
 """
 shader.code=shader.code.replace(" ALBEDO=albedo_view ?",patch+" ALBEDO=albedo_view ?")
 return shader

