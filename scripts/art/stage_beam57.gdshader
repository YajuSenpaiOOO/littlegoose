shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never,shadows_disabled,fog_disabled;
uniform sampler2D scene_depth : hint_depth_texture,filter_nearest;
uniform float strength57=0.;
void fragment(){
 float depth=texture(scene_depth,SCREEN_UV).r;
 vec3 ndc=vec3(SCREEN_UV*2.-1.,depth);
 if(CLIP_SPACE_FAR==-1.) ndc.z=depth*2.-1.;
 vec4 point=INV_PROJECTION_MATRIX*vec4(ndc,1.);
 float gap=-point.z/point.w+VERTEX.z;
 float soft_contact=smoothstep(0.,.45,gap);
 float side=exp(-pow((UV.x-.5)*4.5,2.));
 side*=smoothstep(0.,.20,UV.x)*(1.-smoothstep(.8,1.,UV.x));
 float ends=smoothstep(0.,.12,UV.y)*(1.-smoothstep(.70,1.,UV.y));
 ALBEDO=vec3(1.,.92,.76);
 ALPHA=side*ends*soft_contact*strength57;
}
