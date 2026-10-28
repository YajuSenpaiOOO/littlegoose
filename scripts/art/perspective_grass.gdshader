shader_type spatial;
render_mode cull_disabled;
uniform sampler2D atlas : source_color, filter_nearest;
uniform sampler2D painted_atlas : source_color, filter_linear_mipmap;
uniform vec4 grass_regions[8];
uniform bool painted_grass=true;
uniform vec3 walker=vec3(1000.);
uniform vec4 trail[8];
uniform float clock=0.;
uniform bool natural_blades=true;
uniform vec4 touch_bounds=vec4(1000.);
varying float variant;
void vertex(){
 vec3 root=(MODEL_MATRIX*vec4(0.,0.,0.,1.)).xyz;
 variant=min(7.,floor(INSTANCE_CUSTOM.x*8.+.01));
 float tip=1.-UV.y;
 float bend=0.;
 float echo=0.;
 if(root.x>=touch_bounds.x && root.z>=touch_bounds.y && root.x<=touch_bounds.z && root.z<=touch_bounds.w){
  bend=1.-smoothstep(.12,.65,length(root.xz-walker.xz));
  for(int i=0;i<8;i++){
   float age=clock-trail[i].z;
   if(age>=0. && age<.9){
    float near=1.-smoothstep(.1,.6,length(root.xz-trail[i].xy));
    echo+=near*exp(-age*5.)*sin(age*13.)*trail[i].w;
   }
  }
 }
 float side=root.x>=walker.x ? 1. : -1.;
 VERTEX.x+=tip*tip*(sin(clock*1.7+root.x*2.+root.z)*.025+bend*side*.22+echo*.07);
 VERTEX.y-=tip*bend*.12;
}
void fragment(){
 float old_variant=mod(variant,4.);
 vec2 pixel=vec2(64.+old_variant*16.+UV.x*16.,880.+UV.y*16.);
 if(natural_blades){
  pixel=old_variant<2. ? vec2(16.+old_variant*16.+UV.x*16.,864.+UV.y*32.) : vec2(64.+(old_variant-2.)*16.+UV.x*16.,880.+UV.y*16.);
 }
 vec4 tex=texture(atlas,pixel/vec2(textureSize(atlas,0)));
 if(painted_grass){
  vec4 region=grass_regions[int(variant)];
  tex=texture(painted_atlas,region.xy+UV*region.zw);
 }
 if(tex.a<(painted_grass ? .5 : .8)) discard;
 ALBEDO=tex.rgb*(painted_grass ? vec3(1.05,1.08,.96) : vec3(.50,.68,.43));
 ROUGHNESS=1.;
}
