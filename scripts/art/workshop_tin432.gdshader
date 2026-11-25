shader_type spatial;

uniform sampler2D paint : source_color, filter_linear_mipmap, repeat_disable;
uniform bool lid = false;

void fragment() {
	vec2 art;
	float painted = 1.;
	if (lid) {
		vec2 face = UV * 2. - 1.;
		art = vec2(892., 322.) + face * vec2(224., 235.);
		float box_x = (art.x - 728.) / 313.;
		float lip = 596. - 165. * sqrt(max(0., 1. - box_x * box_x));
		painted = mix(1. - smoothstep(lip - 14., lip - 2., art.y), 1., smoothstep(.97, 1.02, abs(box_x)));
		painted *= 1. - smoothstep(.91, 1., length(face));
	} else {
		float angle = UV.x * TAU;
		float near_side = abs(cos(angle));
		art = vec2(728. + 294. * sin(angle), 621. + 137. * near_side);
		art.y += UV.y * (126. + 56. * near_side);
	}
	vec3 ink = texture(paint, art / vec2(1536., 1024.)).rgb;
	ALBEDO = mix(vec3(.037, .063, .147), ink, painted);
	METALLIC = .16;
	ROUGHNESS = .61;
}
