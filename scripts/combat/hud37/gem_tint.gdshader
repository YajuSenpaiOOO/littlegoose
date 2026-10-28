shader_type canvas_item;

varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec4 art = texture(TEXTURE, UV);
	// White draws preserve the empty socket; colored draws recolor the pink facets.
	if (distance(vertex_tint.rgb, vec3(1.0)) > 0.01) {
		float light = dot(art.rgb, vec3(0.299, 0.587, 0.114));
		art.rgb = vec3(light);
	}
	COLOR = art * vertex_tint;
}
