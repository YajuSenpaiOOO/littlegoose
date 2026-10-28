shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never,fog_disabled;
uniform float strength57=0.;
varying vec4 firefly;
void vertex(){firefly=INSTANCE_CUSTOM;}
void fragment(){
 float radius=length((UV-.5)*2.);
 float core=1.-smoothstep(.035,.18,radius);
 float halo=exp(-radius*radius*7.)*(1.-smoothstep(.65,1.,radius));
 ALBEDO=mix(vec3(.93,.76,.24),vec3(1.,.97,.65),core);
 ALPHA=max(core,halo*.24)*firefly.a*strength57;
}
