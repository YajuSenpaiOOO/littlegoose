shader_type spatial;
uniform sampler2D wallpaper:source_color,repeat_enable,filter_linear_mipmap;
varying vec3 world_p;
varying vec3 world_n;
void vertex(){world_p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;world_n=normalize(mat3(MODEL_MATRIX)*NORMAL);}
void fragment(){
 vec2 p=abs(world_n.x)>.5?vec2(world_p.z,world_p.y):vec2(world_p.x,world_p.y);
 ALBEDO=texture(wallpaper,p/2.2).rgb;ROUGHNESS=1.0;SPECULAR=.03;
}
