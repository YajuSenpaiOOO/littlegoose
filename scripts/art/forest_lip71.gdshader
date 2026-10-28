shader_type spatial;
uniform sampler2D paint : source_color,filter_linear_mipmap,repeat_enable;
varying vec3 position71;
void vertex(){position71=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 vec2 mirrored=1.-abs(fract(position71.xz/12.)*2.-1.);
 ALBEDO=texture(paint,mirrored).rgb;
 ROUGHNESS=1.; SPECULAR=0.;
}
