shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color, filter_linear_mipmap, repeat_enable;
varying vec3 stone_point;
void vertex(){stone_point=VERTEX;}
void fragment(){
 float row = step(3.47,stone_point.z)+step(3.94,stone_point.z);
 float column = (stone_point.x+1.17)/.47 + .28*mod(row,2.0);
 float joint = step(.46,abs(fract(column)-.5));
 float nose = 1.0-smoothstep(.003,.022,min(abs(stone_point.z-3.47),abs(stone_point.z-3.94)));
 vec3 stone = texture(paint,vec2(column,stone_point.z*1.9)).rgb;
 ALBEDO = stone*vec3(.74,.70,.61)*(1.0-.24*joint+.11*nose);
 ROUGHNESS=1.;
}
