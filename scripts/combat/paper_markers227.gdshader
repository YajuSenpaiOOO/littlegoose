shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, skip_vertex_transform;
#include "res://scripts/combat/marker_terrain227.gdshaderinc"
varying vec4 ring_color;
void vertex(){
 vec3 point=VERTEX;
 point.xz*=max(.005,INSTANCE_CUSTOM.r-(1.-UV.y)*.025);
 point=(MODEL_MATRIX*vec4(point,1.)).xyz;
 point.y=terrain113(point.xz)+.035;
 VERTEX=(VIEW_MATRIX*vec4(point,1.)).xyz;
 ring_color=COLOR;
}
void fragment(){ALBEDO=ring_color.rgb;ALPHA=ring_color.a;}
