uniform float forest_strength186=0.;
uniform int forest_pool_count186=0;
uniform vec4 forest_pools186[12];
float forest_line186(vec2 p,vec2 a,vec2 b){
 return length(p-a-(b-a)*clamp(dot(p-a,b-a)/dot(b-a,b-a),0.,1.));
}
float forest_region186(vec3 hit){
 vec2 p=hit.xz-vec2(-48.,0.);
 float r=length((p-vec2(-1.,0.))/vec2(17.,15.));
 float core=1.-smoothstep(.85,1.15,r);
 float canopy=(1.-smoothstep(1.,1.55,r))*smoothstep(.2,3.5,hit.y);
 float nook=1.-smoothstep(.75,1.2,length((p-vec2(-11.,-10.))/vec2(7.,6.)));
 float d=forest_line186(p,vec2(33.,-3.),vec2(28.,-3.));
 d=min(d,forest_line186(p,vec2(28.,-3.),vec2(23.,3.)));
 d=min(d,forest_line186(p,vec2(23.,3.),vec2(18.,3.)));
 d=min(d,forest_line186(p,vec2(18.,3.),vec2(14.,7.)));
 d=min(d,forest_line186(p,vec2(14.,7.),vec2(10.,8.)));
 float approach=(1.-smoothstep(2.4,4.2,d))*smoothstep(0.,1.,clamp((33.-p.x)/23.,0.,1.));
 return max(max(core,nook),max(canopy,approach));
}
