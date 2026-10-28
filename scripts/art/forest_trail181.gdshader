shader_type spatial;
render_mode cull_disabled,depth_draw_never;
uniform sampler2D soil:source_color,filter_linear_mipmap,repeat_enable;
varying vec3 at;
void vertex(){at=VERTEX;}
void fragment(){
 vec3 paint=texture(soil,at.xz*.36).rgb;
 float edge=1.-smoothstep(.58,.98,abs(UV.x*2.-1.));
 float uneven=.85+.15*sin(at.x*8.+sin(at.z*5.));
 ALBEDO=mix(paint,vec3(.29,.25,.23),.3)*vec3(.88,.90,1.);ROUGHNESS=1.;SPECULAR=0.;ALPHA=edge*uneven*.83;
}
