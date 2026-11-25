extends "res://scripts/art/pig_model350.gd"
var locked354:=false
var cycles354:=0
func advance219(delta: float) -> void:
 if not running219:return
 age219+=delta
 if phase219=="idle":
  if age219>=0. and not locked354:
   var offset: Vector3=world.hero.global_position-global_position
   direction219=Vector2(offset.x,offset.z).normalized()
   if direction219.length_squared()<.01:direction219=Vector2.DOWN
   locked354=true;cycles354+=1;warning354()
  if age219>=1.:
   phase219="spray";age219=0.;emission219=0.
 elif phase219=="spray":
  emission219+=delta
  while emission219>=.26:
   emission219-=.26
   update_pose219();_process(0.)
   var sweep:=lerpf(-.34,.34,clampf(age219/2.2,0.,1.))
   for i in 2:stream.emit219(nose219(i),direction219.rotated(sweep+(-.11 if i==0 else .11)),i)
  if age219>=2.2:phase219="idle";age219=-1.;locked354=false
 update_pose219()
 warning.visible=phase219=="idle" and age219>=0.
func warning354() -> void:
 # Draw the full committed lane before the sweep, rather than a single old ray.
 var at:=Vector2(global_position.x,global_position.z)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for angle in [-.46,.46]:
  var direction:=direction219.rotated(angle)
  var side:=direction.orthogonal()*.035
  for i in 12:
   var a:=at+direction*(.5+float(i)*.45)
   var b:=at+direction*(.5+float(i)*.45+.28)
   for point in [a-side,a+side,b+side,a-side,b+side,b-side]:st.add_vertex(to_local(Vector3(point.x,world.floor_height(point)+.045,point.y)))
 warning.mesh=st.commit()
