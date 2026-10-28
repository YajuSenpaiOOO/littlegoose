shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform float opacity87=.16;
void fragment(){
 vec2 p=(UV-.5)*2.;
 float mask=1.-smoothstep(.15,1.,dot(p,p));
 ALBEDO=vec3(.13,.18,.12);ALPHA=mask*opacity87;
}
