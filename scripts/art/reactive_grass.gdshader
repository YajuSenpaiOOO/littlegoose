shader_type canvas_item;
uniform vec2 walker = vec2(-10000.0);
uniform vec4 trail[8];
uniform float clock = 0.0;
uniform float wind = 0.65;
uniform vec4 touch_bounds = vec4(-10000.0);
varying vec4 paint_tint;
void vertex(){
 paint_tint=COLOR;
 vec2 root=MODEL_MATRIX[3].xy;
 vec2 size=vec2(length(MODEL_MATRIX[0].xy),length(MODEL_MATRIX[1].xy));
 float tip=clamp(-VERTEX.y*size.y/16.0,0.0,1.0);
 float pressure=0.0;
 float direction=root.x>=walker.x ? 1.0 : -1.0;
 float echo=0.0;
 if(root.x>=touch_bounds.x && root.y>=touch_bounds.y && root.x<=touch_bounds.z && root.y<=touch_bounds.w){
  pressure=1.0-smoothstep(5.0,24.0,length((root-walker)*vec2(1.0,1.25)));
  for(int i=0;i<8;i++){
   float age=clock-trail[i].z;
   if(age>=0.0 && age<0.85){
    float near=1.0-smoothstep(4.0,22.0,length((root-trail[i].xy)*vec2(1.0,1.25)));
    echo+=near*exp(-age*5.0)*sin(age*13.0)*trail[i].w;
   }
  }
 }
 float sway=sin(clock*1.7+root.x*0.04+root.y*0.03)*wind;
 VERTEX.x+=tip*tip*(sway+pressure*direction*6.0+clamp(echo,-2.0,2.0))/max(size.x,0.001);
 VERTEX.y+=tip*pressure*4.0/max(size.y,0.001);
}
void fragment(){vec4 paint=texture(TEXTURE,UV); if(paint.a<0.80) discard; COLOR=paint*paint_tint;}
