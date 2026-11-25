extends MeshInstance3D

const STRIPS:=24
var paper_size:Vector2

func attach(spread:MeshInstance3D,dimensions:Vector2) -> void:
 paper_size=dimensions
 var ink:=spread.material_override.duplicate() as StandardMaterial3D
 ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 material_override=ink
 cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 spread.add_child(self)
 hide()

func set_tone(tone:Color) -> void:
 material_override.albedo_color=tone

func show_turn(progress:float,direction:float) -> void:
 visible=progress>0. and progress<1.
 if not visible:return
 var page:=SurfaceTool.new()
 page.begin(Mesh.PRIMITIVE_TRIANGLES)
 var source_side:=direction if progress<.5 else -direction
 for i in STRIPS:
  var a:=float(i)/STRIPS
  var b:=float(i+1)/STRIPS
  var section:=[Vector2(a,0),Vector2(b,0),Vector2(b,1),Vector2(a,0),Vector2(b,1),Vector2(a,1)]
  for point:Vector2 in section:
   var uv:=Vector2(.5+source_side*point.x*.453,lerpf(.046,.955,point.y))
   page.set_uv(uv)
   page.add_vertex(paper_point(point,progress,direction))
 mesh=page.commit()

func paper_point(point:Vector2,progress:float,direction:float) -> Vector3:
 var angle:=progress*PI+sin(progress*PI)*.28*point.x
 var reach:=paper_size.x*.453*point.x
 var x:=direction*reach*cos(angle)
 var y:=.002+reach*sin(angle)*.66
 var z:=(lerpf(.046,.955,point.y)-.5)*paper_size.y
 z-=sin(progress*PI)*point.x*.022*point.y
 return Vector3(x,y,z)
