shader_type spatial;
render_mode cull_disabled;
uniform vec4 base_color : source_color=vec4(.4,.3,.18,1.);
void fragment(){ALBEDO=base_color.rgb*COLOR.rgb;ROUGHNESS=1.;SPECULAR=0.;}
