shader_type spatial;
uniform sampler2D pigment97 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
varying vec3 place97;
varying vec3 normal97;
void vertex(){place97=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;normal97=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec3 w=pow(abs(normal97),vec3(8.));w/=max(dot(w,vec3(1.)),.001);
 vec3 stone=texture(pigment97,place97.zy/3.2).rgb*w.x+texture(pigment97,place97.xz/3.2).rgb*w.y+texture(pigment97,place97.xy/3.2).rgb*w.z;
 ALBEDO=stone*vec3(.78,.80,.73);ROUGHNESS=1.;SPECULAR=.02;
}
