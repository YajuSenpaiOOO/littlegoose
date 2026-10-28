shader_type spatial;
varying vec3 world;
float noise(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 vec2 p=vec2(world.x+world.z*.37,world.y)*vec2(2.6,7.);
 p.x+=mod(floor(p.y),2.)*.5;
 vec2 cell=floor(p);
 vec2 edge=min(fract(p),1.-fract(p));
 float mortar=1.-smoothstep(.025,.095,min(edge.x,edge.y));
 vec3 color=mix(vec3(.30,.34,.36),vec3(.43,.44,.40),noise(cell));
 color+=vec3(noise(floor(world.xz*24.))-.5)*.035;
 ALBEDO=mix(color,vec3(.22,.24,.22),mortar*.65);
 ROUGHNESS=1.; SPECULAR=0.;
}
