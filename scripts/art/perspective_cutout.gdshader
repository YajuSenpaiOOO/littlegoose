shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D paint : source_color, filter_linear;
uniform float fade=1.;
float hash(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void fragment(){
 vec4 tex=texture(paint,UV);
 if(tex.a<.5) discard;
 if(hash(floor(FRAGCOORD.xy))>fade) discard;
 ALBEDO=tex.rgb*COLOR.rgb;
}
