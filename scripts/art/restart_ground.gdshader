shader_type canvas_item;
uniform sampler2D grass_texture : source_color, filter_nearest, repeat_enable;
uniform sampler2D earth_texture : source_color, filter_nearest, repeat_disable;
uniform sampler2D new_grass : source_color, filter_nearest, repeat_enable;
uniform sampler2D new_earth : source_color, filter_nearest, repeat_enable;
uniform bool hero_style = true;
uniform int surface = 0;
uniform bool blockout = false;
uniform vec4 tone : source_color = vec4(1.0);
uniform vec2 edge_points[64];
uniform int edge_count = 0;
varying vec2 world_pixel;
void vertex(){ world_pixel = VERTEX; }
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 p = floor(world_pixel);
 vec3 col = texture(grass_texture,p/400.0).rgb;
 // Compress material contrast; the player and standing objects carry the detail.
 float l = dot(col,vec3(0.3,0.5,0.2));
 col = mix(vec3(l)*vec3(0.91,1.02,0.83),col,0.48);
 col = mix(vec3(0.43,0.48,0.31),col,0.58);
 if(surface==1){
  vec2 tile = 1.0-abs(fract(p/vec2(250.0,500.0)*0.5)*2.0-1.0);
  col = texture(earth_texture,vec2(0.501+tile.x*0.498,0.001+tile.y*0.998)).rgb;
  col = mix(col,vec3(0.60,0.49,0.31),0.24);
 }
 if(hero_style){
  // Keep the new albedo's broad masses; no gray/olive multiplication.
  vec2 tile=1.0-abs(fract(p/420.0*0.5)*2.0-1.0);
  col=surface==1 ? texture(new_earth,tile).rgb : texture(new_grass,tile).rgb;
  col=mix(col,surface==1 ? vec3(0.78,0.65,0.46) : vec3(0.46,0.63,0.40),surface==1 ? 0.16 : 0.42);
 }
 float coverage=1.0;
 if(surface==1 && edge_count>0){
  float edge=100000.0;
  for(int i=0;i<64;i++){
   if(i>=edge_count) break;
   vec2 a=edge_points[i];
   vec2 b=edge_points[(i+1)%edge_count];
   vec2 ab=b-a;
   edge=min(edge,length(p-a-ab*clamp(dot(p-a,ab)/max(dot(ab,ab),0.01),0.0,1.0)));
  }
  float erosion=hash(floor(p/3.0))*4.0+hash(p)*2.0;
  coverage=smoothstep(0.5,8.0,edge-erosion);
 }
 if(blockout){col=surface==1 ? vec3(0.67,0.58,0.40) : vec3(0.25,0.36,0.28);}
 COLOR = vec4(col*tone.rgb,tone.a*coverage);
}
