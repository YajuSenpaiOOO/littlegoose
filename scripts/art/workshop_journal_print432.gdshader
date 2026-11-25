shader_type canvas_item;

varying vec4 page_tone;

void vertex() {
	page_tone = COLOR;
}

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	float value = dot(original.rgb, vec3(.299, .587, .114));
	vec3 sepia = mix(vec3(.26, .16, .10), vec3(.93, .81, .62), value);
	vec3 print_ink = mix(original.rgb, sepia, .40);
	float fibre = fract(sin(dot(floor(UV * 510.), vec2(31.1, 76.7))) * 9173.71);
	COLOR = vec4((print_ink + (fibre - .5) * .06) * page_tone.rgb, original.a * .90 * page_tone.a);
}
