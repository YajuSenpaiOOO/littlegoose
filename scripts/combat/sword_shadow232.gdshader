shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never,skip_vertex_transform;
uniform sampler2D art232:filter_nearest_mipmap,repeat_disable;
uniform vec2 tip232=vec2(0.,.525);
uniform bool pad232=false;
uniform vec3 light232=vec3(.4,-1.,.4);
uniform float opacity232=.24;
varying vec4 shape232;
varying float clip232;
#include "res://scripts/combat/marker_terrain227.gdshaderinc"
void vertex(){
 shape232=INSTANCE_CUSTOM;clip232=COLOR.r;
 if(!pad232){
  float t=clamp((tip232.y-VERTEX.y)/1.05,0.,1.);
  VERTEX.x=tip232.x+(VERTEX.x-tip232.x)*(1.+shape232.y*.32);
  VERTEX.y=tip232.y+(VERTEX.y-tip232.y)*(1.-shape232.y-shape232.z*.3);
  VERTEX.x+=(shape232.x+shape232.z*.23)*t*t;
 }
 vec3 point=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;
 vec3 light=light232;light.y=min(light.y,-.05);
 vec3 projected=point+light*((terrain113(MODEL_MATRIX[3].xz)-point.y)/light.y);
 for(int i=0;i<2;i++)projected=point+light*((terrain113(projected.xz)-point.y)/light.y);
 projected.y=terrain113(projected.xz)+.022;
 VERTEX=(VIEW_MATRIX*vec4(projected,1.)).xyz;
}
void fragment(){
 if(UV.y<clip232)discard;
 ALBEDO=vec3(.10,.14,.10);ALPHA=texture(art232,UV).a*opacity232*shape232.w;
}
