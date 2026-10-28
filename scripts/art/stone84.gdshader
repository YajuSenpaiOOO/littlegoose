shader_type spatial;
render_mode cull_disabled;
uniform sampler2D face_paint79 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform bool stair_top84=false;
uniform sampler2D top_paint84 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
varying vec3 at84;
varying vec3 n84;
void vertex(){at84=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;n84=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
float hash84(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec3 n=normalize(n84);
 vec2 face=abs(n.x)>.6?at84.zy:at84.xy;
 vec3 wall=texture(face_paint79,face/2.8).rgb;
 float grey=dot(wall,vec3(.3,.55,.15));
 wall=mix(vec3(grey),wall,.65)*.87;
 vec3 top=texture(top_paint84,at84.xz/2.8).rgb;
 float top_grey=dot(top,vec3(.3,.55,.15));
 top=mix(vec3(top_grey),top,.72)*vec3(.91,.94,.88);
 if(stair_top84){
  vec2 cell=vec2((10.-at84.x)/(5.2/9.),(at84.z+47.05)/.7666667);
  vec2 uv=fract(cell);
  float joint=1.-smoothstep(.015,.05,min(min(uv.x,1.-uv.x),min(uv.y,1.-uv.y)));
  top*=mix(.96,1.04,hash84(floor(cell)))*(1.-joint*.16);
 }
 ALBEDO=mix(wall,top,smoothstep(.45,.88,n.y));
 NORMAL=normalize((VIEW_MATRIX*vec4(normalize(n+vec3(0.,.35,0.)),0.)).xyz);
 ROUGHNESS=1.;SPECULAR=0.;
}
