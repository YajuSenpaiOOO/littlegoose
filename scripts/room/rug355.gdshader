shader_type spatial;
render_mode cull_disabled;
void fragment(){
 vec2 p=UV;float edge=min(min(p.x,1.-p.x),min(p.y,1.-p.y));
 vec3 cream=vec3(.80,.70,.52);vec3 sage=vec3(.29,.38,.24);
 vec3 color=cream;
 if(edge<.025)color=vec3(.61,.46,.31);
 else if(edge<.045 || (edge>.085 && edge<.10))color=sage;
 float spots=sin(p.x*100.)*sin(p.y*80.);
 if(edge>.045 && edge<.085 && spots>.1)color=sage;
 float weave=sin(p.x*1100.)*sin(p.y*750.)*.025;
 ALBEDO=color+weave;ROUGHNESS=1.;
}
