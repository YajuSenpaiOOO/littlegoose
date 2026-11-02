shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform float opacity = 0.58;
void fragment() {
 vec2 p = (UV-.5)*2.;
 float strength = max(0.,1.-dot(p,p));
 ALBEDO = vec3(.12,.16,.09);
 ALPHA = strength*strength*opacity;
}
