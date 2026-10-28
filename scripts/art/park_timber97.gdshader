shader_type spatial;
uniform sampler2D timber97 : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D endgrain97 : source_color,filter_linear_mipmap,repeat_disable;
uniform int kind97=0;
uniform vec3 pigment97 : source_color=vec3(.85,.8,.67);
varying vec3 local97;
varying float cap97;
void vertex(){local97=VERTEX;cap97=abs(NORMAL.y);}
void fragment(){
 vec2 uv=kind97==1?UV*vec2(1.3,1.3):UV.yx*vec2(1.4,.6);
 vec3 col=texture(timber97,uv).rgb*pigment97;
 if(kind97==1){
  if(cap97>.7){
   col=texture(endgrain97,local97.xz/.94+vec2(.5)).rgb*vec3(.94,.91,.83);
  }
 }
 if(kind97==2){
  float twist=.5+.5*sin((UV.y*42.+UV.x*3.)*6.283185);
  col=mix(vec3(.38,.29,.16),vec3(.72,.59,.36),twist);
 }
 ALBEDO=col;ROUGHNESS=1.;SPECULAR=.03;
}
