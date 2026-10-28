shader_type spatial;
varying vec3 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 float board=floor(world.x/.30);
 float grain=sin(world.z*95.+sin(world.x*9.)*3.)*.018;
 float seam=1.-smoothstep(.014,.028,min(fract(world.x/.30),1.-fract(world.x/.30)));
 ALBEDO=vec3(.36,.23,.12)+grain+sin(board*17.)*.025-seam*.075;
 ROUGHNESS=1.; SPECULAR=0.;
}
