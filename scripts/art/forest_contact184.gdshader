shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
void fragment() {
 vec2 p=(UV-.5)*2.;
 float radius=length(p);
 float strength=1.-smoothstep(.20,1.,radius);
 ALBEDO=vec3(.055,.075,.08);
 ALPHA=strength*.68;
}
