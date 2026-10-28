shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform float strength=0.;
uniform float unfold=0.;
void fragment() {
 float r=length(UV)/max(.02,unfold);
 float soft=1.-smoothstep(.72,1.,r);
 float edge=exp(-pow((r-.965)*70.,2.));
 ALBEDO=mix(vec3(.98,.58,.58),vec3(1.,.82,.54),edge);
 ALPHA=(soft*.16+edge*.48)*strength*COLOR.a;
}
