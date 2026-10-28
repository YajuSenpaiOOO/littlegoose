shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform float opacity = .46;
void fragment(){
 vec2 p=(UV-.5)*2.;
 float coverage=1.-smoothstep(.38,1.,dot(p,p));
 ALBEDO=vec3(.09,.13,.085);
 ALPHA=coverage*opacity;
}
