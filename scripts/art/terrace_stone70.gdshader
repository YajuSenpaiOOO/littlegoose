shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap,repeat_enable;
uniform vec3 tint : source_color=vec3(.78,.86,.95);
varying vec3 world70;
varying vec3 normal70;
void vertex(){ world70=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz; normal70=normalize(MODEL_NORMAL_MATRIX*NORMAL); }
void fragment(){
 vec3 w=pow(abs(normal70),vec3(5.)); w/=max(.001,w.x+w.y+w.z);
 vec3 a=texture(paint,world70.zy*.42).rgb;
 vec3 b=texture(paint,world70.xz*.42).rgb;
 vec3 c=texture(paint,world70.xy*.42).rgb;
 ALBEDO=(a*w.x+b*w.y+c*w.z)*tint*COLOR.rgb;
 ROUGHNESS=1.; SPECULAR=.04;
}
