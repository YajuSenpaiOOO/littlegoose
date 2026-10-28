extends "res://scripts/art/rock_surfaces103.gd"
func _clean_shader91() -> Shader:
 var shader := super._clean_shader91()
 shader.code=shader.code.insert(shader.code.find("\n")+1,"uniform sampler2D lookout_stone141 : source_color, filter_linear_mipmap_anisotropic, repeat_enable;\n")
 var g: Vector2=world.meadow.landmarks.grove
 var detail := """
 // A continuous grass -> moss -> worn rock transition at the future seat.
 vec2 view_p141=world.xz-vec2(%f,%f);
 float view_r141=length((view_p141-vec2(-25.7,-28.3))/vec2(2.9,2.4));
 float worn141=1.-smoothstep(.40,1.12,view_r141+.065*sin(world.x*5.)*sin(world.z*4.));
 vec2 stone_uv141=world.xz/5.3;
 vec3 bare141=texture(lookout_stone141,stone_uv141).rgb*vec3(.91,.97,.88);
 float moss141=smoothstep(.35,.84,view_r141)*(1.-smoothstep(.85,1.2,view_r141));
 bare141=mix(bare141,vec3(.37,.46,.27),moss141*.65);
 col=mix(col,bare141,worn141);
 """%[g.x,g.y]
 shader.code=shader.code.replace(" ALBEDO=albedo_view ?",detail+" ALBEDO=albedo_view ?")
 return shader
func _ready() -> void:
 super._ready()
 for material in after_materials91:
  material.set_shader_parameter("lookout_stone141",preload("res://assets/stone92/painted_bedrock92.png"))
