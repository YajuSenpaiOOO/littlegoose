shader_type spatial;
render_mode cull_disabled,shadows_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap;
uniform float fade=1.;
uniform float alpha_threshold=.5;
uniform vec3 tint : source_color=vec3(1.);
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec4 tex=texture(paint,UV);
 if(tex.a<alpha_threshold) discard;
 if(fade<.999 && hash(floor(FRAGCOORD.xy))>fade) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=tex.rgb*tint;
 ROUGHNESS=1.; SPECULAR=0.;
}
