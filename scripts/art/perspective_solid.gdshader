shader_type spatial;
render_mode cull_disabled;
uniform vec4 paint : source_color=vec4(1.);
uniform float fade=1.;
uniform int surface_kind=0;
varying vec3 world;
varying vec3 surface_normal;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;surface_normal=normalize((MODEL_MATRIX*vec4(NORMAL,0.)).xyz);}
void fragment(){
 if(hash(floor(FRAGCOORD.xy))>fade) discard;
 vec3 col=paint.rgb;
 vec2 p=vec2(abs(surface_normal.x)>.5 ? world.z : world.x,world.y);
 float grain=(hash(floor(p*55.))-.5)*.05;
 if(surface_kind==1){
  col*=.96+grain;
  if(world.y<.9){
   vec2 cell=vec2(p.x*3.2+floor(p.y*5.)*.5,p.y*5.);
   vec2 edge=min(fract(cell),1.-fract(cell));
   float stone=smoothstep(.025,.075,min(edge.x,edge.y));
   vec3 rock=mix(vec3(.18,.18,.15),vec3(.35,.34,.28),hash(floor(cell)));
   col=mix(vec3(.10,.105,.085),rock,stone);
  }
 }
 if(surface_kind==2){
  if(abs(surface_normal.y)>.2){
   vec2 cell=vec2(world.z*2.6+floor(world.x*4.8)*.5,world.x*4.8);
   vec2 edge=fract(cell);
   float rim=smoothstep(.02,.10,min(edge.x,1.-edge.x))*smoothstep(.02,.16,edge.y);
   col*=mix(.48,1.03,rim)*mix(.85,1.12,hash(floor(cell)));
  }else{col=vec3(.55,.40,.24)*(1.+grain);}
 }
 if(surface_kind==3){
  float plank=fract(p.x*7.);
  col*=mix(.55,1.,smoothstep(.025,.09,min(plank,1.-plank)));
  col*=.94+grain+sin(p.x*47.+sin(p.y*4.)*.6)*.055;
 }
 ALBEDO=col;
 ROUGHNESS=1.;
 SPECULAR=0.;
}
