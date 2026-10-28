shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled;
uniform sampler2D art : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 tint : source_color=vec4(1.0);
void fragment(){
 vec2 d=vec2(1.1)/vec2(textureSize(art,0));
 vec4 c=texture(art,UV)*.5;
 c+=(texture(art,UV+vec2(d.x,0.0))+texture(art,UV-vec2(d.x,0.0))+texture(art,UV+vec2(0.0,d.y))+texture(art,UV-vec2(0.0,d.y)))*.125;
 ALBEDO=mix(c.rgb,vec3(.62,.75,.80),.07)*tint.rgb;
 ALPHA=c.a*tint.a;
}
