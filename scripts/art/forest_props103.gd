extends "res://scripts/art/forest_props102.gd"
const ENTRY103=preload("res://scripts/world/park_layout103.gd")
var entrance_plants103 := 0
var entrance_rocks103 := 0
func _ready() -> void:
 super._ready()
 var g: Vector2=world.meadow.landmarks.grove
 for spec in [Vector4(14.0,14.1,2.3,0),Vector4(22.,7.8,2.5,2)]:
  var before := rocks87.size();_finger_rock93(g+Vector2(spec.x,spec.y),spec.z,int(spec.w))
  if rocks87.size()>before:
   var rock: Dictionary=rocks87[-1];rock.visual.position.y-=.18
   var material: ShaderMaterial=rock.visual.material_override;material.shader=preload("res://scripts/art/forest_receiver95.gdshader");world.porch49.shade_material(material)
   var shape: ConvexPolygonShape3D=rock.body.get_child(0).shape
   var points := shape.points
   for i in points.size(): points[i].y-=.18
   shape.points=points;rock.shadow.update_shadow();entrance_rocks103+=1
 var atlas := _textures87("woodland_plants87")
 for anchor in [Vector2(11.4,13.6),Vector2(14.5,14.4),Vector2(17.,15.3),Vector2(20.5,6.7),Vector2(23.8,8.1),Vector2(25.6,10.4),Vector2(10.4,10.9)]:
  for i in 3:
   var local: Vector2=anchor+Vector2(sin(i*2.2+anchor.y)*.8,cos(i*2.6)*.65)
   var at := g+local
   if ENTRY103.corridor103(local).x<2.5 or world.meadow.route_distance(at)<1.7: continue
   var overlap := false
   for plant in plants87:
    if Vector2(plant.position.x,plant.position.z).distance_to(at)<.70: overlap=true;break
   for rock in rocks87:
    if ((at-rock.at)/Vector2(rock.width*.52,rock.width*.27)).length()<1.: overlap=true;break
   if overlap: continue
   var width := 1.5 if i==0 else 1.05
   var plant := _sprite87(atlas[1 if i==0 else 2],at,width,"EntranceBank103")
   plant.material_override=_plant_material94(plant.texture);plant.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
   plants87.append(plant);plants94.append({"visual":plant,"push":Vector3.ZERO,"radius":.95});entrance_plants103+=1
 var contacts := SurfaceTool.new();contacts.begin(Mesh.PRIMITIVE_TRIANGLES)
 for rock in rocks87: _contact87(contacts,rock.at+Vector2(0,.1),rock.width*.86,rock.width*.35)
 for plant in plants87: _contact87(contacts,Vector2(plant.position.x,plant.position.z),.65,.34)
 get_node("SoftGroundContacts87").mesh=contacts.commit()
 print("ENTRANCE103 rocks=",entrance_rocks103," plants=",entrance_plants103)
