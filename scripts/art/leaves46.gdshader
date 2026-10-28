shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
varying vec4 leaf_color;
varying float fold;
void vertex(){leaf_color=INSTANCE_CUSTOM;fold=mix(.84,1.,step(0.,VERTEX.x));}
void fragment(){
 ALBEDO=leaf_color.rgb*fold;
 ALPHA=leaf_color.a;
 ROUGHNESS=1.; SPECULAR=0.;
}
