shader_type spatial;
render_mode cull_disabled;
uniform sampler2D water_paint59 : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D shore59 : filter_linear,repeat_disable;
uniform vec4 bounds59=vec4(0.,0.,1.,1.);
uniform int water_style59=0;
uniform float clock=0.;
uniform float night59=0.;
uniform float sunset59=0.;
uniform bool motion60=true;
uniform bool sparkle60=true;
uniform float frozen60=0.;
uniform bool distant_glow61=true;
uniform float focus61=15.;
varying vec3 at60;
void vertex(){at60=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
float hash60(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 p=at60.xz;
 float t=motion60 ? clock : frozen60;
 float shore=texture(shore59,(p-bounds59.xy)/bounds59.zw).r*8.;
 float depth=smoothstep(.15,5.5,shore);
 vec2 warp=vec2(sin(p.y*.85+t*.65),cos(p.x*.65-t*.43));
 vec3 painted=texture(water_paint59,p/15.+warp*.004+vec2(t*.0014,0.)).rgb;
 vec3 shallow=vec3(.28,.48,.38);
 vec3 deep=vec3(.09,.26,.29);
 vec3 colour;
 if(water_style59==0){
  colour=mix(shallow,deep,depth)*.56+painted*.44;
 }else if(water_style59==1){
  colour=mix(vec3(.30,.56,.45),vec3(.065,.27,.34),depth)+painted*.12;
  float trees=smoothstep(.48,.73,sin(p.x*.59+sin(p.x*1.61)*.7+warp.x*.055));
  colour=mix(colour,vec3(.12,.25,.23),trees*(1.-smoothstep(.6,4.,shore))*.15);
 }else{
  colour=mix(vec3(.31,.45,.43),vec3(.12,.23,.34),depth)+painted*.12;
 }
 // Broad moving ripples carry smaller broken glints; no point lights or reflection pass.
 float wave=sin(p.y*3.7+sin(p.x*.67+t*.24)*.7-t*.85);
 float crosswave=sin(p.y*6.4+p.x*.45+t*.61);
 colour*=1.+wave*.036+crosswave*.018;
 float glints=0.;
 float distance_blend=0.;
 if(distant_glow61){
  float view_depth=-(VIEW_MATRIX*vec4(at60,1.)).z;
  distance_blend=smoothstep(focus61+4.,focus61+17.,view_depth);
 }
 if(sparkle60){
  vec2 grid=p*vec2(1.05,2.4);
  vec2 cell=floor(grid);
  vec2 local=fract(grid);
  vec2 soft_edge=smoothstep(vec2(0.),vec2(.25),local)*(1.-smoothstep(vec2(.75),vec2(1.),local));
  float seed=hash60(cell);
  float breath=.5+.5*sin(t*1.35+seed*6.283+sin(p.x*.6)*.7);
  float finewave=sin(p.y*7.4+sin(p.x*.67+t*.24)*.9-t*1.25);
  float ribbon=smoothstep(.84,.99,finewave);
  float broken=smoothstep(.35,.72,sin(p.x*2.3+seed*4.+t*.32)*.5+.5);
  float pocket=smoothstep(.42,.79,seed)*smoothstep(.35,.9,breath);
  glints=ribbon*broken*pocket;
  glints+=smoothstep(.975,1.,crosswave)*smoothstep(.88,.99,seed)*breath*.35;
  glints*=soft_edge.x*soft_edge.y*smoothstep(.1,.8,shore);
  // Wide, smooth wave crests survive distant depth-of-field without pixel-sized flicker.
  float soft_crest=pow(max(0.,sin(p.y*2.25+sin(p.x*.38+t*.18)*.8-t*.62)),10.);
  float soft_break=smoothstep(.25,.88,.5+.5*sin(p.x*1.10+sin(p.y*.40)+t*.36));
  float soft_pulse=.55+.45*sin(p.x*.28+p.y*.37+t*.80);
  float far_glints=soft_crest*soft_break*soft_pulse*smoothstep(.15,1.1,shore);
  glints=mix(glints,far_glints*.85,distance_blend);
 }
 colour=mix(colour,vec3(.44,.53,.43),exp(-pow((shore-.24)/.20,2.))*.22);
 colour+=vec3(.18,.10,.035)*sunset59*(.3+.7*depth);
 float luma=dot(colour,vec3(.2126,.7152,.0722));
 colour=mix(colour,mix(vec3(luma)*vec3(.86,.95,1.),colour,.55),night59);
 vec3 light_tint=mix(vec3(.80,.93,.88),vec3(1.,.68,.32),sunset59*.8);
 light_tint=mix(light_tint,vec3(.40,.60,.85),night59);
 ALBEDO=colour+light_tint*glints*.38;
 EMISSION=light_tint*glints*mix(.19,.035,night59)*(1.+distance_blend*.6);
 NORMAL=normalize((VIEW_MATRIX*vec4(wave*.07,1.,crosswave*.045,0.)).xyz);
 ROUGHNESS=.72; SPECULAR=.08;
}
