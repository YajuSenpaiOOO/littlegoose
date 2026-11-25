shader_type spatial;
render_mode unshaded, fog_disabled, depth_test_disabled, depth_draw_never, cull_disabled;
uniform sampler2D image : hint_screen_texture, filter_linear, repeat_disable;
uniform sampler2D depth : hint_depth_texture, filter_nearest, repeat_disable;
uniform float amount = 0.;
uniform float focus_far = 6.;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1., 1.);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float scene_depth = texture(depth, uv).r;
	float ndc_depth = CLIP_SPACE_FAR == -1. ? scene_depth * 2. - 1. : scene_depth;
	vec4 view = INV_PROJECTION_MATRIX * vec4(uv * 2. - 1., ndc_depth, 1.);
	float distance = -view.z / view.w;
	float blur = smoothstep(focus_far, focus_far + 4., distance) * amount;
	vec3 sharp = texture(image, uv).rgb;
	ALBEDO = sharp;
	if (blur > .02) {
		vec2 pixel = 1. / vec2(textureSize(image, 0));
		vec3 soft = sharp * .20;
		for (int i = 0; i < 8; i++) {
			float angle = float(i) * 2.39996323;
			float radius = sqrt((float(i) + .5) / 8.) * 12. * blur;
			vec2 offset = vec2(cos(angle), sin(angle)) * pixel * radius;
			soft += texture(image, uv + offset).rgb * .10;
		}
		ALBEDO = mix(sharp, soft, blur);
	}
}
