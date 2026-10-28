shader_type spatial;
render_mode cull_disabled,world_vertex_coords;
uniform sampler2D ground_paint : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform bool flat_ground=false;
uniform vec3 flat_color : source_color=vec3(.38,.54,.28);
uniform vec3 walker=vec3(1000.);
uniform vec4 trail[8];
uniform vec4 touch_bounds=vec4(1000.);
uniform float clock=0.;
uniform float wind_strength=1.;
uniform bool albedo_view=false;
uniform bool mixed_grass=false;
uniform bool forest_depth=false;
uniform vec4 forest_mask_bounds=vec4(-32.,-32.,64.,64.);
uniform sampler2D forest_mask : filter_linear,repeat_disable;
varying vec2 root_xz;
varying vec3 ground_normal;
varying float height_mix;
varying float shade;
void vertex(){
 vec3 root=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 root_xz=root.xz;
 ground_normal=normalize(MODEL_NORMAL_MATRIX*vec3(0.,1.,0.));
 if(mixed_grass){
  float growth=mix(.42,1.,INSTANCE_CUSTOM.b);
  float local_height=dot(VERTEX-root,ground_normal);
  VERTEX-=ground_normal*local_height*(1.-growth);
 }
 float tip=UV.y;
 float pressure=0.; float echo=0.;
 if(root.x>=touch_bounds.x && root.z>=touch_bounds.y && root.x<=touch_bounds.z && root.z<=touch_bounds.w){
  pressure=1.-smoothstep(.1,.65,length(root.xz-walker.xz));
  for(int i=0;i<8;i++){
   float age=clock-trail[i].z;
   if(age>=0. && age<.9) echo+=(1.-smoothstep(.1,.6,length(root.xz-trail[i].xy)))*exp(-age*5.)*sin(age*13.)*trail[i].w;
  }
 }
 float wind=sin(clock*1.45+root.x*1.8+root.z)*.017*wind_strength;
 vec2 outward=normalize(root.xz-walker.xz+vec2(.0001));
 VERTEX.xz+=tip*tip*(outward*pressure*.24+vec2(wind+echo*.035,wind*.35));
 VERTEX.y-=tip*pressure*.075;
 float lod=1.-smoothstep(27.,42.,distance(root,CAMERA_POSITION_WORLD));
 VERTEX=root+(VERTEX-root)*lod;
 NORMAL=ground_normal;
 height_mix=tip;
 shade=.96+INSTANCE_CUSTOM.y*.08;
}
void fragment(){
 vec2 tile=root_xz/6.;
 vec2 mirror=1.-abs(fract(tile*.5)*2.-1.);
 vec3 soil=texture(ground_paint,mirror).rgb;
 if(flat_ground) soil=flat_color;
 // Same ground hue at the buried root; subtle cool shadow and warmer leaf tip.
 vec3 leaf=soil*mix(vec3(.89,.94,.83),vec3(1.00,1.04,.91),height_mix)*shade;
 vec3 col=mix(soil,leaf,smoothstep(.04,.42,height_mix));
 if(forest_depth){
  vec3 forest_shade=texture(forest_mask,(root_xz-forest_mask_bounds.xy)/forest_mask_bounds.zw).rgb;
  col*=1.-forest_shade.r*.24-forest_shade.g*.20-forest_shade.b*.18;
 }
 NORMAL=normalize((VIEW_MATRIX*vec4(ground_normal,0.)).xyz);
 ALBEDO=albedo_view ? vec3(0.) : col;
 EMISSION=albedo_view ? col : vec3(0.);
 ROUGHNESS=1.; SPECULAR=0.;
}
