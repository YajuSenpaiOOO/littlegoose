shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color, filter_linear_mipmap;
uniform float glow106=.2;
void fragment(){
 vec4 color=texture(paint,UV);
 if(color.a<.5) discard;
 ALBEDO=color.rgb;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 // Only glass emits: timber and ivy must remain dark at night.
 float window=smoothstep(.62,.66,UV.x)*(1.-smoothstep(.81,.84,UV.x))*smoothstep(.29,.31,UV.y)*(1.-smoothstep(.39,.41,UV.y));
 float amber=smoothstep(.55,.9,color.r)*smoothstep(.12,.3,color.r-color.b);
 EMISSION=color.rgb*amber*window*glow106;
 ROUGHNESS=1.; SPECULAR=0.;
}
