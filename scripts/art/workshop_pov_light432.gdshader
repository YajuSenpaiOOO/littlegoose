shader_type canvas_item;

uniform float saturation = 1.;
uniform float exposure = 1.;
uniform vec3 shadows = vec3(1.);
uniform vec3 highlights = vec3(1.);
uniform float reveal = 0.;
uniform vec2 art_size = vec2(1000.,667.);
uniform vec2 wrist_start;
uniform vec2 wrist_end;
uniform float cord_depth;
uniform float cord_shadow;
uniform int charm_count;
uniform float finger_phase;
uniform float finger_motion;
uniform vec2 breath_offset;

float wrist_curve(float along) {
	float centered = 2. * along - 1.;
	float arc = sqrt(max(0., 1. - centered * centered));
	return mix(wrist_start.y, wrist_end.y, along) + cord_depth * arc;
}

void fragment() {
	vec2 local = UV * art_size;
	vec2 paint_uv = UV;
	// Keep the wrist still and ease the breathing displacement in through the sleeve.
	if (local.y > 354.) {
		float weight = smoothstep(354.,580.,local.y);
		float shoulder = mix(1.,.70,smoothstep(654.,935.,local.x));
		paint_uv -= breath_offset * (weight * shoulder) / art_size;
	}
	if (finger_motion > 0. && local.y < 228. && local.x > 568. && local.x < 826.) {
		float flex = (1. - smoothstep(145.,228.,local.y))
			* smoothstep(568.,606.,local.x) * (1. - smoothstep(794.,826.,local.x));
		float curl = sin(finger_phase * 1.15 + .038 * (local.x - 625.));
		paint_uv += vec2(1.55 * sin(finger_phase + .025 * local.x),2.4 * curl)
			* (finger_motion * flex) / art_size;
	}
	vec4 paint = texture(TEXTURE, paint_uv);
	float value = dot(paint.rgb, vec3(.2126, .7152, .0722));
	vec3 tone = mix(shadows, highlights, smoothstep(.14,.79,value));
	vec3 color = mix(vec3(value), paint.rgb, saturation) * tone * exposure;
	if (paint.a > 0.0 && local.x >= wrist_start.x && local.x <= wrist_end.x
		&& local.y >= wrist_end.y - 4. && local.y <= wrist_start.y + cord_depth + 42.) {
		float along = (local.x - wrist_start.x) / (wrist_end.x - wrist_start.x);
		float gap = local.y - wrist_curve(along);
		float core = 1. - smoothstep(.7, 4.5, abs(gap - 1.7));
		float penumbra = 1. - smoothstep(1., 8.5, abs(gap - 4.));
		float contact = max(core, penumbra * .52);
		float spread = min(.76, float(charm_count - 1) * .25);
		float charm_scale = min(1., 5. / float(max(charm_count, 1)));
		for (int i = 0; i < charm_count; i++) {
			float t = .53 + spread * (float(i) / float(max(charm_count - 1, 1)) - .5);
			vec2 center = vec2(mix(wrist_start.x,wrist_end.x,t),wrist_curve(t));
			vec2 diff = local - center - vec2(3.5,1. + 16. * charm_scale);
			diff.x -= diff.y * .09;
			float shadow = 1. - smoothstep(.19,1.,length(diff / (vec2(10.,18.) * charm_scale)));
			contact = max(contact, shadow * .51);
		}
		color *= mix(vec3(1.), vec3(.62,.41,.36), contact * cord_shadow);
	}
	COLOR = vec4(clamp(color, vec3(0.), vec3(1.)), paint.a * reveal);
}
