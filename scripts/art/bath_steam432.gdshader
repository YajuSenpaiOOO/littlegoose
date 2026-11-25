shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform float density = 0.0;

void fragment() {
 float height = 1.0 - UV.y;
 float a = sin(TIME * 0.91 - height * 7.0);
 float b = sin(TIME * 0.69 - height * 8.0 + 2.0);
 float left = (UV.x - (0.31 + 0.12 * a)) / mix(0.057, 0.22, height);
 float right = (UV.x - (0.64 + 0.16 * b)) / mix(0.048, 0.24, height);
 float wisps = exp(-left * left * 2.0) * (0.55 + a * 0.25)
             + exp(-right * right * 2.0) * (0.48 + b * 0.24);
 float fade = smoothstep(0.0, 0.27, height) * (1.0 - smoothstep(0.54, 1.0, height));
 ALBEDO = vec3(0.93, 0.74, 0.53);
 ALPHA = clamp(wisps * fade * density, 0.0, 0.30);
}
