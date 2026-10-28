shader_type spatial;
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
 }
 col=mix(col,vec3(.34,.25,.15),path*.85);
 if(forest_depth){
  vec3 shade=texture(forest_mask,(world.xz+vec2(32.))/64.).rgb;
  col*=1.-shade.r*.24-shade.g*.20-shade.b*.18;
 }
 ALBEDO=albedo_view ? vec3(0.) : col;
 EMISSION=albedo_view ? col : vec3(0.);
 ROUGHNESS=1.; SPECULAR=0.;
}
