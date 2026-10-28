shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color, filter_linear_mipmap;
uniform float glass_energy55=.22;
void fragment(){
 vec4 color=texture(paint,UV);
 if(color.a<.5) discard;
 ALBEDO=color.rgb;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 float glass=smoothstep(.55,.9,color.r)*smoothstep(.12,.3,color.r-color.b);
 EMISSION=color.rgb*glass*glass_energy55;
 ROUGHNESS=1.; SPECULAR=0.;
}
