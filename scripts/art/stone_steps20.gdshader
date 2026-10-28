shader_type spatial;
render_mode cull_disabled;
varying vec3 place;
void vertex() { place = (MODEL_MATRIX*vec4(VERTEX,1.)).xyz; }
void fragment() {
	vec2 tile = vec2(place.x*1.8+floor(place.z*2.)*.5,place.z*2.);
	vec2 f = fract(tile);
	float seam = step(min(min(f.x,1.-f.x),min(f.y,1.-f.y)),.025);
	float speck = floor(fract(sin(dot(floor(place.xz*32.),vec2(127.1,311.7)))*43758.54)*4.)/4.;
	float moss = smoothstep(.25,.65,sin(place.x*2.7)*cos(place.z*3.1))*.32;
	vec3 stone = mix(vec3(.37,.40,.34),vec3(.43,.47,.30),moss)+speck*.035;
	ALBEDO = mix(stone,stone*.67,seam);
	ROUGHNESS = 1.;
}
