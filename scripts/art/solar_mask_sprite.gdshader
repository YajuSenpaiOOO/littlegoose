shader_type canvas_item;
render_mode unshaded;
uniform float coverage = 1.0;
uniform float strength = 1.0;
uniform vec3 shadow_tint;
void fragment() {
    float alpha=texture(TEXTURE,UV).a;
    // A union of opaque blockers, not a pile of partly darkened ground layers.
    if(alpha<0.45 || coverage<0.01) discard;
    COLOR=vec4(1.0,1.0,1.0,coverage);
}
