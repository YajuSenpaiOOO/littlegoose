shader_type spatial;
uniform sampler2D paper : source_color, filter_linear_mipmap, repeat_disable;
uniform bool fluted = false;
varying vec2 local_xz;

void vertex() { local_xz = VERTEX.xz; }

void fragment() {
	vec2 paint_uv = vec2(.28,.35) + local_xz * vec2(.23,.30);
	vec3 pulp = texture(paper,paint_uv).rgb;
	float shade;
	if (fluted) {
		float fold = cos(UV.x * TAU * 24.);
		shade = mix(.99,.68,UV.y) * (.91 + fold*.09);
	} else {
		float rim = smoothstep(.18,.286,length(local_xz));
		shade = 1. - rim*.30;
	}
	ALBEDO = pulp * vec3(.89,.79,.66) * shade;
	ROUGHNESS = 1.;
	SPECULAR = 0.;
}
