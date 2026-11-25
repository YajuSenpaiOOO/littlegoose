shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D stone_paint : source_color, filter_linear_mipmap, repeat_enable;
uniform bool stone_course = false;
uniform float cut_height = 20.0;
varying vec3 point;
void vertex(){point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
float patch(vec2 p,vec2 center,vec2 extent){
 vec2 d=(p-center)/extent;
 return 1.0-smoothstep(.67,1.0,dot(d,d));
}
void fragment(){
 if(point.y>cut_height) discard;
 vec3 normal=abs(normalize((INV_VIEW_MATRIX*vec4(NORMAL,0.0)).xyz));
 vec2 side=normal.x>normal.z ? point.zy : point.xy;
 vec3 grey=texture(paint,side*vec2(.24,.41)).rgb;
 vec3 masonry=texture(stone_paint,side*vec2(.32,.39)+vec2(.12,.23)).rgb;
 if(stone_course){
  vec2 stone_uv=normal.y>.6 ? point.xz : side;
  ALBEDO=texture(stone_paint,stone_uv*vec2(.35,.47)+vec2(.09,.17)).rgb*vec3(.73,.73,.65);
 }else{
  float skirting=(1.0-smoothstep(.56,1.33,point.y))*.25;
  float weather=texture(paint,side*.52+vec2(.31,.42)).r;
  float seam=patch(side,vec2(-2.12,.88),vec2(.49,.38))+patch(side,vec2(2.05,.84),vec2(.57,.30));
  seam+=patch(side,vec2(-5.55,.94),vec2(.37,.37))+patch(side,vec2(5.56,.82),vec2(.42,.30));
  float grain=texture(paint,side*1.75+vec2(.52,.18)).g;
  float reveal=smoothstep(.10,.82,seam*1.35+(grain-.61)*.85);
  vec3 lime=grey*mix(vec3(.78,.77,.65),vec3(1.02,.94,.81),smoothstep(.04,.66,weather));
  ALBEDO=mix(lime,masonry*vec3(.85,.79,.68),reveal*.80);
  ALBEDO=mix(ALBEDO,ALBEDO*vec3(.68,.73,.60),skirting);
 }
 ROUGHNESS=.98;
 SPECULAR=.08;
}
