shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, skip_vertex_transform;
uniform sampler2D silhouette : filter_nearest_mipmap, repeat_disable;
uniform vec4 region=vec4(0.,0.,1.,1.);
uniform bool flipped=false;
uniform float opacity=.28;
uniform float clip_tip158=0.;
uniform sampler2D terrain_heights113 : filter_nearest, repeat_disable;
uniform sampler2D terrain_tiles113 : filter_nearest, repeat_disable;
uniform sampler2D terrain_rects113 : filter_nearest, repeat_disable;
uniform vec2 terrain_origin113;
uniform vec4 bridge_rect113;
uniform vec2 bridge_ends113;
uniform mat4 visual_world113;
uniform vec4 sprite_geometry113;
uniform float pixel_size113;
uniform vec3 light_direction113;
uniform vec2 actor_xz113;
uniform vec2 support_center113;
uniform int support_count113;
uniform vec2 support_points113[64];
uniform vec4 support_spans113[8];
uniform vec4 support_bounds113[8];
float support113(vec2 at,float base_height) {
 if (dot(at-support_center113,at-support_center113)>=64.) return base_height;
 for (int i=0;i<support_count113;i++) {
  vec4 bounds=support_bounds113[i];
  if (any(lessThan(at,bounds.xy)) || any(greaterThan(at,bounds.zw))) continue;
  vec4 span=support_spans113[i];int start=int(span.x);int count=int(span.y);bool inside=false;
  vec2 before=support_points113[start+count-1];
  for (int j=0;j<count;j++) {
   vec2 point=support_points113[start+j];
   if ((point.y>at.y)!=(before.y>at.y)) {
    float crossing=(before.x-point.x)*(at.y-point.y)/(before.y-point.y)+point.x;
    if (at.x<crossing) inside=!inside;
   }
   before=point;
  }
  if (inside) base_height=max(base_height,span.z);
 }
 return base_height;
}
float terrain113(vec2 at) {
 if (all(greaterThanEqual(at,bridge_rect113.xy)) && all(lessThan(at,bridge_rect113.xy+bridge_rect113.zw))) {
  return support113(at,mix(mix(bridge_ends113.x,.24,smoothstep(0.,1.3,at.x-bridge_rect113.x)),bridge_ends113.y,smoothstep(0.,1.3,at.x-bridge_rect113.x-bridge_rect113.z+1.3)));
 }
 ivec2 key=clamp(ivec2(floor((at-terrain_origin113)/16.)),ivec2(0),textureSize(terrain_tiles113,0)-ivec2(1));
 vec4 tile=texelFetch(terrain_tiles113,key,0);vec4 rect=texelFetch(terrain_rects113,key,0);
 vec2 uv=(at-rect.xy)/rect.zw*(tile.z-1.);ivec2 cell=clamp(ivec2(floor(uv)),ivec2(0),ivec2(int(tile.z)-2));vec2 f=uv-vec2(cell);
 ivec2 base=ivec2(tile.xy)+cell;
 float a=texelFetch(terrain_heights113,base,0).r;
 float b=texelFetch(terrain_heights113,base+ivec2(1,0),0).r;
 float c=texelFetch(terrain_heights113,base+ivec2(1,1),0).r;
 float d=texelFetch(terrain_heights113,base+ivec2(0,1),0).r;
 return support113(at,f.x>=f.y ? a+(b-a)*f.x+(c-b)*f.y : a+(c-d)*f.x+(d-a)*f.y);
}
#include "res://scripts/combat/balloon_soft154.gdshaderinc"
void vertex() {
 vec2 pixels=UV*sprite_geometry113.xy;
 vec3 local=vec3((pixels.x-sprite_geometry113.x*.5+sprite_geometry113.z)*pixel_size113,(sprite_geometry113.y*.5-pixels.y+sprite_geometry113.w)*pixel_size113,0.);
 local=balloon_warp154(local);
 vec3 point=(visual_world113*vec4(local,1.)).xyz;
 vec3 projected=point+light_direction113*((terrain113(actor_xz113)-point.y)/light_direction113.y);
 for (int i=0;i<2;i++) projected=point+light_direction113*((terrain113(projected.xz)-point.y)/light_direction113.y);
 projected.y=terrain113(projected.xz)+.022;
 VERTEX=(VIEW_MATRIX*vec4(projected,1.)).xyz;
}
void fragment() {
 vec2 uv=vec2(flipped ? 1.-UV.x : UV.x,UV.y);
 if(uv.y<clip_tip158){discard;}
 ALBEDO=vec3(.10,.14,.10);ALPHA=texture(silhouette,region.xy+uv*region.zw).a*opacity;
}


