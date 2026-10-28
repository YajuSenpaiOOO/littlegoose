shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform sampler2D silhouette : filter_nearest_mipmap, repeat_disable;
uniform vec4 region = vec4(0.,0.,1.,1.);
uniform bool flipped = false;
uniform float opacity = .28;
void fragment() {
	vec2 uv = vec2(flipped ? 1.-UV.x : UV.x, UV.y);
	float a = texture(silhouette,region.xy+uv*region.zw).a;
	ALBEDO = vec3(.10,.14,.10);
	ALPHA = a*opacity;
}
