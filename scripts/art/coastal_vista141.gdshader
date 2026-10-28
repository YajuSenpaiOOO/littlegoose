shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled;
uniform sampler2D art : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 tint : source_color=vec4(1.0);
void fragment(){
 // The quad extends above/below the painted image. Clamp its top sky and
 // bottom water continuously so a scenic camera tilt cannot expose an edge.
 vec2 uv=(UV-vec2(.5))*vec2(1.,1.8)+vec2(.5);
 float distance=1.-smoothstep(.18,.7,uv.y);
 vec2 d=vec2(mix(.45,1.4,distance))/vec2(textureSize(art,0));
 vec4 c=texture(art,uv)*.6;
 c+=(texture(art,uv+vec2(d.x,0.0))+texture(art,uv-vec2(d.x,0.0))+texture(art,uv+vec2(0.0,d.y))+texture(art,uv-vec2(0.0,d.y)))*.1;
 float horizon=1.-smoothstep(.02,.21,abs(uv.y-.20));
 float luminance=dot(c.rgb,vec3(.299,.587,.114));
 vec3 pigment=mix(c.rgb,vec3(luminance),.10*distance);
 ALBEDO=mix(pigment,vec3(.68,.80,.86),.035+.14*horizon)*tint.rgb;
 ALPHA=c.a*tint.a;
}
