uniform float forest_strength186=0.;
uniform int forest_pool_count186=0;
uniform vec4 forest_pools186[12];
uniform int approach_count189=0;
uniform vec4 approach189[64];
uniform float traveller189=0.;
float forest_line186(vec2 p,vec2 a,vec2 b){
 return length(p-a-(b-a)*clamp(dot(p-a,b-a)/dot(b-a,b-a),0.,1.));
}
float forest_region186(vec3 hit){
 vec2 p=hit.xz-vec2(-48.,24.);
 float r=length((p-vec2(-1.,0.))/vec2(17.,15.));
 float core=1.-smoothstep(.85,1.15,r);
 float canopy=(1.-smoothstep(1.,1.55,r))*smoothstep(.2,3.5,hit.y);
 float nook=1.-smoothstep(.75,1.2,length((p-vec2(-11.,-10.))/vec2(7.,6.)));
 float d=forest_line186(p,vec2(33.,-3.),vec2(28.,-3.));
 d=min(d,forest_line186(p,vec2(28.,-3.),vec2(23.,3.)));
 d=min(d,forest_line186(p,vec2(23.,3.),vec2(18.,3.)));
 d=min(d,forest_line186(p,vec2(18.,3.),vec2(14.,7.)));
 d=min(d,forest_line186(p,vec2(14.,7.),vec2(10.,8.)));
 float approach=(1.-smoothstep(4.,10.,d))*mix(.82,1.,smoothstep(0.,1.,clamp((33.-p.x)/23.,0.,1.)));
 float outer=0.;
 for(int i=1;i<64;i++){
  if(i>=approach_count189)break;
  vec4 a=approach189[i-1];vec4 b=approach189[i];
  vec2 v=b.xy-a.xy;float t=clamp(dot(hit.xz-a.xy,v)/max(dot(v,v),.001),0.,1.);
  float near_path=1.-smoothstep(4.,11.,length(hit.xz-a.xy-v*t));
  outer=max(outer,mix(a.z,b.z,t)*near_path);
 }
 float home_safe=smoothstep(4.5,10.,length(hit.xz-vec2(-4.7,-2.6)));
 return max(traveller189*.88,max(outer,max(max(core,nook),max(canopy,approach))))*home_safe;
}
