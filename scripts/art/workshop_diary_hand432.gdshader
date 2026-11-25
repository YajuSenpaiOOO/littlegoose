shader_type canvas_item;

uniform float tap;
uniform float reach;
uniform vec2 fingertip = vec2(.65,.46);
uniform vec2 palm_anchor = vec2(.741,.567);
uniform bool shadow_pass = false;
varying vec4 ink;

void vertex() {
	ink = COLOR;
}

void fragment() {
	vec2 point = UV;
	vec2 finger = (UV - fingertip) / vec2(.074,.087);
	float flex = 1. - smoothstep(.18, 1., length(finger));
	vec2 hand = (UV - palm_anchor) / vec2(.15,.22);
	float wrist = 1. - smoothstep(.22,1.,length(hand));
	point -= vec2(.0015,-.004) * flex * tap + vec2(-.018,.008) * wrist * reach;
	vec4 paint = texture(TEXTURE,point);
	if (shadow_pass) {
		vec2 softness = vec2(.0035,.0035);
		float outline = paint.a*.30;
		outline += texture(TEXTURE,point+softness).a*.175;
		outline += texture(TEXTURE,point-softness).a*.175;
		outline += texture(TEXTURE,point+vec2(softness.x,-softness.y)).a*.175;
		outline += texture(TEXTURE,point+vec2(-softness.x,softness.y)).a*.175;
		float contact = 1. - smoothstep(.42,1.,length(hand));
		COLOR = vec4(ink.rgb,outline*ink.a*contact);
	} else {
		COLOR = paint*ink;
	}
}
