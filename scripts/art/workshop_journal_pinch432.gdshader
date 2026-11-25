shader_type canvas_item;

varying vec4 light_tone;

void vertex() {
	light_tone = COLOR;
}

void fragment() {
	vec2 pixel = UV * vec2(1536.0, 1024.0);
	vec4 ink = texture(TEXTURE, UV);
	vec2 bead_uv = (pixel - vec2(429.5, 586.5)) / vec2(31.6, 28.5);
	float cut = 1.0 - smoothstep(.95, 1.0, length(bead_uv));
	ink.a *= 1.0 - cut;
	COLOR = ink * light_tone;
}
