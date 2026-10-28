shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;
uniform float phase=0.;
uniform float clock=0.;
uniform float strength=.24;
void fragment(){
 float side=pow(max(0.,1.-abs(UV.x*2.-1.)),2.2);
 float ends=smoothstep(0.,.18,UV.y)*(1.-smoothstep(.65,1.,UV.y));
 float ripple=.9+.1*sin(UV.y*15.+clock*.24+phase);
 ALBEDO=vec3(1.,.89,.59);
 ALPHA=side*ends*ripple*strength;
}
