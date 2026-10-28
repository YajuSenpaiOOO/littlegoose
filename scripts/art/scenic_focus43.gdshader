shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, depth_draw_never, depth_test_disabled;
uniform sampler2D screen_image : hint_screen_texture, filter_linear;
uniform sampler2D depth_image : hint_depth_texture, filter_nearest;
uniform float focus_distance=15.;
uniform float radius_pixels=6.2;
uniform float clear_span=2.8;
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
}
