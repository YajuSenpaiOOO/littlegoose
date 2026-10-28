shader_type spatial;
uniform sampler2D wood59 : source_color,filter_linear_mipmap,repeat_enable;
uniform vec3 tint59 : source_color=vec3(1.);
uniform float seed59=0.;
void fragment(){
 vec3 paint=texture(wood59,UV*vec2(1.6,.5)+vec2(seed59*.17,seed59*.07)).rgb;
 ALBEDO=paint*tint59;
 ROUGHNESS=.95; SPECULAR=.08;
}
