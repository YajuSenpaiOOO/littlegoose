shader_type spatial;
render_mode cull_disabled, shadows_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap;
uniform float fade=1.;
uniform float alpha_threshold=.5;
uniform float root_cut_y=1.;
uniform vec3 tint : source_color=vec3(1.);
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
uniform float wind_clock=0.;
uniform float wind_strength=0.;
varying vec2 crown_wave;
void vertex(){
 vec3 origin=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 float phase=origin.x*.71+origin.z*.43;
 crown_wave=vec2(sin(wind_clock*.72+phase)+.28*sin(wind_clock*1.41+phase+UV.y*5.),sin(wind_clock*.91+phase+UV.x*4.));
}
vec2 canopy_uv(vec2 uv){
 if(wind_strength<=0.) return uv;
 float crown=smoothstep(.30,.70,1.-uv.y);
 uv+=crown_wave*vec2(.0045,.0009)*crown*wind_strength;
 return uv;
}
void fragment(){
 vec4 tex=texture(paint,canopy_uv(UV));
 if(UV.y>root_cut_y) discard;
 if(tex.a<alpha_threshold) discard;
 if(fade<.999 && hash(floor(FRAGCOORD.xy))>fade) discard;
 // Painted volume supplies the local form; receive the same scene lighting as ground.
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=tex.rgb*tint;
 ROUGHNESS=1.; SPECULAR=0.;
}
