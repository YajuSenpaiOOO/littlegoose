shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform sampler2D silhouette : filter_linear_mipmap, repeat_disable;
uniform vec4 region=vec4(0.,0.,1.,1.);
uniform bool flipped=false;
uniform float opacity=.18;
uniform float softness68=1.4;
void fragment(){
 vec2 uv=vec2(flipped ? 1.-UV.x : UV.x,UV.y);
 vec2 at=region.xy+uv*region.zw;
 vec2 pixel=softness68/vec2(textureSize(silhouette,0));
 float a=texture(silhouette,at).a*.4;
 a+=texture(silhouette,clamp(at+vec2(pixel.x,0.),region.xy,region.xy+region.zw)).a*.15;
 a+=texture(silhouette,clamp(at-vec2(pixel.x,0.),region.xy,region.xy+region.zw)).a*.15;
 a+=texture(silhouette,clamp(at+vec2(0.,pixel.y),region.xy,region.xy+region.zw)).a*.15;
 a+=texture(silhouette,clamp(at-vec2(0.,pixel.y),region.xy,region.xy+region.zw)).a*.15;
 ALBEDO=vec3(.006,.009,.016);
 ALPHA=a*opacity;
}
