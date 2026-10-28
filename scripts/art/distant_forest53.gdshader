shader_type spatial;
render_mode unshaded,cull_disabled,fog_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap;
void fragment(){
 vec4 tex=texture(paint,UV);
 if(tex.a<.5) discard;
 float lum=dot(tex.rgb,vec3(.2126,.7152,.0722));
 ALBEDO=COLOR.rgb*mix(.87,1.08,lum);
 ROUGHNESS=1.; SPECULAR=0.;
}
