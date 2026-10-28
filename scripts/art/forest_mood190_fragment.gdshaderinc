 // Cool canopy grade. Keep the actor close to the authored sprite palette;
 // local lamps must not paint a roaming warm patch across the face.
 if(forest_strength186>.001){
  vec3 hit186=(INV_VIEW_MATRIX*vec4(point.xyz/point.w,1.)).xyz;
  float region186=forest_region186(hit186)*forest_strength186*mix(1.,.56,night_mix56);
  vec2 p186=hit186.xz-vec2(-48.,24.);
  float clear186=1.-smoothstep(.45,1.1,length(p186/vec2(14.,11.)));
  vec3 original186=ALBEDO;
  float lum186=dot(original186,vec3(.2126,.7152,.0722));
  float core190=emitter_mask190(SCREEN_UV,distance)*smoothstep(.18,.55,lum186);
  float pool186=0.;
  for(int i=0;i<12;i++){
   if(i>=forest_pool_count186) break;
   vec4 lamp186=forest_pools186[i];
   float near186=1.-smoothstep(.25,lamp186.z,length(hit186.xz-lamp186.xy));
   near186*=1.-smoothstep(1.8,4.,hit186.y-lamp186.w);
   pool186=max(pool186,near186);
  }
  vec3 cool186=mix(vec3(lum186),original186,.53)*mix(vec3(.36,.29,.53),vec3(.49,.42,.64),clear186);
  cool186=mix(cool186,original186*vec3(.92,.80,.67),pool186*.46);
  cool186=mix(cool186,original186,core190*.96);
  float back186=smoothstep(focus_distance+5.,focus_distance+23.,distance);
  cool186=mix(cool186,vec3(.105,.075,.18),back186*.16);
  ALBEDO=mix(original186,cool186,region186);
 }
