shader_type spatial;
varying vec3 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 pixel=floor(world.xz*42.);
 float grain=hash(pixel);
 float furrow=.5+.5*cos(world.x*21.+sin(world.z*1.7)*.10);
 vec3 soil=mix(vec3(.24,.16,.085),vec3(.34,.235,.13),furrow*.65+grain*.22);
 soil+=step(.985,grain)*.07;
 ALBEDO=soil;
 ROUGHNESS=1.; SPECULAR=0.;
}
