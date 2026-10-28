shader_type spatial;
uniform bool route_layout=true;
uniform int route_count=0;
uniform vec4 route_segments[64];
uniform float route_widths[64];
uniform float rail_line_z72=-61.4;
uniform vec2 rail_extent72=vec2(-22.,32.);
varying vec3 at72;
varying vec3 normal72;
void vertex(){at72=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz; normal72=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 float d=1000.;
 for(int i=0;i<64;i++){
  if(i>=route_count)break;
  vec2 a=route_segments[i].xy,b=route_segments[i].zw,v=b-a;
  float t=clamp(dot(at72.xz-a,v)/max(.0001,dot(v,v)),0.,1.);
  d=min(d,length(at72.xz-a-v*t)*.77/max(.01,route_widths[i]));
 }
 float road=1.-smoothstep(.65,.88,d);
 vec3 land=mix(vec3(.34,.42,.29),vec3(.40,.47,.34),smoothstep(.3,5.5,at72.y));
 land=mix(land,vec3(.34,.35,.32),1.-smoothstep(.55,.86,normal72.y));
 land=mix(land,vec3(.48,.43,.33),road*smoothstep(.65,.9,normal72.y));
 float rail=(1.-smoothstep(3.1,3.4,abs(at72.z-rail_line_z72)))*step(rail_extent72.x,at72.x)*(1.-step(rail_extent72.y,at72.x));
 ALBEDO=mix(land,vec3(.32,.33,.31),rail);
 ROUGHNESS=1.; SPECULAR=0.;
}
