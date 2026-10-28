shader_type spatial;
render_mode cull_disabled,shadows_disabled;
uniform sampler2D paint: source_color,filter_linear_mipmap;
uniform float glow144=.12;
void fragment(){
 vec4 color=texture(paint,UV);if(color.a<.5) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 float pane=smoothstep(.48,.55,UV.y)*(1.-smoothstep(.82,.88,UV.y));
 float warm=smoothstep(.55,.85,color.r)*smoothstep(.12,.35,color.r-color.b);
 ALBEDO=color.rgb;EMISSION=color.rgb*warm*pane*glow144;
 ROUGHNESS=1.;SPECULAR=0.;
}
