extends "res://scripts/art/rock_surfaces142.gd"
const FOREST180=preload("res://scripts/world/forest_plan180.gd")
func _rock_score91(at: Vector3,normal: Vector3) -> float:
 if FOREST180.affects180(Vector2(at.x,at.z)): return .90-normal.y
 return super._rock_score91(at,normal)
func _clean_shader91() -> Shader:
 var shader := super._clean_shader91()
 var patch := """
 vec2 f180=world.xz-vec2(-48.,0.);
 float local180=(1.-smoothstep(12.,19.,length(f180*vec2(.8,1.))))*(1.-smoothstep(.4,1.0,world.y));
 float lum180=dot(col,vec3(.299,.587,.114));
 vec3 cool180=mix(col,vec3(lum180*.66,lum180*.84,lum180*1.06),.62)*vec3(.70,.76,.85);
 col=mix(col,cool180,local180*.8);
 """
 shader.code=shader.code.replace(" ALBEDO=albedo_view ?",patch+" ALBEDO=albedo_view ?")
 return shader
