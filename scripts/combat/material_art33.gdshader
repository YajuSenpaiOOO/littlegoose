shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;
uniform sampler2D sheet : source_color, filter_nearest_mipmap;
uniform vec4 regions[6];
varying flat float tile;
void vertex() { tile=INSTANCE_CUSTOM.x; }
void fragment() {
	vec4 region=regions[clamp(int(tile+0.1),0,5)];
	vec4 source=texture(sheet,region.xy+UV*region.zw);
	// Reject the generator's translucent halo without modifying the RGBA source.
	if (source.a<0.78) discard;
	ALBEDO=source.rgb*COLOR.rgb;
	ALPHA=source.a*COLOR.a;
}
