shader_type canvas_item;
render_mode unshaded, blend_mul;
uniform float strength = 0.22;
uniform vec3 shadow_tint : source_color = vec3(0.20,0.22,0.30);
void fragment() {
    float alpha = texture(TEXTURE, UV).a;
    // White outside the silhouette is neutral under multiply, even at night.
    COLOR = vec4(mix(vec3(1.0),shadow_tint,alpha*strength),1.0);
}
