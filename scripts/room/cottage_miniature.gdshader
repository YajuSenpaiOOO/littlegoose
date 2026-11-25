shader_type canvas_item;
render_mode unshaded;

uniform sampler2D scene : hint_screen_texture, filter_linear;
uniform float strength = 0.0;
uniform vec2 roof_peak;
uniform vec2 left_eave;
uniform vec2 right_eave;
uniform float doorstep;
uniform vec4 rear_view;

float edge_y(vec2 eave, float x) {
	float weight = clamp((x-roof_peak.x)/(eave.x-roof_peak.x), 0., 1.);
	return mix(roof_peak.y,eave.y,weight);
}

void fragment() {
	vec2 uv=SCREEN_UV;
	float roof=edge_y(uv.x<roof_peak.x ? left_eave : right_eave,uv.x);
	float upper=1.-smoothstep(roof-.016,roof+.010,uv.y);
	float front=smoothstep(doorstep-.009,doorstep+.047,uv.y);
	vec2 back_in=smoothstep(rear_view.xy,rear_view.xy+vec2(.007),uv);
	vec2 back_out=1.-smoothstep(rear_view.zw-vec2(.007),rear_view.zw,uv);
	float window=back_in.x*back_in.y*back_out.x*back_out.y;
	float outside=max(max(upper,front),window*.78)*strength;
	vec3 sharp=texture(scene,uv).rgb;
	vec3 result=sharp;
	if(outside>.008) {
		vec2 pixel=SCREEN_PIXEL_SIZE*min(2.,1./(SCREEN_PIXEL_SIZE.y*1000.));
		vec3 sum=sharp*2.;
		float radius=mix(8.,17.,outside);
		for(int i=0;i<8;i++){
			float angle=float(i)*.7853982;
			float ring=i%2==0 ? 1. : .58;
			vec2 tap=uv+vec2(cos(angle),sin(angle))*ring*radius*pixel;
			sum+=texture(scene,clamp(tap,vec2(.002),vec2(.998))).rgb;
		}
		result=mix(sharp,sum*.1,outside*.89);
	}
	vec2 lens=(uv-vec2(.5,.53))*vec2(1.23,1.);
	result*=1.-.10*strength*smoothstep(.14,.50,dot(lens,lens));
	float highlight=smoothstep(.52,.88,dot(sharp,vec3(.2126,.7152,.0722)));
	result=mix(result,result*vec3(1.035,1.018,1.),highlight*(1.-outside)*strength);
	COLOR=vec4(result,1.);
}
