shader_type spatial;
uniform sampler2D paint : source_color, filter_linear_mipmap, repeat_enable;
uniform float seed=0.;
varying vec3 world;
varying vec2 local;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;local=UV;}
void fragment(){
 vec2 offset=fract(vec2(seed*.371,seed*.617));
 vec3 stone=texture(paint,world.xz*.85+offset).rgb;
 stone=mix(stone,vec3(dot(stone,vec3(.299,.587,.114))),.15);
 float edge=smoothstep(.1,.95,length(local));
 ALBEDO=stone*(1.-edge*.14)*1.06;
 ROUGHNESS=1.; SPECULAR=0.;
}
