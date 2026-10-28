shader_type spatial;
varying vec3 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec3 pixel=floor(world*58.);
 float grain=sin(pixel.y*.75+sin(pixel.x*.26+pixel.z*.29)*2.);
 float fleck=hash(pixel.xy+pixel.z);
 vec3 wood=vec3(.46,.30,.15)+grain*.025+(fleck-.5)*.025;
 float edge=min(min(UV.x,1.-UV.x),min(UV.y,1.-UV.y));
 wood+=(1.-smoothstep(0.,.045,edge))*.035;
 ALBEDO=wood;
 ROUGHNESS=1.; SPECULAR=0.;
}
