shader_type spatial;
uniform sampler2D paint:source_color,filter_nearest_mipmap,repeat_disable;
void fragment(){
 // Same material color/lighting as A; B differs only in redrawn art and sampling.
 vec3 c=texture(paint,UV).rgb;
 float gray=dot(c,vec3(.2126,.7152,.0722));
 ALBEDO=mix(vec3(gray),c,.65)*vec3(.70,.75,.80);
 ROUGHNESS=1.;SPECULAR=0.;
}
