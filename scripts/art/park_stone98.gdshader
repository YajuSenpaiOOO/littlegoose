shader_type spatial;
render_mode cull_disabled;
uniform sampler2D pigment97 : source_color,filter_linear_mipmap,repeat_enable;
varying vec3 local98;
varying vec3 normal98;
void vertex(){local98=VERTEX;normal98=NORMAL;}
void fragment(){
 vec3 w=pow(abs(normal98),vec3(6.));w/=max(.001,w.x+w.y+w.z);
 vec3 paint=texture(pigment97,local98.zy*.35).rgb*w.x+texture(pigment97,local98.xz*.35).rgb*w.y+texture(pigment97,local98.xy*.35).rgb*w.z;
 ALBEDO=mix(vec3(.51,.53,.43),paint,.5);ROUGHNESS=1.;SPECULAR=0.;
}
