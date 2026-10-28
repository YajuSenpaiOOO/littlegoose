// Shared source with the existing 2D combat canvas. Alpha is deliberately separate.
global uniform vec4 combat_world_tint159 : source_color;
uniform float environment_grade159=1.;
vec3 grade_world_effect159(vec3 color){
 return color*mix(vec3(1.),combat_world_tint159.rgb,environment_grade159);
}
