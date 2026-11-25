shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

void fragment() {
	vec2 at=UV*2.-1.;
	float softness=max(0.,1.-dot(at,at));
	ALBEDO=vec3(.10,.074,.048);
	ALPHA=softness*softness*COLOR.a;
}
