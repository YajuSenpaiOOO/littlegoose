shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform float strength=0.;
uniform float unfold=0.;
void fragment() {
 float r=length(UV)/max(.02,unfold);
 float a=atan(UV.y,UV.x);
 float irregular=.025*sin(a*7.)+.018*sin(a*13.+.6);
 float soft=1.-smoothstep(.69,1.+irregular,r);
 // Sparse ivory fibres, rather than a continuous luminous skill circle.
 float fibres=exp(-pow((r-(.90+irregular))*55.,2.))*smoothstep(.35,.83,sin(a*19.+r*12.));
 ALBEDO=mix(vec3(1.,.70,.67),vec3(1.,.91,.73),fibres);
 ALPHA=(soft*.11+fibres*.22)*strength*COLOR.a;
}
