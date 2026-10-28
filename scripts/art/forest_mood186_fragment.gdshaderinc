 // Regional cool canopy, lavender shadow fill and protected amber lights.
 if(forest_strength186>.001){
  vec3 hit186=(INV_VIEW_MATRIX*vec4(point.xyz/point.w,1.)).xyz;
  float region186=forest_region186(hit186)*forest_strength186;
  vec2 p186=hit186.xz-vec2(-48.,0.);
  float clear186=1.-smoothstep(.45,1.1,length(p186/vec2(14.,11.)));
  vec3 original186=ALBEDO;
  float lum186=dot(original186,vec3(.2126,.7152,.0722));
  float warm186=smoothstep(.055,.23,original186.r-original186.b)*smoothstep(.27,.67,original186.r);
  float pool186=0.;
  for(int i=0;i<12;i++){
   if(i>=forest_pool_count186) break;
   vec4 lamp186=forest_pools186[i];
   float near186=1.-smoothstep(.25,lamp186.z,length(hit186.xz-lamp186.xy));
   near186*=1.-smoothstep(1.8,4.,hit186.y-lamp186.w);
   pool186=max(pool186,near186);
  }
  vec3 cool186=mix(vec3(lum186),original186,.73)*mix(vec3(.43,.52,.71),vec3(.65,.69,.85),clear186);
  float shadow186=1.-smoothstep(.12,.45,lum186);
  cool186+=vec3(.025,.014,.046)*shadow186;
  cool186+=vec3(.065,.032,.008)*pool186;
  cool186=mix(cool186,original186,max(warm186*.83,pool186*.24));
  float back186=smoothstep(focus_distance+5.,focus_distance+23.,distance);
  cool186=mix(cool186,vec3(.12,.13,.205),back186*.10);
  float actor186=actor_mask57*.22;
  ALBEDO=mix(original186,max(cool186,vec3(.018,.023,.037)),region186*(1.-actor186));
 }
