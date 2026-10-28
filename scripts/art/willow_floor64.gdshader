shader_type spatial;
render_mode cull_disabled, depth_draw_never;
uniform sampler2D paint : source_color,filter_linear_mipmap,repeat_enable;
varying vec3 at64;
void vertex(){at64=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 vec2 q=(UV-.5)*2.;
 float edge=length(q)+sin(q.x*5.+q.y*4.)*.045+sin(q.y*7.-q.x*3.)*.035;
 float cover=1.-smoothstep(.64,1.,edge);
 vec3 ground=texture(paint,at64.xz/6.).rgb;
 float patch=.5+.5*sin(at64.x*.9+sin(at64.z*.7));
 vec3 tint=mix(vec3(.24,.20,.12),vec3(.23,.33,.14),patch);
 ALBEDO=ground*.18+tint*.82;
 ROUGHNESS=1.; SPECULAR=0.;
 ALPHA=cover*.88;
}
