shader_type spatial;
render_mode cull_disabled,world_vertex_coords,depth_prepass_alpha;
uniform sampler2DArray paint : source_color,filter_linear_mipmap;
uniform vec4 regions[4];
uniform vec3 walker=vec3(1000.);
uniform vec4 trail[8];
uniform vec4 touch_bounds=vec4(1000.);
uniform float clock=0.;
uniform float wind_strength=1.;
uniform bool albedo_view=false;
uniform bool smooth_edges=true;
varying float variant;
varying float distance_to_camera;
void vertex(){
 vec3 root=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 variant=min(3.,floor(INSTANCE_CUSTOM.x*4.+.01));
 distance_to_camera=distance(root,CAMERA_POSITION_WORLD);
 float lod=1.-smoothstep(26.,38.,distance_to_camera);
 float tip=1.-UV.y;
 float pressure=0.; float echo=0.;
 if(root.x>=touch_bounds.x && root.z>=touch_bounds.y && root.x<=touch_bounds.z && root.z<=touch_bounds.w){
  pressure=1.-smoothstep(.1,.65,length(root.xz-walker.xz));
  for(int i=0;i<8;i++){
   float age=clock-trail[i].z;
   if(age>=0. && age<.9){
    echo+=(1.-smoothstep(.1,.6,length(root.xz-trail[i].xy)))*exp(-age*5.)*sin(age*13.)*trail[i].w;
   }
  }
 }
 vec2 outward=normalize(root.xz-walker.xz+vec2(.0001));
 float wind=sin(clock*1.45+root.x*1.8+root.z)*.018*wind_strength;
 VERTEX.xz+=tip*tip*(outward*pressure*.19+vec2(wind+echo*.035,wind*.35));
 VERTEX=root+(VERTEX-root)*lod;
 VERTEX.y-=tip*pressure*.08*lod;
 // One up-facing lighting normal prevents card directions becoming alternating stripes.
 NORMAL=vec3(0.,1.,0.);
}
void fragment(){
 vec4 region=regions[int(variant)];
 vec2 uv=region.xy+UV*region.zw;
 vec4 tex=texture(paint,vec3(uv,variant));
 if(tex.a<.02) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,1.,0.,0.)).xyz);
 ALPHA=smoothstep(.12,.68,tex.a);
 if(!smooth_edges){
  if(tex.a<.5) discard;
  ALPHA=1.;
 }
 ALBEDO=albedo_view ? vec3(0.) : tex.rgb;
 EMISSION=albedo_view ? tex.rgb : vec3(0.);
 ROUGHNESS=1.; SPECULAR=0.;
}
