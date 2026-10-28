shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
void fragment(){vec2 p=(UV-.5)*2.;ALBEDO=vec3(.09,.13,.085);ALPHA=(1.-smoothstep(.38,1.,dot(p,p)))*COLOR.a;}
