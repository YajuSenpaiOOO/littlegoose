shader_type spatial;
render_mode cull_disabled, shadows_disabled;
uniform sampler2D paint : source_color, filter_linear_mipmap, repeat_disable;
uniform float fade=1.;
uniform float glow81=0.;
uniform vec2 glass_band81=vec2(.64,.80);
float noise81(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec4 tex=texture(paint,UV);
 if(tex.a<.97) discard;
 if(fade<.999 && noise81(floor(FRAGCOORD.xy))>fade) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=tex.rgb; ROUGHNESS=1.; SPECULAR=0.;
 // Only painted amber glass gets a restrained core; stone and roof stay matte.
 float amber=smoothstep(.48,.78,tex.r)*smoothstep(.12,.30,tex.r-tex.b)*smoothstep(.28,.55,tex.g);
 float glass=step(glass_band81.x,UV.y)*(1.-step(glass_band81.y,UV.y));
 EMISSION=tex.rgb*amber*glass*glow81*.65;
}
