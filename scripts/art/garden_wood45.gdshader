shader_type spatial;
uniform sampler2D paint : source_color, filter_linear_mipmap, repeat_enable;
void fragment(){
 vec3 wood=texture(paint,UV).rgb;
 ALBEDO=wood*.88;
 ROUGHNESS=1.; SPECULAR=0.;
}
