shader_type spatial;
render_mode cull_disabled;
uniform sampler2D grass_texture : source_color, filter_nearest_mipmap, repeat_enable;
uniform sampler2D earth_texture : source_color, filter_nearest_mipmap;
uniform bool quiet_ground=true;
varying vec3 world;
float hash(vec2 p){ return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void vertex(){ world=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment(){
 vec2 p=world.xz;
 vec3 grass=texture(grass_texture,p/8.0).rgb;
 float l=dot(grass,vec3(.3,.5,.2));
 grass=mix(vec3(l)*vec3(.91,1.02,.83),grass,.60);
 // Spatial albedo is linear; the old 2D palette must not be reused as linear RGB.
 grass=mix(vec3(.155,.196,.078),grass,.68);
 if(quiet_ground){
  // Remove readable painted leaf shapes from the albedo; standing grass owns them.
  vec3 broad=textureLod(grass_texture,p/8.0,2.0).rgb;
  float fleck=(hash(floor(p*85.))-.5)*.014;
  grass=mix(broad,vec3(.16,.20,.10),.25)+vec3(fleck);
  grass=mix(grass,texture(grass_texture,p/8.0).rgb,.16);
 }
 vec2 tile=1.0-abs(fract(p/vec2(5.,10.)*.5)*2.-1.);
 vec3 earth=texture(earth_texture,vec2(.501+tile.x*.498,.001+tile.y*.998)).rgb;
 earth*=vec3(.85,.86,.92);
 float main_path=abs(p.x-sin(p.y*.18)*1.2)-1.35;
 float branch=max(abs(p.y-.7)-1.0,max(-p.x,p.x-11.5));
 float hill_path=max(abs(p.x-10.)-1.0,p.y-1.0);
 float edge=min(main_path,min(branch,hill_path));
 float noise=(hash(floor(p*24.))-.5)*.18;
 float mask=1.-smoothstep(-.10,.18,edge+noise);
 ALBEDO=mix(grass,earth,mask)*vec3(1.07,1.06,.96);
 ROUGHNESS=1.;
}
