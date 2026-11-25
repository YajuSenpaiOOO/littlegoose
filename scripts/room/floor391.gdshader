shader_type spatial;
uniform sampler2D painted_wood : source_color, repeat_enable, filter_linear_mipmap;
uniform float saturation = 0.72;
uniform vec3 tint = vec3(0.88, 0.94, 1.03);
void fragment(){
 vec3 c=texture(painted_wood,UV*vec2(2.0)).rgb;
 float l=dot(c,vec3(0.2126,0.7152,0.0722));
 ALBEDO=mix(vec3(l),c,saturation)*tint;
 ROUGHNESS=1.0;SPECULAR=0.05;
}
