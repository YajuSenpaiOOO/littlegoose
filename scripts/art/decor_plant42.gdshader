shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap;
uniform float root_cut_y=1.;
uniform float clock=0.;
uniform vec3 walker=vec3(1000.);
uniform float flex=.025;
varying float tip;
void vertex(){
 vec3 root=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 tip=1.-UV.y;
 vec2 away=root.xz-walker.xz;
 float touch=(1.-smoothstep(.15,.8,length(away)))*(1.-smoothstep(.6,1.3,abs(root.y-walker.y)));
 VERTEX.x+=(sin(clock*1.3+root.x+root.z)*flex+touch*sign(away.x)*.12)*tip*tip;
 VERTEX.y-=touch*.035*tip;
}
void fragment(){
 vec4 tex=texture(paint,UV);
 if(tex.a<.5 || UV.y>root_cut_y) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=tex.rgb;
 ROUGHNESS=1.; SPECULAR=0.;
}
