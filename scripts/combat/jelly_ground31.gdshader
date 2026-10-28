shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;
void fragment() {
	vec2 p=(floor(UV*16.0)+0.5)/16.0;
	float body=length((p-vec2(0.49,0.52))*vec2(1.0,1.3));
	float side=length((p-vec2(0.72,0.48))*vec2(1.4,1.8));
	float shape=1.0-step(0.41,min(body,side));
	ALBEDO=COLOR.rgb*mix(0.8,1.15,step(0.48,p.y));
	ALPHA=COLOR.a*shape;
}
