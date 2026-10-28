shader_type canvas_item;
render_mode unshaded;
void fragment() {
	vec3 source = texture(TEXTURE,UV).rgb;
	float highlight = smoothstep(0.6,1.0,dot(source,vec3(0.2,0.65,0.15)));
	COLOR = vec4(mix(vec3(0.35,0.8,0.67),vec3(0.95,1.0,0.98),highlight),COLOR.a);
}
