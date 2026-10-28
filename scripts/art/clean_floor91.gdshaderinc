uniform sampler2D soil_field89 : filter_linear,repeat_disable;
uniform vec4 soil_bounds89=vec4(0.,0.,1.,1.);
uniform float floor_strength89=1.;
vec3 forest_floor89(vec3 col,vec3 at,vec3 normal,float path){
 // Clean grass is continuous under trees. The actual roots/contact shadows
 // provide grounding; no brown stipple, leaf confetti or muddy clearing tint.
 return col;
}
