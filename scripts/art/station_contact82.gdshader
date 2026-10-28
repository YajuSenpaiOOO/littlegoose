shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform float opacity82=.2;
void fragment(){
 vec2 edge=abs(UV-.5)*2.;
 float alpha=1.-smoothstep(.35,1.,max(edge.x,edge.y));
 ALBEDO=vec3(.08,.10,.09);ALPHA=alpha*opacity82;
}
