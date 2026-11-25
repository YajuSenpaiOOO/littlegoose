shader_type spatial;
uniform sampler2D grain : source_color, filter_linear_mipmap, repeat_enable;
uniform float strength = 0.;
uniform vec2 displacement = vec2(0.);
uniform vec3 tint = vec3(.12,.075,.075);
uniform float lamp_bounce = 0.;
varying vec3 tabletop;

void vertex() { tabletop = VERTEX; }

float softness(vec2 from, vec2 to, vec2 at, float width) {
	vec2 axis = to - from;
	float along = clamp(dot(at-from,axis) / dot(axis,axis),0.,1.);
	float distance_to_axis = length(at - mix(from,to,along));
	return 1. - smoothstep(width*.3,width,distance_to_axis);
}

void fragment() {
	float row = tabletop.z / .191 + .5;
	float board = floor(row);
	vec2 uv = vec2(tabletop.x * .58 + board * .29, fract(row) * .66 + board * .37);
	vec3 paint = texture(grain, uv).rgb;
	float seam = smoothstep(.012, .035, min(fract(row), 1. - fract(row)));
	float shade = .86 + .12 * sin(board * 2.21 + .33);
	float edge = smoothstep(.355,.386,abs(tabletop.z));
	ALBEDO = mix(vec3(.42, .29, .18), paint * vec3(.91,.79,.64), .81)
		* mix(.67,shade,seam) * (1. - edge*.17);
	if (strength > .001) {
		vec2 at = tabletop.xz + displacement;
		float palm = softness(vec2(.54,-.20),vec2(.67,-.08),at,.14);
		float thumb = softness(vec2(.61,-.17),vec2(.69,-.30),at,.067);
		float fingers = softness(vec2(.48,-.22),vec2(.39,-.39),at,.085);
		float sleeve = softness(vec2(.64,-.06),vec2(1.03,.41),at,.21);
		float body = softness(vec2(-.03,.52),vec2(.80,.49),at,.24);
		float shadow = max(max(max(palm,thumb),fingers),max(sleeve*.88,body*.70));
		ALBEDO *= mix(vec3(1.),tint,shadow*strength);
	}
	ROUGHNESS = .91;
	SPECULAR = .17;
 float glow = 1.0 - smoothstep(.12, 1.27, length((tabletop.xz - vec2(.20, -.03)) * vec2(1., 1.9)));
 EMISSION = ALBEDO * vec3(1., .69, .40) * lamp_bounce * glow;
}
