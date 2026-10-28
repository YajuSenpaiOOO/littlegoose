shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
varying vec4 mote_color;
void vertex(){mote_color=INSTANCE_CUSTOM;}
void fragment(){
 float r=length((UV-.5)*2.);
 float soft=1.-smoothstep(.08,.96,r);
 if(soft<.015 || mote_color.a<.003) discard;
 ALBEDO=mote_color.rgb;
 ALPHA=soft*soft*mote_color.a;
 ROUGHNESS=1.; SPECULAR=0.;
}
