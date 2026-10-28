shader_type spatial;
uniform bool detailed_path=true;
float grain(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float soft_noise(vec2 p){
 vec2 cell=floor(p),f=fract(p); f=f*f*(3.-2.*f);
 return mix(mix(grain(cell),grain(cell+vec2(1,0)),f.x),mix(grain(cell+vec2(0,1)),grain(cell+vec2(1)),f.x),f.y);
}
uniform sampler2D paint : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool albedo_view=false;
uniform bool flat_ground=false;
uniform vec3 flat_color : source_color=vec3(.38,.54,.28);
uniform bool forest_depth=false;
uniform sampler2D forest_mask : filter_linear,repeat_disable;
uniform bool forest_layout=false;
uniform bool route_layout=false;
uniform int route_count=0;
uniform vec4 route_segments[32];
varying vec3 world;
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 vec2 tile=world.xz/6.;
 vec2 mirrored=1.-abs(fract(tile*.5)*2.-1.);
 vec3 col=textureGrad(paint,mirrored,dFdx(tile),dFdy(tile)).rgb;
 if(flat_ground) col=flat_color;
 float edge=abs(world.x-sin(world.z*.25)*.9)-.63;
 float path=1.-smoothstep(-.1,.13,edge);
 if(forest_layout){
  vec2 a=vec2(-.4,-1.8),b=vec2(-4.7,-4.8);
  vec2 v=b-a;
  float along=clamp(dot(world.xz-a,v)/dot(v,v),0.,1.);
  float branch=length(world.xz-a-v*along)-.66;
  float doorstep=length((world.xz-vec2(-4.7,-4.8))/vec2(1.8,.9))-.8;
  path=max(path,max(1.-smoothstep(-.1,.13,branch),1.-smoothstep(-.1,.15,doorstep)));
 }
 if(route_layout){
  float distance_to_path=1000.;
  for(int i=0;i<32;i++){
   if(i>=route_count) break;
   vec2 a=route_segments[i].xy,b=route_segments[i].zw;
   vec2 v=b-a;
   float t=clamp(dot(world.xz-a,v)/max(dot(v,v),.0001),0.,1.);
   distance_to_path=min(distance_to_path,length(world.xz-a-v*t));
  }
  path=1.-smoothstep(.64,.94,distance_to_path);
  if(detailed_path){
   vec2 pixel=floor(world.xz/.035)*.035;
   float ragged=(soft_noise(pixel*3.7)-.5)*.24+(grain(floor(pixel/.07))-.5)*.075;
   float boundary=distance_to_path+ragged;
   path=1.-smoothstep(.755,.775,boundary);
   float flecks=grain(floor(pixel/.055));
   float soil_grain=(flecks-.5)*.045+(soft_noise(pixel*8.)-.5)*.035;
   vec3 soil=vec3(.46,.345,.215)+vec3(soil_grain);
   float compact=1.-smoothstep(.12,.65,distance_to_path);
   soil+=vec3(.025,.022,.014)*compact;
   float pebble=step(.978,flecks)*(.35+.65*grain(floor(pixel/.13)));
   soil=mix(soil,vec3(.53,.46,.33),pebble*.38);
   float turf_edge=(1.-smoothstep(.02,.15,abs(boundary-.77)))*(1.-path);
   col*=1.-turf_edge*.10;
   col=mix(col,soil,path);
  }
 }
 if(!detailed_path || !route_layout) col=mix(col,vec3(.34,.25,.15),path*.85);
 if(forest_depth){
  vec3 shade=texture(forest_mask,(world.xz+vec2(32.))/64.).rgb;
  col*=1.-shade.r*.24-shade.g*.20-shade.b*.18;
 }
 ALBEDO=albedo_view ? vec3(0.) : col;
 EMISSION=albedo_view ? col : vec3(0.);
 ROUGHNESS=1.; SPECULAR=0.;
}
