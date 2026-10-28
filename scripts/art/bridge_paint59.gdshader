shader_type spatial;
render_mode cull_disabled,shadows_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap,repeat_disable;
uniform vec4 region59=vec4(0.,0.,1.,1.);
uniform float fade59=1.;
uniform vec3 tint59 : source_color=vec3(1.);
void fragment(){
 vec4 tex=texture(paint,region59.xy+UV*region59.zw);
 if(tex.a<.5) discard;
 if(fract(sin(dot(floor(FRAGCOORD.xy),vec2(12.9898,78.233)))*43758.5453)>fade59) discard;
 ALBEDO=tex.rgb*tint59;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ROUGHNESS=1.; SPECULAR=0.;
}
