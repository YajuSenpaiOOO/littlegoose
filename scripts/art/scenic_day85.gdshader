shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, depth_draw_never, depth_test_disabled;
uniform sampler2D screen_image : hint_screen_texture, filter_linear;
uniform sampler2D depth_image : hint_depth_texture, filter_nearest;
uniform float focus_distance=15.;
uniform float radius_pixels=6.2;
uniform float clear_span=2.8;
uniform float tone_strength=0.;
uniform float noon_strength85=0.;
uniform float day_exposure55=1.;
uniform float night_mix56=0.;
uniform float haze_strength57=0.;
uniform vec3 haze_color57=vec3(.3,.4,.6);
uniform vec2 stage_center57=vec2(-5.);
uniform vec2 stage_radius57=vec2(.01);
uniform float stage_depth57=15.;
uniform float actor_stage57=0.;
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
  if(max(gap.x,gap.y)<25.) nearby=true;
 }
 if(!nearby) return vec3(0.);
 vec3 sum=glow_sample(uv); float weights=1.;
 for(int i=1;i<=12;i++){
  float t=float(i)/12.;
  float a=float(i)*2.39996323;
  float weight=exp(-t*2.2);
  sum+=glow_sample(uv+vec2(cos(a),sin(a))*sqrt(t)*21.*pixel)*weight;
  weights+=weight;
 }
 return sum/weights;
}
uniform float near_blur58=1.;
uniform float cone_strength58=0.;
uniform float cone_density58=.28;
uniform float cone_spread58=.384;
uniform float cone_radius58=2.5;
uniform vec3 cone_tint58=vec3(1.,.94,.82);
uniform vec3 cone_top58=vec3(0.,6.,0.);
uniform vec3 cone_bottom58=vec3(0.);
uniform vec4 cone_bounds58=vec4(-1.);
float cone_air58(vec3 camera,vec3 hit){
 vec3 axis=cone_bottom58-cone_top58;
 float height=length(axis); axis/=max(height,.01);
 vec3 centre=(cone_top58+cone_bottom58)*.5;
 float sphere=sqrt(height*height*.25+cone_radius58*cone_radius58);
 vec3 direction=normalize(hit-camera);
 vec3 origin=camera-centre;
 float b=dot(direction,origin);
 float disc=b*b-dot(origin,origin)+sphere*sphere;
 if(disc<=0.) return 0.;
 float root=sqrt(disc);
 float begin=max(0.,-b-root);
 float end=min(length(hit-camera),-b+root);
 if(end<=begin) return 0.;
 float stride=(end-begin)/10.;
 float sum=0.;
 for(int i=0;i<10;i++){
  vec3 at=camera+direction*(begin+(float(i)+.5)*stride)-cone_top58;
  float along=dot(at,axis);
  if(along<=0. || along>=height) continue;
  float radius=.045+along*cone_spread58;
  float radial=length(at-axis*along)/radius;
  float soft=exp(-radial*radial*3.2)*(1.-smoothstep(.65,1.2,radial));
  float vertical=smoothstep(0.,.12,along/height)*(1.-smoothstep(.8,1.,along/height));
  sum+=soft*vertical*stride;
 }
 return 1.-exp(-sum*cone_density58*cone_strength58);
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
 near_focus*=near_blur58;
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
  vec3 source56=ALBEDO;
 vec3 grade56=tone(source56)*day_exposure55;
 float darkness56=1.-smoothstep(.04,.48,dot(grade56,vec3(.2126,.7152,.0722)));
 grade56+=vec3(.012,.025,.055)*darkness56*night_mix56;
 float warm56=smoothstep(.07,.25,source56.r-source56.b)*smoothstep(.12,.50,source56.r);
 float protection56=max(glass_mask(SCREEN_UV)*.92,warm56*.88*night_mix56);
 ALBEDO=mix(grade56,source56,protection56);
 if(noon_strength85>0.){
  vec3 c85=ALBEDO;
  float l85=dot(c85,vec3(.2126,.7152,.0722));
  // Quiet the luminous yellow-green foliage without tinting stone or skin.
  float green85=smoothstep(.015,.12,c85.g-c85.b)*(1.-smoothstep(.015,.13,c85.r-c85.g));
  c85=mix(c85,vec3(l85),green85*.16);
  c85*=mix(vec3(1.),vec3(.92,.97,1.025),green85*.65);
  float shade85=1.-smoothstep(.12,.55,l85);
  c85*=mix(vec3(1.),vec3(.93,.99,1.06),shade85*.55);
  c85-=max(c85-vec3(.72),vec3(0.))*.18;
  ALBEDO=mix(ALBEDO,c85,noon_strength85);
 }
 vec2 actor_q57=(SCREEN_UV-stage_center57)/stage_radius57;
 float actor_mask57=(1.-smoothstep(.20,1.,dot(actor_q57,actor_q57)));
 actor_mask57*=1.-smoothstep(.65,2.,abs(distance-stage_depth57));
 ALBEDO=mix(ALBEDO,source56*vec3(1.04,1.005,.94),actor_mask57*actor_stage57*.48);
 if(stage_strength>0.){
  float front=1.-smoothstep(max(1.,focus_distance-9.),max(3.,focus_distance-3.5),distance);
  float back=smoothstep(focus_distance+7.,focus_distance+23.,distance);
  vec3 staged=ALBEDO*mix(vec3(1.),vec3(.68,.78,.76),front);
  float lum=dot(staged,vec3(.2126,.7152,.0722));
  staged=mix(staged,vec3(lum)*vec3(.96,1.,1.02),back*.40);
  staged*=1.-back*.055;
  ALBEDO=mix(ALBEDO,staged,stage_strength);
 }
 float air57=smoothstep(focus_distance+7.,focus_distance+32.,distance)*haze_strength57;
 ALBEDO=mix(ALBEDO,haze_color57,air57);
 if(glow_strength>0.){
  float lum=dot(ALBEDO,vec3(.2126,.7152,.0722));
  ALBEDO+=local_glow(SCREEN_UV)*glow_strength*(1.-smoothstep(.65,.95,lum)*.6);
 }
 if(cone_strength58>0. && SCREEN_UV.x>=cone_bounds58.x && SCREEN_UV.x<=cone_bounds58.z && SCREEN_UV.y>=cone_bounds58.y && SCREEN_UV.y<=cone_bounds58.w){
  vec3 hit58=(INV_VIEW_MATRIX*vec4(point.xyz/point.w,1.)).xyz;
  float air58=cone_air58(INV_VIEW_MATRIX[3].xyz,hit58);
  ALBEDO=mix(ALBEDO,cone_tint58,air58);
 }
}
