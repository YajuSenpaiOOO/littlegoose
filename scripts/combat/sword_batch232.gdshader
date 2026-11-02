shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled, shadows_disabled;
uniform sampler2D art232:source_color,filter_nearest_mipmap,repeat_disable;
uniform vec2 tip232=vec2(0.,.525);
uniform bool pad232=false;
varying vec4 shape232;
varying float clip232;
varying float proxy232;
varying vec3 contact232;
#include "res://scripts/combat/world_effect_grade159.gdshaderinc"
void vertex(){
 shape232=INSTANCE_CUSTOM;clip232=COLOR.r;proxy232=COLOR.g;
 contact232=(MODEL_MATRIX*vec4(tip232,0.,1.)).xyz;
 if(!pad232){
  float t=clamp((tip232.y-VERTEX.y)/1.05,0.,1.);
  VERTEX.x=tip232.x+(VERTEX.x-tip232.x)*(1.+shape232.y*.32);
  VERTEX.y=tip232.y+(VERTEX.y-tip232.y)*(1.-shape232.y-shape232.z*.3);
  VERTEX.x+=(shape232.x+shape232.z*.23)*t*t;
 }
}
void fragment(){
 vec4 tex=texture(art232,UV);
 if(tex.a<(pad232?.01:.86)||UV.y<clip232)discard;
 ALBEDO=grade_world_effect159(tex.rgb);ALPHA=tex.a*shape232.w;
 DEPTH=FRAGCOORD.z;
 if(proxy232>.5){
  vec3 camera=INV_VIEW_MATRIX[3].xyz;
  vec3 normal=normalize(vec3(INV_VIEW_MATRIX[2].x,0.,INV_VIEW_MATRIX[2].z));
  vec3 world=(INV_VIEW_MATRIX*vec4(VERTEX,1.)).xyz;
  vec3 ray=world-camera;
  float divisor=dot(ray,normal);
  float t=abs(divisor)>.00001?dot(contact232-camera,normal)/divisor:1.;
  vec4 clip=PROJECTION_MATRIX*VIEW_MATRIX*vec4(camera+ray*max(t,.001),1.);
  DEPTH=clip.z/clip.w*.5+.5;
 }
}
