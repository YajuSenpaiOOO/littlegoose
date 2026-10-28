shader_type spatial;
uniform sampler2D paint108 : source_color,filter_linear_mipmap;
varying float cap108;
void vertex(){cap108=abs(NORMAL.y);}
void fragment(){
 vec2 uv=UV;
 vec3 col;
 if(cap108>.7){col=texture(paint108,vec2(.5+clamp(uv.x,0.,1.)*.5,clamp(uv.y,0.,1.))).rgb;}
 else {col=texture(paint108,vec2(uv.x*.5,uv.y)).rgb;}
 ALBEDO=col*vec3(.94,.96,.94);ROUGHNESS=1.;SPECULAR=0.;
}
