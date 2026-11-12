extends "res://scripts/art/paper_stage326.gd"

var castle_target327: Area3D

func _ready() -> void:
 super._ready()
 # The batteries stand ahead of the blocking scenery so both muzzles are clear.
 for cannon in cannons326:
  var old := cannon.position
  var foot := old + Vector3(0.,0.,.9)
  foot.y = ground298(foot.x,foot.z)
  var shift := foot-old
  cannon.position = foot
  var index := cannons326.find(cannon)
  cannon_areas326[index].position += shift
  (scenery_shapes322[cannon].get_parent() as Node3D).position += shift
 castle_target327 = Area3D.new()
 castle_target327.collision_layer = 0
 castle_target327.collision_mask = 0
 castle_target327.monitoring = false
 castle.add_child(castle_target327)
 # Separate wall bays follow the painted silhouette instead of a full image rectangle.
 for rect in [Rect2(225,185,219,715),Rect2(444,450,234,450),Rect2(678,530,399,370),Rect2(1077,600,190,300),Rect2(1267,730,205,170)]:
  var holder := CollisionShape3D.new()
  var box := BoxShape3D.new()
  box.size = Vector3(rect.size.x * castle.pixel_size,rect.size.y * castle.pixel_size,.14)
  holder.shape = box
  var center: Vector2 = rect.get_center()
  holder.position = Vector3((center.x-837.5)*castle.pixel_size,(928.-center.y)*castle.pixel_size,.035)
  castle_target327.add_child(holder)

func sample_entry313(_t: float) -> void:
 if is_instance_valid(dinosaur313): dinosaur313.hide()
 if is_instance_valid(packet313): packet313.hide()
 if is_instance_valid(handler313): handler313.hide()
 if is_instance_valid(line313): line313.hide()

func sample(t: float) -> void:
 super.sample(t)
 if t >= 4.02:
  pixel_pose315()

func _process(delta: float) -> void:
 super._process(delta)
 if playing and age >= 4.05:
  cancel()
  finished = true

func enable_castle327(enabled: bool) -> void:
 if is_instance_valid(castle_target327):
  castle_target327.set_deferred("collision_layer",8 if enabled else 0)

func reset_battle314() -> void:
 super.reset_battle314()
 enable_castle327(false)

func make_flight327(at: Vector3, meteor: bool) -> Sprite3D:
 if not meteor:
  return make_shell326(at)
 var sprite := card298(preload("res://assets/paper_stage314/meteor.png"),{"span":[806.],"foot":[587.,896.]},1.9,self)
 sprite.rotation.x = deg_to_rad(-25.)
 sprite.global_position = at
 return sprite

func make_ring327(parent: Node3D = self) -> MeshInstance3D:
 var ring := MeshInstance3D.new()
 ring.mesh = ImmediateMesh.new()
 ring.material_override = shock326.material_override
 ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 parent.add_child(ring)
 return ring

func paint_ring327(ring: MeshInstance3D, at: Vector2, radius: float, alpha: float) -> void:
 ring.visible = alpha > 0.
 var mesh := ring.mesh as ImmediateMesh
 mesh.clear_surfaces()
 if alpha <= 0.:
  return
 mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 40:
  var a := TAU*float(i)/40.
  var b := TAU*float(i+1)/40.
  var corners: Array[Vector3] = []
  for spec in [Vector2(a,radius),Vector2(b,radius),Vector2(a,maxf(0.,radius-.13)),Vector2(b,maxf(0.,radius-.13))]:
   var p: Vector2 = at+Vector2(cos(spec.x),sin(spec.x))*spec.y
   corners.append(ring.to_local(Vector3(p.x,battle.floor_height(p)+.05,p.y)))
  for vertex in [0,1,2,2,1,3]:
   mesh.surface_set_color(Color(1.,.76,.43,alpha))
   mesh.surface_add_vertex(corners[vertex])
 mesh.surface_end()

func make_blast327(at: Vector2, width: float) -> Dictionary:
 var root := Node3D.new()
 add_child(root)
 var boom := card298(preload("res://assets/paper_stage314/boom.png"),{"span":[1308.],"foot":[768.,995.]},width,root)
 boom.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
 boom.material_override.albedo_color = Color.WHITE
 boom.global_position = Vector3(at.x,battle.floor_height(at)+.08,at.y)
 return {"root":root,"boom":boom,"ring":make_ring327(root)}
