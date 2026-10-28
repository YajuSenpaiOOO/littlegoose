shader_type spatial;
uniform sampler2D stone_paint91 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform float tile_metres91=6.;
varying vec3 rock_position91;
varying vec3 rock_normal91;
void vertex(){
 rock_position91=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;
 rock_normal91=normalize(MODEL_NORMAL_MATRIX*NORMAL);
}
void fragment(){
 vec3 w=pow(abs(rock_normal91),vec3(10.));w/=max(.001,w.x+w.y+w.z);
 vec3 pigment=texture(stone_paint91,rock_position91.zy/tile_metres91).rgb*w.x;
 pigment+=texture(stone_paint91,rock_position91.xz/tile_metres91).rgb*w.y;
 pigment+=texture(stone_paint91,rock_position91.xy/tile_metres91).rgb*w.z;
 ALBEDO=pigment*vec3(.93,.96,1.);
 ROUGHNESS=.96;
 SPECULAR=.12;
}
