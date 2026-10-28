shader_type canvas_item;
render_mode unshaded, blend_mul;
uniform vec3 shadow_tint : source_color = vec3(0.20,0.22,0.30);
varying float strength;
void vertex() { strength = COLOR.a; }
void fragment() {
    COLOR = vec4(mix(vec3(1.0),shadow_tint,strength),1.0);
}
