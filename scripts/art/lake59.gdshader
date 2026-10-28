shader_type spatial;
render_mode cull_disabled;
uniform sampler2D water_paint59 : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D shore59 : filter_linear,repeat_disable;
uniform vec4 bounds59=vec4(0.,0.,1.,1.);
uniform int water_style59=0;
uniform float clock=0.;
uniform float night59=0.;
uniform float sunset59=0.;
varying vec3 at59;
void vertex(){at59=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
float hash59(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 p=at59.xz;
 float shore=texture(shore59,(p-bounds59.xy)/bounds59.zw).r*8.;
 float depth=smoothstep(.15,5.5,shore);
 vec2 warp=vec2(sin(p.y*.8+clock*.21),cos(p.x*.48-clock*.16))*.055;
 vec3 painted=texture(water_paint59,p/15.+warp*.02+vec2(clock*.0008,0.)).rgb;
 float swell=sin(p.y*1.5+sin(p.x*.55)+clock*.38)*sin(p.x*.4-clock*.21);
 vec3 shallow=vec3(.28,.48,.38);
 vec3 deep=vec3(.09,.26,.29);
 vec3 colour;
 float shine=0.;
 if(water_style59==0){
  colour=mix(shallow,deep,depth)*.56+painted*.44;
  shine=smoothstep(.77,.95,sin(p.y*2.2+sin(p.x*.32)*.6+clock*.24))*smoothstep(.62,.92,painted.g)*.025;
 }else if(water_style59==1){
  shallow=vec3(.30,.56,.45); deep=vec3(.065,.27,.34);
  colour=mix(shallow,deep,depth)+painted*.12;
  // Broken reflected canopy bands, deliberately stylized, not live SSR.
  float trees=smoothstep(.48,.73,sin(p.x*.59+sin(p.x*1.61)*.7+warp.x));
  float reflection=trees*(1.-smoothstep(.6,4.,shore))*.15;
  colour=mix(colour,vec3(.12,.25,.23),reflection);
  float dash=sin(p.y*5.+sin(p.x*.31)+clock*.32);
  shine=smoothstep(.96,1.,dash)*smoothstep(.45,.8,hash59(floor(p*vec2(.55,1.2))))*.055;
 }else{
  colour=mix(vec3(.31,.45,.43),vec3(.12,.23,.34),depth);
  colour+=painted*.12;
  shine=smoothstep(.91,1.,sin(p.y*2.6+sin(p.x*.15)+clock*.18))*.025;
 }
 float lip=exp(-pow((shore-.24)/.20,2.));
 colour=mix(colour,vec3(.44,.53,.43),lip*.22);
 colour+=vec3(.18,.10,.035)*sunset59*(.3+.7*depth);
 float luma=dot(colour,vec3(.2126,.7152,.0722));
 vec3 moon_muted=mix(vec3(luma)*vec3(.86,.95,1.),colour,.55);
 colour=mix(colour,moon_muted,night59);
 ALBEDO=colour+vec3(.55,.70,.65)*shine;
 NORMAL=normalize((VIEW_MATRIX*vec4(swell*.035,1.,cos(p.y*.9+clock*.2)*.025,0.)).xyz);
 ROUGHNESS=water_style59==1 ? .55 : .85;
 SPECULAR=.08;
}
