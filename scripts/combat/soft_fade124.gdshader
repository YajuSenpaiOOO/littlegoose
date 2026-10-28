shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, depth_prepass_alpha;
uniform sampler2D art : source_color, filter_nearest_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
uniform vec2 contact_uv = vec2(0.5);
uniform vec2 push = vec2(1.0,0.0);
uniform vec2 body_span = vec2(0.6);
uniform float foot_y = 0.75;
uniform float dent = 0.0;
uniform float head_lag = 0.0;
void fragment() {
	vec2 uv=UV;
	float height=(foot_y-UV.y)/max(body_span.y,0.01);
	float feet=smoothstep(0.0,0.15,height);
	vec2 distance=(UV-contact_uv)/max(body_span,vec2(0.01));
	float local_hit=exp(-dot(distance*vec2(3.0,3.7),distance*vec2(3.0,3.7)));
	uv-=push*dent*body_span*local_hit*feet;
	// Upper tuft lags the torso, with a smooth transition and anchored feet.
	uv.x-=head_lag*body_span.x*smoothstep(0.62,0.94,height)*feet;
	vec4 color=texture(art,uv)*tint;
	ALBEDO=color.rgb;
	ALPHA=color.a;
	if (texture(art,uv).a<0.5) { discard; }
}

