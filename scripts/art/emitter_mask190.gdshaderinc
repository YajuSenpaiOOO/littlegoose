uniform int emitter_count190=0;
uniform vec4 emitter_rects190[20];
uniform float emitter_depths190[20];
float emitter_mask190(vec2 screen,float scene_depth){
 float result=0.;
 for(int i=0;i<20;i++){
  if(i>=emitter_count190)break;
  vec4 core=emitter_rects190[i];vec2 q=(screen-core.xy)/max(core.zw,vec2(.0001));
  float same_surface=1.-smoothstep(.12,.35,abs(scene_depth-emitter_depths190[i]));
  result=max(result,(1.-smoothstep(.65,1.,dot(q,q)))*same_surface);
 }
 return result;
}
