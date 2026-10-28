shader_type spatial;
varying vec3 world;
varying vec2 local;
uniform float seed=0.;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;local=UV;}
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 float noise=hash(floor(world.xz*52.)+seed);
 vec3 stone=mix(vec3(.40,.405,.34),vec3(.53,.52,.435),noise*.5+.2);
 float edge=smoothstep(.1,.95,length(local));
 stone*=1.-edge*.12;
 ALBEDO=stone;
 ROUGHNESS=1.; SPECULAR=0.;
}
