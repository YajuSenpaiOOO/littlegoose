shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color, filter_linear_mipmap, repeat_enable;
uniform float cutoff = -1.13;
uniform float reveal = 0.0;
varying vec3 world_pos;
uniform vec3 house_origin = vec3(0.0);
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz - house_origin;}
void fragment(){
 if(world_pos.z > cutoff) discard;
 vec3 cell=floor(world_pos*90.);
 float grain=fract(sin(dot(cell,vec3(12.9898,78.233,37.719)))*43758.5453);
 if(grain>=reveal) discard;
 ALBEDO=texture(paint,UV).rgb*vec3(.84,.70,.54);
 ROUGHNESS=1.0;
 SPECULAR=.08;
}
