shader_type spatial;
render_mode cull_disabled,shadows_disabled,depth_prepass_alpha;
uniform sampler2D paint:source_color,filter_linear_mipmap;
uniform float fade=1.;
uniform float alpha_threshold=.5;
uniform float root_cut_y=1.;
uniform vec3 tint:source_color=vec3(1.);
void fragment(){
 vec4 tex=texture(paint,UV);
 if(UV.y>root_cut_y || tex.a<alpha_threshold) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 ALBEDO=tex.rgb*tint;ROUGHNESS=1.;SPECULAR=0.;
 ALPHA=fade*fade;
}
