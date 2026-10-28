shader_type canvas_item;
uniform vec4 tile_region = vec4(0.1, 0.35, 0.9, 0.65);
uniform float flow = 0.0;
varying vec4 tint;
void vertex() {
	tint = COLOR;
}
void fragment() {
	vec2 uv = vec2(mix(tile_region.x, tile_region.z, fract(UV.x - flow)),
		mix(tile_region.y, tile_region.w, UV.y));
	COLOR = texture(TEXTURE, uv) * tint;
}
