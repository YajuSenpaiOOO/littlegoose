shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint: source_color,filter_nearest_mipmap,repeat_disable;
uniform vec4 region219=vec4(0.,0.,1.,1.);
uniform vec3 normal219=vec3(0.,.422618,.906308);
void fragment(){
 vec4 tex=texture(paint,region219.xy+UV*region219.zw);
 if(tex.a<.6)discard;
 ALBEDO=tex.rgb*COLOR.rgb*.82;ROUGHNESS=1.;SPECULAR=0.;
 NORMAL=normalize((VIEW_MATRIX*vec4(normal219,0.)).xyz);
}
