shader_type canvas_item;
varying vec4 item_tint;
void vertex() { item_tint = COLOR; }
void fragment() {
    vec4 paint = texture(TEXTURE, UV);
    // The generated export retained a soft matte. Exclude it at render time;
    // preserve the source PNG and its opaque pixel-art silhouette.
    paint.a = step(0.97, paint.a);
    COLOR = paint * item_tint;
}
