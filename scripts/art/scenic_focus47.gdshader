shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, depth_draw_never, depth_test_disabled;
uniform sampler2D screen_image : hint_screen_texture, filter_linear;
uniform sampler2D depth_image : hint_depth_texture, filter_nearest;
uniform float focus_distance=15.;
uniform float radius_pixels=6.2;
uniform float clear_span=2.8;
uniform float tone_strength=0.;
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
 ALBEDO=tone(ALBEDO);
}
