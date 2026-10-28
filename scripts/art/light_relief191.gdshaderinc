uniform int light_count191=0;
uniform vec4 lights191[20];
uniform vec4 stage191=vec4(0.);
float light_relief191(vec3 hit){
 float sum=0.;
 for(int i=0;i<20;i++){
  if(i>=light_count191)break;
  vec4 lamp=lights191[i];
  float d=length((hit-lamp.xyz)*vec3(1.,.65,1.));
  sum+=pow(1.-smoothstep(.3,lamp.w,d),2.);
 }
 // A world-space stage footprint, not a screen ellipse around the character.
 float stage=(1.-smoothstep(.65,2.25,length(hit.xz-stage191.xy)))*stage191.z;
 stage*=1.-smoothstep(2.4,5.,hit.y-stage191.w);
 return clamp(max(sum,stage),0.,1.);
}
