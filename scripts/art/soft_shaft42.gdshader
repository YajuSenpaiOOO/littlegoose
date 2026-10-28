shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled, fog_disabled;
uniform sampler2D scene_depth : hint_depth_texture, filter_nearest;
uniform float clock=0.;
uniform float phase=0.;
uniform float strength=.17;
varying vec3 world_position;
void vertex(){ world_position=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz; }
float hash(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
float mist(vec3 p){
 vec3 cell=floor(p),f=fract(p); f=f*f*(3.-2.*f);
 return mix(mix(mix(hash(cell),hash(cell+vec3(1,0,0)),f.x),mix(hash(cell+vec3(0,1,0)),hash(cell+vec3(1,1,0)),f.x),f.y),mix(mix(hash(cell+vec3(0,0,1)),hash(cell+vec3(1,0,1)),f.x),mix(hash(cell+vec3(0,1,1)),hash(cell+vec3(1,1,1)),f.x),f.y),f.z);
}
void fragment(){
 float d=texture(scene_depth,SCREEN_UV).r;
 vec3 ndc=vec3(SCREEN_UV*2.-1.,d);
 if(CLIP_SPACE_FAR==-1.) ndc.z=d*2.-1.;
 vec4 scene=INV_PROJECTION_MATRIX*vec4(ndc,1.);
 float gap=-scene.z/scene.w+VERTEX.z;
 float contact=smoothstep(0.,.65,gap);
 float side=exp(-pow((UV.x-.5)*4.1,2.));
 side*=smoothstep(0.,.24,UV.x)*(1.-smoothstep(.76,1.,UV.x));
 float ends=smoothstep(0.,.32,UV.y)*(1.-smoothstep(.48,1.,UV.y));
 float wisps=mix(.38,1.,mist(world_position*.65+vec3(clock*.018,phase,0.)));
 ALBEDO=vec3(1.,.90,.68);
 ALPHA=side*ends*wisps*contact*strength;
}
