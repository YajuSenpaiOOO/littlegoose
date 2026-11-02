// Terrain sampling copied from actor_shadow113; same floor triangles and supports.
uniform sampler2D terrain_heights113 : filter_nearest, repeat_disable;
uniform sampler2D terrain_tiles113 : filter_nearest, repeat_disable;
uniform sampler2D terrain_rects113 : filter_nearest, repeat_disable;
uniform vec2 terrain_origin113;
uniform vec4 bridge_rect113;
uniform vec2 bridge_ends113;
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
