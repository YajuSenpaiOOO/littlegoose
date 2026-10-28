shader_type canvas_item;
render_mode unshaded, blend_mul;
uniform float source_scale_y = 1.0;
uniform float strength = 0.22;
varying float foot_y;
void vertex() { foot_y = VERTEX.y * source_scale_y; }
void fragment() {
    // Only the lowest few world pixels of the real shoes, not a body-sized oval.
    float band = smoothstep(-3.0, -0.7, foot_y) * (1.0-smoothstep(0.5,1.5,foot_y));
    float alpha = texture(TEXTURE,UV).a * band * strength;
    COLOR = vec4(mix(vec3(1.0),vec3(0.28,0.27,0.32),alpha),1.0);
}
