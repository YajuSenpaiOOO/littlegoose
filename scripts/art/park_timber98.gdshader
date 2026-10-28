shader_type spatial;
uniform sampler2D timber97 : source_color,filter_linear_mipmap,repeat_enable;
uniform sampler2D endgrain97 : source_color,filter_linear_mipmap,repeat_disable;
uniform int kind97=0;
varying vec3 local98;
varying float cap98;
void vertex(){local98=VERTEX;cap98=abs(NORMAL.y);}
void fragment(){
 vec3 col=texture(timber97,UV*vec2(1.,.65)).rgb;
 col=mix(vec3(.43,.31,.17),col,.72);
 if(kind97==1 && cap98>.7) col=mix(vec3(.58,.43,.25),texture(endgrain97,local98.xz/1.05+vec2(.5)).rgb,.63);
 if(kind97==2) col=mix(vec3(.38,.32,.20),vec3(.64,.56,.37),.5+.25*sin(UV.y*160.));
 ALBEDO=col;ROUGHNESS=1.;SPECULAR=0.;
}
