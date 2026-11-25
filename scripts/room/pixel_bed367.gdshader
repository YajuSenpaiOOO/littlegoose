shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D pixel_atlas:source_color,filter_nearest,repeat_disable;
uniform vec2 tile=vec2(0.);
uniform vec2 logical_grid=vec2(192.,128.);
uniform bool repeat_u=false;
uniform bool show_paint=true;
uniform vec3 plain_color:source_color=vec3(.8,.7,.5);
uniform vec3 room_tint=vec3(.8);
varying vec3 world_normal;
varying float gathering;
void vertex(){world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);gathering=COLOR.r;}
void fragment(){
 vec2 st=UV;
 st.x=repeat_u?fract(st.x):clamp(st.x,0.,.999999);
 st.y=clamp(st.y,0.,.999999);
 // Discrete sampling of newly drawn pixel clusters, not a screen-resolution filter.
 st=(floor(st*logical_grid)+vec2(.5))/logical_grid;
 // Keep the generated sheet dividers outside every sampled tile edge.
 st=vec2(.008)+st*.984;
 vec2 atlas_uv=(tile+st)/vec2(2.,3.);
 vec3 color=show_paint?texture(pixel_atlas,atlas_uv).rgb:plain_color;
 float light=smoothstep(-.55,.8,dot(normalize(world_normal),normalize(vec3(-.35,.75,.65))));
 float form=.90+.05*min(floor(light*3.),2.);
 float ao=.92+.04*min(floor(clamp((gathering-.82)/.18,0.,.999)*3.),2.);
 ALBEDO=color*room_tint*form*ao;
}
