extends RefCounted

const SIDES:=9
const PROFILES:=[
 [[Vector4(-.84,.10,-.13,.085),Vector4(-.49,.128,-.08,.118),Vector4(-.08,.13,.02,.105),Vector4(.36,.13,.09,.077),Vector4(.80,.086,.23,.038)],
  [Vector4(.00,.12,.025,.078),Vector4(.21,.15,-.17,.054),Vector4(.40,.14,-.35,.030)]],
 [[Vector4(-.75,.105,-.08,.093),Vector4(-.38,.12,-.05,.104),Vector4(.07,.116,.03,.092),Vector4(.43,.093,.10,.067),Vector4(.75,.093,.10,.036)],
  [Vector4(-.20,.11,-.025,.055),Vector4(-.09,.21,-.12,.026)]],
 [[Vector4(-.80,.12,-.05,.108),Vector4(-.44,.131,-.12,.107),Vector4(-.09,.16,.04,.094),Vector4(.28,.091,.19,.075),Vector4(.56,.087,.13,.060),Vector4(.80,.115,.25,.030)]]
]

static func _log_space(point:Vector3) -> Vector3:
 return Vector3(-point.y,point.x,point.z)

static func build(style:int) -> ArrayMesh:
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for path in PROFILES[style]:
  var centers:=PackedVector3Array()
  var radii:=PackedFloat32Array()
  for joint:Vector4 in path:
   centers.append(Vector3(joint.x,joint.y,joint.z))
   radii.append(joint.w)
  var axes:=PackedVector3Array()
  for i in centers.size():
   axes.append((centers[mini(i+1,centers.size()-1)]-centers[maxi(0,i-1)]).normalized())
  for row in centers.size()-1:
   for side in SIDES:
    for corner in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
     var r:int=row+corner.y
     var s:int=side+corner.x
     var normal:=_radial(axes[r],s)
     surface.set_normal(_log_space(normal))
     surface.set_uv(Vector2(float(s)/SIDES,float(r)/(centers.size()-1)))
     surface.add_vertex(_log_space(centers[r]+normal*radii[r]))
  var end:=centers.size()-1
  for row in [0,end]:
   surface.set_normal(_log_space(axes[row]*(-1. if row==0 else 1.)))
   for side in SIDES:
    surface.set_uv(Vector2(.5,.5))
    surface.add_vertex(_log_space(centers[row]))
    for step in [1,0] if row==0 else [0,1]:
     var angle:=TAU*float(side+step)/SIDES
     surface.set_uv(Vector2(.5,.5)+Vector2.from_angle(angle)*.46)
     surface.add_vertex(_log_space(centers[row]+_radial(axes[row],side+step)*radii[row]))
 return surface.commit()

static func _radial(axis:Vector3,side:int) -> Vector3:
 var lateral:=axis.cross(Vector3.UP).normalized()
 var vertical:=lateral.cross(axis)
 var angle:=TAU*float(side)/SIDES
 return vertical*cos(angle)-lateral*sin(angle)
