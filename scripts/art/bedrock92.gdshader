shader_type spatial;
uniform sampler2D stone_paint91 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D grass_paint92 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform float tile_metres91=6.;
varying vec3 rock_position91;
varying vec3 rock_normal91;
varying float edge_distance92;
void vertex(){
 rock_position91=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;
 rock_normal91=normalize(MODEL_NORMAL_MATRIX*NORMAL);
 edge_distance92=COLOR.r;
}
void fragment(){
 vec3 w=pow(abs(rock_normal91),vec3(10.));w/=max(.001,w.x+w.y+w.z);
 vec3 pigment=texture(stone_paint91,rock_position91.zy/tile_metres91).rgb*w.x;
 pigment+=texture(stone_paint91,rock_position91.xz/tile_metres91).rgb*w.y;
 pigment+=texture(stone_paint91,rock_position91.xy/tile_metres91).rgb*w.z;
 vec2 t=rock_position91.xz/6.;
 vec2 mirrored=1.-abs(fract(t*.5)*2.-1.);
 vec3 moss=texture(grass_paint92,mirrored).rgb*vec3(.77,.83,.73);
 float uneven=.5+.5*sin(rock_position91.x*4.1+sin(rock_position91.z*5.3));
 float edge=1.-smoothstep(.015,.16+uneven*.10,edge_distance92);
 ALBEDO=mix(pigment*vec3(.94,.96,.97),moss,edge*.77);
 ROUGHNESS=1.;SPECULAR=.06;
}
