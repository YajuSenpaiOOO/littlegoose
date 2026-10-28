shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, shadows_disabled;
uniform sampler2D art153 : source_color, filter_nearest_mipmap;
uniform float bend153=0.;
uniform float flatten153=0.;
uniform float fade153=1.;
void vertex(){
 VERTEX.x+=bend153*UV.y*UV.y*3.;
 VERTEX.y=mix(VERTEX.y, VERTEX.y*.58, flatten153);
 VERTEX.x+=flatten153*UV.y*UV.y*.16;
}
void fragment(){
 vec4 c=texture(art153,UV);
 if(c.a<.86){discard;}
 ALBEDO=c.rgb;ROUGHNESS=.85;ALPHA=c.a*fade153;
}
