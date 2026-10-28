shader_type spatial;
render_mode cull_disabled;
uniform sampler2D face_paint79 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D top_paint79 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
varying vec3 at79;
varying vec3 normal79;
void vertex(){at79=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;normal79=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec3 n79=normalize(normal79);
 vec2 uv79=abs(n79.z)>.6?at79.xy:at79.zy;
 vec3 face79=texture(face_paint79,uv79/2.).rgb*.82;
 vec3 top79=texture(top_paint79,at79.xz*.23).rgb*vec3(1.08,1.03,.88);
 ALBEDO=mix(face79,top79,smoothstep(.35,.85,n79.y));
 NORMAL=normalize((VIEW_MATRIX*vec4(normalize(n79+vec3(0.,.35,0.)),0.)).xyz);
 ROUGHNESS=1.;SPECULAR=0.;
}
