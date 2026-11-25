shader_type canvas_item;
render_mode unshaded;

uniform sampler2D paper_alpha : filter_linear, repeat_disable;
uniform sampler2D pen_alpha : filter_linear, repeat_disable;
uniform vec2 canvas_size = vec2(1000.0, 625.0);
uniform vec4 pen_rect;
uniform float strength = 0.25;

float blur_pen(vec2 uv, vec2 step_size) {
	float alpha = texture(pen_alpha, uv).a * 4.0;
	alpha += 2.0 * (texture(pen_alpha, uv + vec2(step_size.x, 0.0)).a
		+ texture(pen_alpha, uv - vec2(step_size.x, 0.0)).a
		+ texture(pen_alpha, uv + vec2(0.0, step_size.y)).a
		+ texture(pen_alpha, uv - vec2(0.0, step_size.y)).a);
	alpha += texture(pen_alpha, uv + step_size).a
		+ texture(pen_alpha, uv - step_size).a
		+ texture(pen_alpha, uv + vec2(step_size.x, -step_size.y)).a
		+ texture(pen_alpha, uv + vec2(-step_size.x, step_size.y)).a;
	return alpha / 16.0;
}

void fragment() {
	float receiver = texture(paper_alpha, UV).a * smoothstep(0.43, 0.52, UV.x);
	vec2 pen_size = max(pen_rect.zw, vec2(1.0));
	vec2 uv = (UV * canvas_size - pen_rect.xy - vec2(-12.0, 13.0)) / pen_size;
	float silhouette = 0.0;
	if (receiver > 0.001 && all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0)))) {
		silhouette = blur_pen(uv, vec2(6.0) / pen_size);
	}
	COLOR = vec4(0.25, 0.13, 0.12, COLOR.a * silhouette * receiver * strength);
}
