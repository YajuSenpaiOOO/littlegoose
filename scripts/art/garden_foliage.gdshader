shader_type canvas_item;
uniform float phase = 0.0;
uniform float strength = 0.0;
uniform bool remove_white_matte = false;
varying vec4 item_tint;
void vertex() { item_tint = COLOR; }
void fragment() {
	vec2 uv = UV;
	float canopy = 1.0-smoothstep(0.15, 0.85, uv.y);
	uv.x += sin(TIME * 1.3 + phase + uv.y * 2.5) * strength * canopy;
	vec4 paint = texture(TEXTURE, uv);
	if (remove_white_matte && min(paint.r,min(paint.g,paint.b)) > 0.99) { paint.a = 0.0; }
	COLOR = paint * item_tint;
}
