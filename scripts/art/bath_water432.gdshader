shader_type spatial;
render_mode unshaded, depth_draw_never, shadows_disabled;

varying vec2 pond_point;

void vertex() {
 pond_point = VERTEX.xz / 0.636;
}

void fragment() {
 float radius = length(pond_point);
 float edge = smoothstep(0.955, 0.998, radius);
 float wave = sin(pond_point.x * 18.0 + pond_point.y * 24.0 + TIME * 1.27);
 float across = pond_point.y + 0.16 + pond_point.x * 0.24;
 float sheen = exp(-abs(across + wave * 0.014) * 66.0);
 sheen *= 1.0 - smoothstep(0.13, 0.63, abs(pond_point.x - 0.12));
 float angle = atan(pond_point.y, pond_point.x + 0.0001);
 float meniscus = edge * (0.40 + smoothstep(0.32, 0.84, sin(angle + 0.58)) * 0.50);
 float glint = clamp(sheen * 0.72 + meniscus, 0.0, 1.0);
 float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL),normalize(VIEW)),0.0,1.0),3.0);
 ALBEDO = mix(vec3(0.43,0.60,0.58),vec3(0.97,0.85,0.69),glint);
 ALPHA = min(0.79,0.088 + fresnel * 0.16 + glint * 0.57);
}
