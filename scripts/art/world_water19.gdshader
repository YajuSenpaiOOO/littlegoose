shader_type spatial;
render_mode cull_disabled;
uniform float clock=0.;
void fragment(){
 vec2 p=UV;
 float ripple=sin(p.x*8.+p.y*5.+clock*.65)*sin(p.x*3.-p.y*8.-clock*.45);
 float fleck=pow(max(0.,ripple),10.);
 ALBEDO=mix(vec3(.075,.17,.23),vec3(.12,.27,.33),ripple*.22+.45)+vec3(.10,.12,.10)*fleck*.35;
 ROUGHNESS=.68; SPECULAR=.15;
}
