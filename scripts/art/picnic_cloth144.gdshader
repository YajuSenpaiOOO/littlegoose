shader_type spatial;
render_mode cull_disabled;
uniform float clock=0.;
varying vec2 cloth_uv;
void vertex(){
 cloth_uv=UV;
 // One free corner; the stone-weighted corners and all roots stay fixed.
 float free_tip=smoothstep(.65,1.,UV.x)*(1.-smoothstep(0.,.23,UV.y));
 VERTEX.y+=free_tip*(.012+.010*sin(clock*3.4+UV.x*7.));
}
void fragment(){
 vec2 checks=floor(cloth_uv*vec2(10.,8.));
 float vertical=mod(checks.x,2.);float horizontal=mod(checks.y,2.);
 vec3 cream=vec3(.90,.81,.66);vec3 red=vec3(.76,.43,.36);
 vec3 color=mix(cream,red,(vertical+horizontal)*.23+vertical*horizontal*.14);
 float threads=sin(cloth_uv.x*610.)*sin(cloth_uv.y*480.);
 color*=.98+.018*threads+.025*sin(cloth_uv.y*32.+sin(cloth_uv.x*17.));
 float border=min(min(cloth_uv.x,1.-cloth_uv.x),min(cloth_uv.y,1.-cloth_uv.y));
 color*=mix(.87,1.,smoothstep(.004,.02,border));
 if(border<.004 && fract(sin(dot(floor(cloth_uv*vec2(170.,130.)),vec2(31.7,19.3)))*437.5)>.72) discard;
 ALBEDO=color;ROUGHNESS=1.;SPECULAR=0.;
}
