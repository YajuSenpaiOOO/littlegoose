shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D paint:source_color,filter_linear_mipmap,repeat_enable;
uniform bool show_paint=true;
uniform vec3 plain_color:source_color=vec3(.9,.83,.7);
uniform vec3 room_tint=vec3(.8);
varying vec3 world_normal;
varying vec3 gathered_value;
void vertex(){world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);gathered_value=COLOR.rgb;}
void fragment(){
 vec3 color=show_paint?texture(paint,UV).rgb:plain_color;
 float form=.84+.16*smoothstep(-.55,.80,dot(normalize(world_normal),normalize(vec3(-.35,.75,.65))));
 ALBEDO=color*room_tint*form*gathered_value;
}
