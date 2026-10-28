shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;
uniform sampler2D sheet : source_color, filter_nearest_mipmap;
uniform vec4 region = vec4(0.0,0.0,1.0,1.0);
void fragment() {
	// Reuse the old candy colours but crop away the spark's long arms. A small
	// bevelled pixel silhouette reads as a hard chip instead of a flying star.
	vec2 p=((floor(UV*vec2(8.0,10.0))+0.5)/vec2(8.0,10.0))*2.0-1.0;
	float chip=step(abs(p.x),0.85)*step(abs(p.y),0.92)*step(abs(p.x)*0.6+abs(p.y)*0.55,0.92);
	vec4 sugar=texture(sheet,region.xy+(vec2(0.2)+UV*0.6)*region.zw);
	ALBEDO=sugar.rgb*COLOR.rgb;
	ALPHA=sugar.a*COLOR.a*chip;
	ALPHA_SCISSOR_THRESHOLD=0.25;
}
