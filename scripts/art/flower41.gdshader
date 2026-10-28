shader_type spatial;
render_mode cull_disabled, world_vertex_coords;
uniform sampler2D paint : source_color, filter_linear_mipmap;
uniform vec3 walker = vec3(1000.);
uniform float clock=0.;
varying float tip;
void vertex(){
 vec3 root=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 tip=1.-UV.y;
 float flex=tip*tip;
 vec2 away=root.xz-walker.xz;
 float touch=(1.-smoothstep(.12,.65,length(away)))*(1.-smoothstep(.5,1.2,abs(walker.y-root.y)));
 VERTEX.xz+=normalize(away+vec2(.001))*touch*.18*flex;
 VERTEX.y-=touch*.07*flex;
 VERTEX.x+=sin(clock*1.4+root.x*1.9+root.z)*.018*flex;
}
void fragment(){
 vec4 tex=texture(paint,UV);
 if(tex.a<.45) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=tex.rgb*COLOR.rgb*mix(.82,1.,smoothstep(0.,.4,tip));
 ROUGHNESS=1.; SPECULAR=0.;
}
