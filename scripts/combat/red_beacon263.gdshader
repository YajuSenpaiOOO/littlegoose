shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform float pulse263=0.0;
void fragment(){
 float radius=length((UV-vec2(0.5))*2.0);
 float alpha=(1.0-smoothstep(0.0,1.0,radius))*(0.55+0.4*pulse263);
 ALBEDO=mix(vec3(1.0,0.10,0.18),vec3(1.0,0.77,0.61),1.0-smoothstep(0.0,0.28,radius));
 ALPHA=alpha;
}
