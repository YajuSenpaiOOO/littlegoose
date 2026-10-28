shader_type spatial;
render_mode cull_disabled,shadows_disabled;
#include "res://scripts/art/porch_light49.gdshaderinc"
uniform sampler2D paint : source_color,filter_linear_mipmap;
uniform float fade=1.;
uniform float alpha_threshold=.5;
uniform vec3 tint : source_color=vec3(1.);
uniform float structure49=0.;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void vertex(){porch_position49=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 vec4 tex=texture(paint,UV);
 vec2 p=UV*vec2(textureSize(paint,0));
 if(tex.a<alpha_threshold) discard;
 if(fade<.999 && hash(floor(FRAGCOORD.xy))>fade) discard;
 float gable=245.+abs(p.x-656.)*.97;
 float under_roof=smoothstep(gable+4.,gable+20.,p.y)*(1.-smoothstep(gable+45.,gable+100.,p.y));
 under_roof*=1.-smoothstep(430.,490.,abs(p.x-656.));
 float beam=smoothstep(728.,748.,p.y)*(1.-smoothstep(765.,835.,p.y));
 float base=smoothstep(1010.,1115.,p.y)*.35;
 float warm=step(.15,tex.r-tex.b)*smoothstep(.64,.9,tex.r);
 vec3 col=tex.rgb*tint;
 // Preserve the original painted stairs, including their baked perspective.
 float stair=step(1030.,p.y)*step(abs(p.x-656.),194.);
 col*=mix(vec3(1.),vec3(.55,.64,.69),max(under_roof*.65,max(beam*.68,base))*structure49*(1.-warm)*(1.-stair));
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=porch_light49(col,porch_position49);
 // Painted windows keep their warm core when the facade is sheltered.
 EMISSION=tex.rgb*warm*.13*porch_light_strength49;
 ROUGHNESS=1.; SPECULAR=0.;
}
