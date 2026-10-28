shader_type canvas_item;
render_mode unshaded, blend_mul;
uniform float shadow_strength = 0.32;

varying float opacity;

void vertex() {
	opacity = COLOR.a;
}

void fragment() {
	vec2 offset = (UV - vec2(0.5)) * 2.0;
	float radius = length(offset);
	float contact = exp(-dot(offset, offset) * 3.5);
	contact *= 1.0 - smoothstep(0.65, 1.0, radius);
	// White is neutral in multiply blending, including fully faded actors.
	vec3 shade = mix(vec3(1.0), vec3(0.46, 0.44, 0.49), contact * shadow_strength * clamp(opacity, 0.0, 1.0));
	COLOR = vec4(shade, 1.0);
}
