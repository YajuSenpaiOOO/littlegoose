shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint:source_color,filter_linear_mipmap,repeat_disable;
uniform vec2 tile_offset;
uniform vec3 tint=vec3(.88);
uniform bool painted=true;
varying vec3 world_pos;
varying vec3 local_pos;
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;local_pos=VERTEX;}
void fragment(){
 vec3 color=texture(paint,tile_offset+UV*.49).rgb*tint;
 if(painted){
  // Wide quiet values; suppress smooth plastic gradients and per-triangle shading.
  float form=mix(.91,1.,smoothstep(.0,.6,world_pos.y));
  ALBEDO=color*form;
  NORMAL=normalize((VIEW_MATRIX*vec4(0.,.55,.835,0.)).xyz);
 }else{ALBEDO=color;}
 ROUGHNESS=1.;SPECULAR=0.;

}
void light(){
 if(painted){
  // Real lights still tint the albedo, with restrained surface shaping and shadow contrast.
  float soft_atten=ATTENUATION;
  vec3 quiet_light=mix(vec3(dot(LIGHT_COLOR,vec3(.2126,.7152,.0722))),LIGHT_COLOR,.22);
  DIFFUSE_LIGHT+=quiet_light*(.40+.04*max(dot(NORMAL,LIGHT),0.))*soft_atten/3.14159265;
 }else{
  DIFFUSE_LIGHT+=LIGHT_COLOR*max(dot(NORMAL,LIGHT),0.)*ATTENUATION/3.14159265;
 }
}
