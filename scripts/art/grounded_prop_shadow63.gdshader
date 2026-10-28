shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform sampler2D silhouette : filter_linear_mipmap, repeat_disable;
uniform float opacity=.27;
void fragment(){
 float alpha=smoothstep(.40,.60,texture(silhouette,UV).a);
 ALBEDO=vec3(.10,.14,.10);
 ALPHA=alpha*opacity;
}
