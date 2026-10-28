shader_type spatial;
uniform bool sample_enabled76=true;
uniform vec4 ground_patches79[8];
uniform float patch_kinds79[8];
uniform bool ground_variety79=true;
uniform sampler2D rock_paint78 : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform int road_end_count77=0;
uniform vec4 road_endings77[8];
uniform vec2 sample_center76=vec2(-31.,-32.);
uniform vec2 sample_extent76=vec2(13.,11.);
uniform float rail_line_z72=-91.4;
uniform vec2 rail_extent72=vec2(-29.,65.175);
varying vec3 normal76;
uniform bool detailed_path=true;
uniform bool road_relief=true;
uniform bool surface_spots=true;
uniform bool footprints_enabled=true;
uniform float footprint_clock=0.;
uniform float footprint_lifetime=4.5;
uniform vec4 footprints[48];
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
uniform vec4 forest_mask_bounds=vec4(-32.,-32.,64.,64.);
uniform bool route_layout=false;
uniform int route_count=0;
uniform vec4 route_segments[64];
uniform float route_widths[64];
varying vec3 world;
void vertex(){normal76=normalize(MODEL_NORMAL_MATRIX*NORMAL);world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 vec2 tile=world.xz/6.;
 vec2 mirrored=1.-abs(fract(tile*.5)*2.-1.);
 vec3 col=textureGrad(paint,mirrored,dFdx(tile),dFdy(tile)).rgb;
  if(flat_ground) col=flat_color;
 if(ground_variety79){
  float best79=0.;float kind79=0.;
  for(int i=0;i<8;i++){
   vec4 patch79=ground_patches79[i];
   float d79=length((world.xz-patch79.xy)/max(patch79.zw,vec2(.01)));
   float rough79=(soft_noise(world.xz*2.2)-.5)*.22;
   float amount79=1.-smoothstep(.35,1.15,d79+rough79);
   if(amount79>best79){best79=amount79;kind79=patch_kinds79[i];}
  }
  vec2 grain79=floor(world.xz/.055)*.055;
  float speck79=(soft_noise(grain79*6.)-.5)*.045;
  vec3 cover79=kind79<.5?vec3(.37,.315,.225):(kind79<1.5?vec3(.25,.245,.17):vec3(.34,.40,.235));
  cover79+=speck79;
  if(kind79>.5 && kind79<1.5){
   float leaf79=step(.91,grain(floor(world.xz*8.)));
   cover79=mix(cover79,vec3(.45,.365,.22),leaf79*.32);
  }
  col=mix(col,cover79,best79*(kind79>1.5?.68:.88));
 }
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
  for(int i=0;i<64;i++){
   if(i>=route_count) break;
   vec2 a=route_segments[i].xy,b=route_segments[i].zw;
   vec2 v=b-a;
   float t=clamp(dot(world.xz-a,v)/max(dot(v,v),.0001),0.,1.);
   distance_to_path=min(distance_to_path,length(world.xz-a-v*t)*.77/max(route_widths[i],.01));
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
   if(surface_spots){
    float dry=smoothstep(.55,.73,soft_noise(pixel*1.45+vec2(17.3,3.1)));
    float worn=smoothstep(.59,.77,soft_noise(pixel*3.5+vec2(6.2,23.7)));
    soil+=dry*vec3(.058,.041,.023)-worn*vec3(.038,.029,.015);
   }
   if(road_relief){
    float bank=(1.-smoothstep(.015,.095,abs(boundary-.77)))*(.65+soft_noise(pixel*4.)*.35);
    soil*=1.-bank*.13;
    col*=1.-bank*.075;
   }
   if(footprints_enabled && path>.05){
    float pressure=0.;
    for(int i=0;i<48;i++){
     float age=footprint_clock-footprints[i].z;
     if(age<0. || age>=footprint_lifetime) continue;
     vec2 offset=world.xz-footprints[i].xy;
     if(dot(offset,offset)>.065) continue;
     vec2 forward=vec2(cos(footprints[i].w),sin(footprints[i].w));
     vec2 local=vec2(dot(offset,vec2(-forward.y,forward.x)),dot(offset,forward));
     float toe=length((local-vec2(0.,.035))/vec2(.067,.095))-1.;
     float heel=length((local-vec2(0.,-.065))/vec2(.045,.052))-1.;
     float sdf=min(toe,heel);
     float aa=max(fwidth(sdf),.09);
     float shape=1.-smoothstep(-aa,aa,sdf);
     float fade=1.-smoothstep(1.1,footprint_lifetime,age);
     pressure=max(pressure,shape*fade);
    }
    soil*=1.-pressure*.24;
   }
   float turf_edge=(1.-smoothstep(.02,.15,abs(boundary-.77)))*(1.-path);
   col*=1.-turf_edge*.10;
   float ending77=1.;
   for(int e=0;e<8;e++){if(e>=road_end_count77)break;ending77=min(ending77,smoothstep(.15,road_endings77[e].z,length(world.xz-road_endings77[e].xy)));}
   // Break the worn surface into patches near open-ground destinations,
   // rather than leaving a translucent but still circular paint-tool cap.
   float worn77=smoothstep(.20,.78,soft_noise(pixel*2.1)+ending77-.5);
   col=mix(col,soil,path*mix(worn77,1.,step(.995,ending77)));
  }
 }
 if(!detailed_path || !route_layout) col=mix(col,vec3(.34,.25,.15),path*.85);
 if(forest_depth){
  vec3 shade=texture(forest_mask,(world.xz-forest_mask_bounds.xy)/forest_mask_bounds.zw).rgb;
  col*=1.-shade.r*.24-shade.g*.20-shade.b*.18;
 }
 float slope76=1.-smoothstep(.60,.88,normal76.y);
 vec3 stone76=mix(vec3(.34,.37,.30),vec3(.43,.45,.35),soft_noise(world.xz*2.6+world.y));
  vec3 rn78=pow(abs(normal76),vec3(4.));rn78/=max(.001,rn78.x+rn78.y+rn78.z);
 vec3 rp78=texture(rock_paint78,world.zy*.24).rgb*rn78.x+texture(rock_paint78,world.xz*.24).rgb*rn78.y+texture(rock_paint78,world.xy*.24).rgb*rn78.z;
 float natural78=max((1.-smoothstep(-28.,-25.,world.x))*(1.-smoothstep(-56.,-53.,world.z)),smoothstep(15.,20.,world.x));
 stone76=mix(stone76,rp78*vec3(.87,.94,.85),natural78);
 col=mix(col,stone76,slope76);
 float edge76=length((world.xz-sample_center76)/sample_extent76)+(soft_noise(world.xz*.8)-.5)*.08;
 float sample76=sample_enabled76?1.:0.;
 vec3 structure76=mix(vec3(.34,.42,.29),vec3(.40,.47,.34),smoothstep(.3,5.5,world.y));
 structure76=mix(structure76,vec3(.34,.35,.32),slope76);
 structure76=mix(structure76,vec3(.48,.43,.33),path*smoothstep(.65,.9,normal76.y));
 float rail76=(1.-smoothstep(3.1,3.4,abs(world.z-rail_line_z72)))*step(rail_extent72.x,world.x)*(1.-step(rail_extent72.y,world.x));
 structure76=mix(structure76,vec3(.32,.33,.31),rail76);
 col=mix(structure76,col,sample76);
 col=mix(col,vec3(.32,.33,.31),rail76);
 ALBEDO=albedo_view ? vec3(0.) : col;
 EMISSION=albedo_view ? col : vec3(0.);
 ROUGHNESS=1.; SPECULAR=0.;
}


