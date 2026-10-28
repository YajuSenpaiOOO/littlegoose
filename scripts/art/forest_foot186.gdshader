shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform bool strip=false;
void fragment(){
 float a=strip ? (1.-smoothstep(.0,1.,UV.y)) : (1.-smoothstep(.15,1.,length((UV-.5)*2.)));
 ALBEDO=vec3(.07,.09,.12);ALPHA=a*.38;
}
