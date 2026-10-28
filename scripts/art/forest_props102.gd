extends "res://scripts/art/forest_props99.gd"
func slab102(p: Vector2) -> bool:
 var stair := PARK99.to_stair99(p)
 var flight := absf(stair.x-PARK99.STAIR_X)<2. and stair.y>PARK99.STAIR_TOP-.35 and stair.y<PARK99.STAIR_FOOT+1.1
 return ((p-PARK99.DECK)/Vector2(3.7,3.)).length()<1. or flight
func _flower_support94(at: Vector2) -> bool:
 return not slab102(at-Vector2(world.meadow.landmarks.grove)) and super._flower_support94(at)
func _ready() -> void:
 super._ready()
 var g: Vector2=world.meadow.landmarks.grove
 var keep: Array[Sprite3D]=[]
 for plant in plants87:
  if slab102(Vector2(plant.position.x,plant.position.z)-g): plant.queue_free()
  else: keep.append(plant)
 plants87=keep
 var reactive: Array[Dictionary]=[]
 for plant in plants94:
  if keep.has(plant.visual): reactive.append(plant)
 plants94=reactive
 var contacts := SurfaceTool.new();contacts.begin(Mesh.PRIMITIVE_TRIANGLES)
 for rock in rocks87: _contact87(contacts,rock.at+Vector2(0,.1),rock.width*.86,rock.width*.35)
 for plant in plants87: _contact87(contacts,Vector2(plant.position.x,plant.position.z),.65,.34)
 get_node("SoftGroundContacts87").mesh=contacts.commit()
