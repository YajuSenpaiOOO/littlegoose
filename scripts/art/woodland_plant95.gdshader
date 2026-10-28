shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap;
uniform vec3 tint : source_color=vec3(.88,.92,.85);
uniform float fade=1.;
uniform float clock=0.;
uniform vec3 push94=vec3(0.);
uniform bool field94=false;
uniform bool reactive94=true;
uniform vec3 walker=vec3(1000.);
uniform vec4 trail[8];
void vertex(){
 vec3 root=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 vec3 push=push94;
 if(field94){
  vec2 away=root.xz-walker.xz;
  float level=1.-smoothstep(.5,1.1,abs(root.y-walker.y));
  float pressure=(1.-smoothstep(.12,.85,length(away)))*level;
  vec2 offset=normalize(away+vec2(.001))*pressure*.22;
  for(int i=0;i<8;i++){
   float age=clock-trail[i].z;
   if(age>=0. && age<.9){
    vec2 past=root.xz-trail[i].xy;
    offset+=normalize(past+vec2(.001))*(1.-smoothstep(.1,.75,length(past)))*exp(-age*6.)*.07*level;
   }
  }
  push=vec3(offset.x,-pressure*.055,offset.y);
 }
 float tip=clamp(1.-UV.y,0.,1.);
 vec3 wind=vec3(sin(clock*1.45+root.x*1.8+root.z)*.018,0.,cos(clock*1.1+root.z)*.007);
 vec3 local=(inverse(MODEL_MATRIX)*vec4((push*(reactive94 ? 1. : 0.)+wind)*tip*tip,0.)).xyz;
 VERTEX+=local;
}
void fragment(){
 vec4 tex=texture(paint,UV);
 if(tex.a<.5) discard;
 if(fade<.999 && fract(sin(dot(floor(FRAGCOORD.xy),vec2(127.1,311.7)))*43758.5453)>fade) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=tex.rgb*tint;
 ROUGHNESS=1.;SPECULAR=0.;
}
