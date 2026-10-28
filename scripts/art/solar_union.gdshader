shader_type canvas_item;
render_mode unshaded, blend_mul;
uniform float strength = 0.27;
uniform vec3 shadow_tint : source_color = vec3(0.2,0.23,0.3);
void fragment() {
    vec2 pixel=TEXTURE_PIXEL_SIZE*1.2;
    float mask=texture(TEXTURE,UV).a*0.6;
    mask+=texture(TEXTURE,UV+vec2(pixel.x,0.0)).a*0.1;
    mask+=texture(TEXTURE,UV-vec2(pixel.x,0.0)).a*0.1;
    mask+=texture(TEXTURE,UV+vec2(0.0,pixel.y)).a*0.1;
    mask+=texture(TEXTURE,UV-vec2(0.0,pixel.y)).a*0.1;
    COLOR=vec4(mix(vec3(1.0),shadow_tint,mask*strength),1.0);
}
