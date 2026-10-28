shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform float strength=.20;
void fragment(){
 float soft=max(0.,1.-dot(UV*2.-1.,UV*2.-1.));
 ALBEDO=vec3(.12,.15,.075);
 ALPHA=soft*soft*strength;
}
