shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap,repeat_disable;
uniform vec4 sample_rect82=vec4(0.,0.,1.,1.);
uniform float fade82=1.;
varying vec3 normal82;
void vertex(){normal82=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
float hash82(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 if(fade82<.001) discard;
 if(fade82<.999 && hash82(floor(FRAGCOORD.xy))>fade82) discard;
 vec4 tex=texture(paint,sample_rect82.xy+UV*sample_rect82.zw);
 if(tex.a<.97) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(normalize(normal82+vec3(0.,.25,0.)),0.)).xyz);
 ALBEDO=tex.rgb;ROUGHNESS=1.;SPECULAR=0.;
}
