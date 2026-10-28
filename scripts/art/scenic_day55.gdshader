shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, depth_draw_never, depth_test_disabled;
uniform sampler2D screen_image : hint_screen_texture, filter_linear;
uniform sampler2D depth_image : hint_depth_texture, filter_nearest;
uniform float focus_distance=15.;
uniform float radius_pixels=6.2;
uniform float clear_span=2.8;
uniform float tone_strength=0.;
uniform float day_exposure55=1.;
uniform float tone_contrast=1.;
uniform float tone_saturation=1.;
uniform vec3 tone_shadows=vec3(1.);
uniform vec3 tone_highlights=vec3(1.);
vec3 tone(vec3 col){
 float lum=dot(col,vec3(.2126,.7152,.0722));
 vec3 tint=mix(tone_shadows,tone_highlights,smoothstep(.14,.70,lum));
 vec3 graded=mix(vec3(lum),col,tone_saturation)*tint;
 graded=(graded-.42)*tone_contrast+.42;
 return mix(col,clamp(graded,vec3(0.),vec3(1.)),tone_strength);
}
uniform float stage_strength=0.;
uniform float glow_strength=0.;
uniform vec4 glow_lights[4];
float glass_mask(vec2 uv){
 float mask=0.;
 for(int i=0;i<4;i++){
  vec2 q=abs(uv-glow_lights[i].xy)/glow_lights[i].zw;
  mask=max(mask,1.-smoothstep(.78,1.18,max(q.x,q.y)));
 }
 return mask;
}
vec3 glow_sample(vec2 uv){
 vec3 c=texture(screen_image,uv).rgb;
 float warm=smoothstep(.10,.30,c.r-c.b)*(1.-smoothstep(.03,.15,c.g-c.r));
 float bright=smoothstep(.65,.92,max(c.r,c.g));
 return c*warm*bright*glass_mask(uv);
}
vec3 local_glow(vec2 uv){
 vec2 pixel=1./vec2(textureSize(screen_image,0));
 bool nearby=false;
 for(int i=0;i<4;i++){
  vec2 gap=(abs(uv-glow_lights[i].xy)-glow_lights[i].zw)/pixel;
  if(max(gap.x,gap.y)<19.) nearby=true;
 }
 if(!nearby) return vec3(0.);
 vec3 sum=glow_sample(uv); float weights=1.;
 for(int i=1;i<=12;i++){
  float t=float(i)/12.;
  float a=float(i)*2.39996323;
  float weight=exp(-t*2.2);
  sum+=glow_sample(uv+vec2(cos(a),sin(a))*sqrt(t)*16.*pixel)*weight;
  weights+=weight;
 }
 return sum/weights;
}
void vertex(){ POSITION=vec4(VERTEX.xy,1.,1.); }
void fragment(){
 float depth=texture(depth_image,SCREEN_UV).r;
 vec3 ndc=vec3(SCREEN_UV*2.-1.,depth);
 if(CLIP_SPACE_FAR==-1.) ndc.z=depth*2.-1.;
 vec4 point=INV_PROJECTION_MATRIX*vec4(ndc,1.);
 float distance=-point.z/point.w;
 float far_focus=smoothstep(focus_distance+clear_span,focus_distance+clear_span+9.,distance);
 float near_focus=1.-smoothstep(max(2.,focus_distance-9.),max(4.,focus_distance-3.5),distance);
 float amount=max(far_focus,near_focus);
 if(radius_pixels<=0.) amount=0.;
 vec3 sharp=texture(screen_image,SCREEN_UV).rgb;
 if(amount<.015){
  ALBEDO=sharp;
 }else{
  // Explicit Gaussian disk works on the current Compatibility backbuffer;
  // increasing mip LOD alone did not blur its captured scene in our render probe.
  vec2 pixel=1./vec2(textureSize(screen_image,0));
  vec3 blurred=sharp;
  float total=1.;
  for(int i=1;i<=24;i++){
   float t=float(i)/24.;
   float angle=float(i)*2.39996323;
   vec2 offset=vec2(cos(angle),sin(angle))*sqrt(t)*radius_pixels*amount*pixel;
   float weight=exp(-t*2.4);
   blurred+=texture(screen_image,SCREEN_UV+offset).rgb*weight;
   total+=weight;
  }
  ALBEDO=mix(sharp,blurred/total,smoothstep(0.,.65,amount));
 }
 ALBEDO=mix(tone(ALBEDO)*day_exposure55,ALBEDO,glass_mask(SCREEN_UV)*.92);
 if(stage_strength>0.){
  float front=1.-smoothstep(max(1.,focus_distance-9.),max(3.,focus_distance-3.5),distance);
  float back=smoothstep(focus_distance+7.,focus_distance+23.,distance);
  vec3 staged=ALBEDO*mix(vec3(1.),vec3(.68,.78,.76),front);
  float lum=dot(staged,vec3(.2126,.7152,.0722));
  staged=mix(staged,vec3(lum)*vec3(.96,1.,1.02),back*.40);
  staged*=1.-back*.055;
  ALBEDO=mix(ALBEDO,staged,stage_strength);
 }
 if(glow_strength>0.){
  float lum=dot(ALBEDO,vec3(.2126,.7152,.0722));
  ALBEDO+=local_glow(SCREEN_UV)*glow_strength*(1.-smoothstep(.65,.95,lum)*.6);
 }
}
