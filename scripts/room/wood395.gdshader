shader_type spatial;
uniform sampler2D paint:source_color,filter_linear_mipmap,repeat_disable;
uniform vec3 wood_tone=vec3(1.0);
void fragment(){
 vec3 c=texture(paint,UV).rgb;
 float gray=dot(c,vec3(.2126,.7152,.0722));
 ALBEDO=mix(vec3(gray),c,.65)*vec3(.70,.75,.80)*wood_tone;
 ROUGHNESS=1.;SPECULAR=0.;
}
