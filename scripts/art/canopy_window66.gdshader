shader_type spatial;
render_mode cull_disabled, shadows_disabled;
uniform sampler2D paint : source_color, filter_linear_mipmap;
uniform float fade=1.;
uniform float alpha_threshold=.5;
uniform float root_cut_y=1.;
uniform vec3 tint : source_color=vec3(1.);
uniform float wind_clock=0.;
uniform float wind_strength=0.;
uniform vec2 window_center66=vec2(-2.);
uniform vec2 window_radius66=vec2(.1);
uniform float window_strength66=0.;
varying vec2 crown_wave;
void vertex(){
 vec3 origin=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 float phase=origin.x*.71+origin.z*.43;
 crown_wave=vec2(sin(wind_clock*.72+phase)+.28*sin(wind_clock*1.41+phase+UV.y*5.),sin(wind_clock*.91+phase+UV.x*4.));
}
vec2 canopy_uv(vec2 uv){
 if(wind_strength<=0.) return uv;
 float crown=smoothstep(.30,.70,1.-uv.y);
 return uv+crown_wave*vec2(.0045,.0009)*crown*wind_strength;
}
float ordered2(vec2 p){
 return mix(mix(0.,2.,step(1.,p.x)),mix(3.,1.,step(1.,p.x)),step(1.,p.y));
}
float coverage(vec2 uv){
 // Fixed in the painted texture: no frame hash, scrolling noise or screen crawl.
 vec2 cell=floor(uv*vec2(textureSize(paint,0)));
 return (ordered2(mod(cell,2.))*4.+ordered2(floor(mod(cell,4.)*.5))+.5)/16.;
}
void fragment(){
 vec4 tex=texture(paint,canopy_uv(UV));
 if(UV.y>root_cut_y || tex.a<alpha_threshold) discard;
 float radius=length((SCREEN_UV-window_center66)/max(window_radius66,vec2(.001)));
 float opacity=smoothstep(.90,1.,radius/max(window_strength66,.001));
 if(opacity<1. && coverage(UV)>opacity) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=tex.rgb*tint;
 ROUGHNESS=1.; SPECULAR=0.;
}
