shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled;
uniform sampler2D art : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 tint : source_color=vec4(1.0);
void fragment(){
 // The horizon is the softest part. Do not blur the whole landscape flat.
 float distance=1.-smoothstep(.18,.7,UV.y);
 vec2 d=vec2(mix(.45,1.4,distance))/vec2(textureSize(art,0));
 vec4 c=texture(art,UV)*.6;
 c+=(texture(art,UV+vec2(d.x,0.0))+texture(art,UV-vec2(d.x,0.0))+texture(art,UV+vec2(0.0,d.y))+texture(art,UV-vec2(0.0,d.y)))*.1;
 float horizon=1.-smoothstep(.02,.21,abs(UV.y-.20));
 float luminance=dot(c.rgb,vec3(.299,.587,.114));
 vec3 pigment=mix(c.rgb,vec3(luminance),.10*distance);
 pigment=mix(pigment,vec3(.68,.80,.86),.035+.14*horizon);
 ALBEDO=pigment*tint.rgb;
 ALPHA=c.a*tint.a;
}
