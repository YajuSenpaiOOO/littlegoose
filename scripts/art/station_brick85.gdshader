shader_type spatial;
render_mode cull_disabled;
uniform vec4 front_cut80;
uniform bool cut_enabled85=false;
varying vec3 position73;
varying vec3 normal73;
float hash73(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void vertex(){position73=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;normal73=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 // Explicit outward normal survives back-face lighting on double-sided walls.
 NORMAL=normalize((VIEW_MATRIX*vec4(normal73,0.)).xyz);
 if(cut_enabled85 && position73.x>front_cut80.x && position73.z>front_cut80.y && position73.x<front_cut80.z && position73.z<front_cut80.w) discard;
 vec2 p=abs(normal73.y)>.6?position73.xz:(abs(normal73.z)>.6?position73.xy:position73.zy);
 vec2 cell=p/vec2(.48,.24);cell.x+=mod(floor(cell.y),2.)*.5;
 vec2 uv=fract(cell);
 float mortar=1.-smoothstep(.02,.045,min(min(uv.x,1.-uv.x),min(uv.y,1.-uv.y)));
 vec3 brick=vec3(.48,.42,.34)*mix(.91,1.07,hash73(floor(cell)));
 ALBEDO=mix(brick,vec3(.30,.30,.26),mortar*.65);
 ROUGHNESS=1.;SPECULAR=0.;
}
