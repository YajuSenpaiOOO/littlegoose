shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color, filter_nearest;
uniform vec2 source_size117=vec2(1448.,1086.);
uniform vec2 crop_origin117=vec2(94.,111.);
uniform float pixel_step117=8.;
uniform float alpha_threshold=.12;
void fragment(){
 // Quantize in source pixels, anchored to the AtlasTexture crop, not the screen.
 vec2 cell=floor((UV*source_size117-crop_origin117)/pixel_step117);
 vec2 sample_uv=(crop_origin117+(cell+.5)*pixel_step117)/source_size117;
 vec4 tex=textureLod(paint,sample_uv,0.);
 if(tex.a<alpha_threshold) discard;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.85,.53,0.)).xyz);
 // Gentle colour steps remove the smooth illustrated gradients without crushing shade.
 ALBEDO=floor(tex.rgb*31.+.5)/31.;
 ROUGHNESS=1.; SPECULAR=0.;
}
