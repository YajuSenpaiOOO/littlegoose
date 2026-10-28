shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
uniform float clock116=0.0;
uniform float phase116=0.0;
uniform bool bubble116=false;
float blob(vec2 p,vec2 c,vec2 size){ return 1.0-smoothstep(.55,1.0,length((p-c)/size)); }
void vertex(){
 float age=fract(clock116*.28+phase116);
 if(!bubble116){ VERTEX.y+=age*.65;VERTEX.x+=sin(age*5.0+phase116*9.0)*.07; }
}
void fragment(){
 float age=fract(clock116*(bubble116?.60:.28)+phase116);
 vec2 p=UV*2.0-1.0;
 float density;
 if(bubble116){
  float ring=abs(length(p)-(.15+age*.55));density=(1.0-smoothstep(.04,.10,ring))*sin(age*3.14159)*.42;
 }else{
  density=max(blob(p,vec2(-.25,.12),vec2(.67,.64)),max(blob(p,vec2(.23,.0),vec2(.64,.8)),blob(p,vec2(.0,-.37),vec2(.55,.57))));
  density*=sin(age*3.14159)*.20;
 }
 ALBEDO=vec3(.91,.94,.88);ALPHA=density;
}
