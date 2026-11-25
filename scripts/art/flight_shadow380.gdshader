shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;
uniform sampler2D body_tex : filter_nearest;
uniform sampler2D wing_tex : filter_nearest;
uniform mat4 body_inverse;
uniform mat4 wing_inverse;
uniform vec3 light_ray;
uniform vec4 body_region;
uniform vec4 wing_region;
uniform vec4 body_layout;
uniform vec4 wing_layout;
uniform float body_density;
uniform float wing_density;
uniform float opacity = .189;
uniform float body_weight = 1.;
uniform float wing_weight = 1.;
varying vec3 ground_world;
void vertex(){ground_world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
vec2 sprite_uv(mat4 inv, vec4 layout, float density){
 vec3 p=(inv*vec4(ground_world,1.)).xyz;
 vec3 d=(inv*vec4(light_ray,0.)).xyz;
 if(abs(d.z)<.00001){return vec2(-10.);}
 p-=d*(p.z/d.z);
 return vec2((p.x/density-layout.z)/layout.x+.5,.5-(p.y/density-layout.w)/layout.y);
}
float inside(vec2 uv){return step(0.,uv.x)*step(uv.x,1.)*step(0.,uv.y)*step(uv.y,1.);}
void fragment(){
 vec2 b=sprite_uv(body_inverse,body_layout,body_density);
 vec2 w=sprite_uv(wing_inverse,wing_layout,wing_density);
 float ba=texture(body_tex,body_region.xy+b*body_region.zw).a*inside(b);
 float wa=texture(wing_tex,wing_region.xy+w*wing_region.zw).a*inside(w);
 ALBEDO=vec3(.10,.14,.10);
 ALPHA=step(.5,max(ba*body_weight,wa*wing_weight))*opacity;
}
