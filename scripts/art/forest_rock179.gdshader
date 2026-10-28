shader_type spatial;
varying vec3 local;
void vertex(){local=VERTEX;}
float noise(vec3 p){return fract(sin(dot(floor(p),vec3(127.1,311.7,74.7)))*43758.5453);}
void fragment(){
 float n=.5+.5*sin(local.x*1.7+local.z*1.1+sin(local.y*3.));float seam=smoothstep(.8,.98,.5+.5*sin(local.y*18.+sin(local.x*2.+local.z*1.2)));
 vec3 rock=mix(vec3(.24,.28,.34),vec3(.40,.43,.48),n);
 float moss=smoothstep(.65,.9,noise(local*.9))*smoothstep(.0,.7,NORMAL.y);
 ALBEDO=mix(rock*(1.-seam*.22),vec3(.23,.34,.29),moss*.65);ROUGHNESS=1.;SPECULAR=0.;
}
