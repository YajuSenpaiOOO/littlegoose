shader_type spatial;
render_mode cull_disabled;
varying vec3 at75;
varying vec3 n75;
float hash75(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void vertex(){at75=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;n75=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec2 p=abs(n75.y)>.6?at75.xz:(abs(n75.z)>.6?at75.xy:at75.zy);
 vec2 c=p/vec2(.65,.34);c.x+=mod(floor(c.y),2.)*.5;
 vec2 uv=fract(c);float seams=1.-smoothstep(.025,.07,min(min(uv.x,1.-uv.x),min(uv.y,1.-uv.y)));
 vec3 stone=vec3(.43,.45,.36)*mix(.9,1.08,hash75(floor(c)));
 float moss=(1.-smoothstep(.2,.75,fract(c.y)))*smoothstep(.38,.8,hash75(floor(c)+4.));
 ALBEDO=mix(mix(stone,vec3(.25,.29,.22),seams*.65),vec3(.25,.35,.19),moss*.5);
 ROUGHNESS=1.;SPECULAR=0.;
}
