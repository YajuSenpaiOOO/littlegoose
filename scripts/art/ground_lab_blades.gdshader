shader_type spatial;
render_mode cull_disabled,world_vertex_coords;
// Opaque silhouettes: no image alpha, intersecting transparent cards or alpha sorting.
uniform vec3 base_color : source_color=vec3(.32,.48,.23);
uniform vec3 tip_color : source_color=vec3(.52,.66,.32);
uniform vec3 walker=vec3(1000.);
uniform vec4 trail[8];
uniform vec4 touch_bounds=vec4(1000.);
uniform float clock=0.;
uniform float wind_strength=1.;
uniform bool albedo_view=false;
varying float height_mix;
varying float shade;
void vertex(){
 vec3 root=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 float tip=UV.y;
 float lod=1.-smoothstep(26.,38.,distance(root,CAMERA_POSITION_WORLD));
 float pressure=0.; float echo=0.;
 if(root.x>=touch_bounds.x && root.z>=touch_bounds.y && root.x<=touch_bounds.z && root.z<=touch_bounds.w){
  pressure=1.-smoothstep(.1,.65,length(root.xz-walker.xz));
  for(int i=0;i<8;i++){
   float age=clock-trail[i].z;
   if(age>=0. && age<.9)
    echo+=(1.-smoothstep(.1,.6,length(root.xz-trail[i].xy)))*exp(-age*5.)*sin(age*13.)*trail[i].w;
  }
 }
 vec2 outward=normalize(root.xz-walker.xz+vec2(.0001));
 float wind=sin(clock*1.45+root.x*1.8+root.z)*.018*wind_strength;
 VERTEX.xz+=tip*tip*(outward*pressure*.24+vec2(wind+echo*.035,wind*.35));
 VERTEX.y-=tip*pressure*.1;
 VERTEX=root+(VERTEX-root)*lod;
 NORMAL=vec3(0.,1.,0.);
 height_mix=tip;
 shade=.94+INSTANCE_CUSTOM.y*.09+COLOR.r*.04;
}
void fragment(){
 vec3 col=mix(base_color,tip_color,smoothstep(.15,.9,height_mix)*.45)*shade*.88;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,1.,0.,0.)).xyz);
 ALBEDO=albedo_view ? vec3(0.) : col;
 EMISSION=albedo_view ? col : vec3(0.);
 ROUGHNESS=1.; SPECULAR=0.;
}
