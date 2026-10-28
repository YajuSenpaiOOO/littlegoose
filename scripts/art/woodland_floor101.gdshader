shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap;
uniform float wing_clock=0.;
uniform bool butterfly=false;
varying float phase;
void vertex(){
 phase=INSTANCE_CUSTOM.x*6.2831853;
 if(butterfly){VERTEX.y+=abs(VERTEX.x)*sin(wing_clock*23.+phase)*1.4;}
}
void fragment(){
 vec4 tex=texture(paint,UV);
 if(tex.a<.5) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,1.,0.,0.)).xyz);
 vec3 col=tex.rgb;
 if(!butterfly){col=mix(vec3(dot(col,vec3(.299,.587,.114))),col,.68)*vec3(.72,.78,.66);}
 ALBEDO=col;ROUGHNESS=1.;SPECULAR=0.;
}
