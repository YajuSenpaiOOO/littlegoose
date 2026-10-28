shader_type spatial;
render_mode unshaded,cull_disabled;
uniform float night79=0.;
varying float height79;
void vertex(){height79=VERTEX.y;}
void fragment(){
 vec3 day79=mix(vec3(.46,.55,.51),vec3(.39,.50,.47),smoothstep(0.,12.,height79));
 ALBEDO=mix(day79,vec3(.12,.19,.29),night79);
 ROUGHNESS=1.;
}
