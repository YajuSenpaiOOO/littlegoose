shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled;
uniform sampler2D art : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 daylight : source_color = vec4(1.0);
uniform float blur_px = 1.5;
uniform float haze = 0.10;
void fragment() {
 vec2 step_uv=vec2(blur_px)/vec2(textureSize(art,0));
 vec4 c=texture(art,UV)*0.40;
 c+=texture(art,UV+vec2(step_uv.x,0.0))*0.15;
 c+=texture(art,UV-vec2(step_uv.x,0.0))*0.15;
 c+=texture(art,UV+vec2(0.0,step_uv.y))*0.15;
 c+=texture(art,UV-vec2(0.0,step_uv.y))*0.15;
 ALBEDO=mix(c.rgb,vec3(0.62,0.75,0.80),haze)*daylight.rgb;
 ALPHA=c.a;
}
