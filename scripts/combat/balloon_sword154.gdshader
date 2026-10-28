shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled, shadows_disabled;
uniform sampler2D art153 : source_color, filter_nearest_mipmap;
uniform float fade154=1.;
#include "res://scripts/combat/balloon_soft154.gdshaderinc"
void vertex(){ VERTEX=balloon_warp154(VERTEX); }
void fragment(){
 vec4 color=texture(art153,UV);
 if(color.a<.86){discard;}
 ALBEDO=color.rgb;ROUGHNESS=1.;SPECULAR=0.;ALPHA=color.a*fade154;
}
