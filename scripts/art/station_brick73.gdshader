shader_type spatial;
render_mode cull_disabled;
varying vec3 position73;
varying vec3 normal73;
float hash73(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void vertex(){position73=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;normal73=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec2 p=abs(normal73.y)>.6?position73.xz:(abs(normal73.z)>.6?position73.xy:position73.zy);
 vec2 cell=p/vec2(.48,.24);cell.x+=mod(floor(cell.y),2.)*.5;
 vec2 uv=fract(cell);
 float mortar=1.-smoothstep(.02,.045,min(min(uv.x,1.-uv.x),min(uv.y,1.-uv.y)));
 vec3 brick=vec3(.48,.42,.34)*mix(.91,1.07,hash73(floor(cell)));
 ALBEDO=mix(brick,vec3(.30,.30,.26),mortar*.65);
 ROUGHNESS=1.;SPECULAR=0.;
}
