shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D paint:source_color,filter_linear_mipmap,repeat_disable;
uniform bool show_paint=true;
uniform vec3 plain_color:source_color=vec3(.8,.65,.4);
uniform vec3 room_tint=vec3(.85);
varying vec3 world_normal;
void vertex(){world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec3 color=show_paint?texture(paint,UV).rgb:plain_color;
 // Painted value design is the base. A bounded world-space hemisphere hints at volume.
 float form=.88+.12*smoothstep(-.55,.80,dot(normalize(world_normal),normalize(vec3(-.35,.75,.65))));
 ALBEDO=color*room_tint*form;
}
