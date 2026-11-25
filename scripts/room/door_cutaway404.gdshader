shader_type spatial;
render_mode cull_disabled;
uniform vec4 tint:source_color=vec4(1.);
uniform sampler2D paint:source_color,filter_linear_mipmap;
uniform bool use_paint=false;
uniform vec4 region=vec4(0.,0.,1.,1.);
uniform bool cutaway=false;
varying float height404;
void vertex(){height404=(MODEL_MATRIX*vec4(VERTEX,1.)).y;}
void fragment(){
 if(cutaway && height404>.40){discard;}
 ALBEDO=tint.rgb*(use_paint?texture(paint,region.xy+UV*region.zw).rgb:vec3(1.));
 ROUGHNESS=1.;SPECULAR=0.;
}
