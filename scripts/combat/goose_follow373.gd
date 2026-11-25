extends CharacterBody3D
var host: Node3D
var visual: Sprite3D
var atlas373: Dictionary={}
var follow373:=true
var mode373:="follow"
var moving373:=false
var direction373:="down"
var clock373:=0.
var grid373:=AStarGrid2D.new()
var route373:=PackedVector2Array()
var repath373:=0.
var destination373:=Vector3.ZERO
var arrived373:=false
var ready373:=false
var seen_frames373: Dictionary={}
func setup373() -> void:
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/black_goose_walk373/frames.json"))
 for key in data:
  var row: Dictionary=data[key];var sheet: Texture2D=host.room.source356("res://assets/black_goose_walk373/"+row.file)
  var frames: Array[Texture2D]=[]
  for i in 4:
   var t:=AtlasTexture.new();t.atlas=sheet;t.region=Rect2(i*row.cell[0],0,row.cell[0],row.cell[1]);t.filter_clip=true;frames.append(t)
  atlas373[key]={"frames":frames,"foot":Vector2(row.foot[0],row.foot[1]),"height":float(row.height)}
 for i in 3:await get_tree().physics_frame
 grid373.region=Rect2i(Vector2i.ZERO,navigation_size373());grid373.cell_size=Vector2(.28,.28);grid373.offset=navigation_offset373();grid373.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES;grid373.update()
 var capsule:=CapsuleShape3D.new();capsule.radius=.24;capsule.height=.68
 var query:=PhysicsShapeQueryParameters3D.new();query.shape=capsule;query.collision_mask=collision_mask;query.exclude=[get_rid(),host.hero.get_rid()]
 query.exclude+=navigation_floor_bodies373()
 var space:=get_world_3d().direct_space_state
 for y in grid373.region.size.y:
  for x in grid373.region.size.x:
   var at: Vector2=grid373.get_point_position(Vector2i(x,y));query.transform=Transform3D(Basis.IDENTITY,Vector3(at.x,navigation_height373(at)+.42,at.y))
   grid373.set_point_solid(Vector2i(x,y),not space.intersect_shape(query,1).is_empty())
 ready373=true
func navigation_size373() -> Vector2i:
 return Vector2i(44,36)

func navigation_offset373() -> Vector2:
 return Vector2(-6.,-4.)

func navigation_height373(_at: Vector2) -> float:
 return 0.

func navigation_floor_bodies373() -> Array[RID]:
 return []

func nearest373(at: Vector3) -> Vector2i:
 var best:=Vector2i.ZERO;var distance:=INF
 for y in grid373.region.size.y:
  for x in grid373.region.size.x:
   var id:=Vector2i(x,y)
   if grid373.is_point_solid(id):continue
   var d:=grid373.get_point_position(id).distance_squared_to(Vector2(at.x,at.z))
   if d<distance:distance=d;best=id
 return best
func hold373() -> void:
 mode373="hold";moving373=false;route373.clear();velocity=Vector3.ZERO
func resume373() -> void:
 mode373="follow";arrived373=false;repath373=0.
func stage373(at: Vector3) -> void:
 mode373="stage";destination373=at;arrived373=false;repath373=0.;moving373=true
func face373(at: Vector3) -> void:
 var delta:=at-global_position
 if absf(delta.x)>absf(delta.z):direction373="right" if delta.x>0. else "left"
 else:direction373="down" if delta.z>0. else "up"
func _physics_process(delta: float) -> void:
 if not ready373:return
 clock373+=delta
 var target: Vector3=host.hero.global_position if mode373=="follow" else destination373
 var distance:=Vector2(target.x-global_position.x,target.z-global_position.z).length()
 if mode373=="hold" or host.sleeping362 or host.leaving371:
  moving373=false;route373.clear()
 elif mode373=="follow":
  if distance>1.5:moving373=true
  elif distance<.95:moving373=false;route373.clear()
 else:
  if distance<.28:moving373=false;arrived373=true;mode373="hold";face373(host.hero.global_position)
 if moving373:
  repath373-=delta
  if repath373<=0.:
   route373=grid373.get_point_path(nearest373(global_position),nearest373(target));repath373=.4
   if route373.size()>0:route373.remove_at(0)
  while route373.size()>0 and Vector2(global_position.x,global_position.z).distance_to(route373[0])<.12:route373.remove_at(0)
  if route373.size()>0:
   var step:=Vector3(route373[0].x-global_position.x,0.,route373[0].y-global_position.z).normalized()
   var speed: float=3.5 if mode373=="follow" and distance>3. else 2.5
   velocity.x=step.x*speed;velocity.z=step.z*speed;face373(global_position+step)
  else:velocity.x=0.;velocity.z=0.
 else:velocity.x=0.;velocity.z=0.
 velocity.y=-.4;var before:=global_position;move_and_slide()
 advance_gait373(Vector2(global_position.x-before.x,global_position.z-before.z).length())
 var walking: bool=Vector2(global_position.x-before.x,global_position.z-before.z).length()>.0005
 apply_frame373(frame_index373(walking))
func frame_index373(walking: bool) -> int:
 return 1+int(clock373*8.)%3 if walking else 0
func apply_frame373(frame: int) -> void:
 var row: Dictionary=atlas373[direction373]
 seen_frames373[direction373+str(frame)]=true
 visual.texture=row.frames[frame];visual.pixel_size=1.44/row.height;visual.offset=Vector2(visual.texture.get_width()*.5-row.foot.x,row.foot.y-visual.texture.get_height()*.5)
 var material: StandardMaterial3D=visual.material_override;material.albedo_texture=visual.texture.atlas

func advance_gait373(_distance: float) -> void:pass
