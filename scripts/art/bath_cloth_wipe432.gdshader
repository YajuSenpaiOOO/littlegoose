shader_type canvas_item;

uniform float coverage = 0.0;

void fragment() {
	float edge = 1.035 - coverage * 1.07;
	edge += sin(UV.y * 5.0 + 0.30) * 0.021 * sin(coverage * PI);
	vec2 cloth_uv = vec2(UV.x - edge, UV.y);
	cloth_uv.x += sin(UV.y * 4.0) * 0.012;
	vec2 checks = smoothstep(vec2(0.46), vec2(0.54), fract(cloth_uv * vec2(14.0, 9.0)));
	vec3 fabric = mix(vec3(0.66, 0.63, 0.52), vec3(0.19, 0.29, 0.39), 0.38 * (checks.x + checks.y));
	float pleats = 0.89 + cos(cloth_uv.x * 54.0) * 0.12 + sin(cloth_uv.x * 98.0) * 0.045;
	float hem = smoothstep(0.005, 0.018, UV.x - edge);
	COLOR = vec4(fabric * pleats * mix(0.55, 1.0, hem), smoothstep(edge - 0.005, edge + 0.003, UV.x));
}
