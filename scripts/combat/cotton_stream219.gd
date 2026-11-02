extends Node3D
## Pooled data records + three MultiMeshes. No scene node/physics body per tuft.
const CAP_DANGER=48
const CAP_DECOR=96
var world: Node3D
var pig: Node3D
var running := true
var enabled219 := true
var stress219 := false
var manual219 := false
var records: Array[Dictionary]=[]
var active: Array[int]=[]
var free_danger: Array[int]=[]
var free_decor: Array[int]=[]
var batches: Array[MultiMeshInstance3D]=[]
var emitted := [0,0]
var nose_count := [0,0]
var hit_count := 0
var dodge_count := 0
var guard_count := 0
var parry_count := 0
var walls_count := 0
var invuln := 0.
var update_us := 0
var upload_us := 0
var peak_active := 0
var cpu_samples: Array[int]=[]
func _ready() -> void:
 for i in CAP_DANGER+CAP_DECOR:
  records.append({"pos":Vector3.ZERO,"vel":Vector3.ZERO,"age":0.,"life":1.8,"radius":.19,"type":0,"danger":i<CAP_DANGER,"angle":0.,"seed":float(i)})
  if i<CAP_DANGER:free_danger.append(i)
  else:free_decor.append(i)
 var texture: Texture2D=load("res://assets/pig219/cotton.png")
 var layout=JSON.parse_string(FileAccess.get_file_as_string("res://assets/pig219/layout.json"))
 for f in layout.cotton.frames:
  var rect: Array=f.region
  var batch=MultiMeshInstance3D.new();batch.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  var mesh=QuadMesh.new();mesh.size=Vector2(float(rect[2])/float(rect[3]),1.)
  var mat=ShaderMaterial.new();mat.shader=preload("res://scripts/art/cotton219.gdshader")
  mat.set_shader_parameter("paint",texture);mat.set_shader_parameter("region219",Vector4(rect[0]/float(texture.get_width()),rect[1]/float(texture.get_height()),rect[2]/float(texture.get_width()),rect[3]/float(texture.get_height())))
  mesh.material=mat
  var mm=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true;mm.mesh=mesh;mm.instance_count=CAP_DANGER+CAP_DECOR;mm.visible_instance_count=0
  batch.multimesh=mm;add_child(batch);batches.append(batch)
func clear219() -> void:
 active.clear();free_danger.clear();free_decor.clear()
 for i in records.size():
  if i<CAP_DANGER:free_danger.append(i)
  else:free_decor.append(i)
 for batch in batches:batch.multimesh.visible_instance_count=0
 invuln=0.
func counts219() -> Vector2i:
 return Vector2i(CAP_DANGER-free_danger.size(),CAP_DECOR-free_decor.size())
func emit219(at: Vector3,direction: Vector2,nose: int) -> void:
 if not enabled219 or not running:return
 var count=counts219()
 if count.x>=(48 if stress219 else 16) or free_danger.is_empty():return
 var slot: int=free_danger.pop_back();var e: Dictionary=records[slot]
 var dir=direction.rotated(sin(float(emitted[0])*.9)*.07)
 e.pos=at;e.vel=Vector3(dir.x,0.,dir.y)*2.5;e.age=0.;e.life=1.8;e.type=emitted[0]%2;e.angle=sin(float(emitted[0]))*.35
 active.append(slot);emitted[0]+=1;nose_count[nose]+=1
 for i in 2:
  if counts219().y>=(96 if stress219 else 32) or free_decor.is_empty():break
  var small: int=free_decor.pop_back();var d: Dictionary=records[small]
  d.pos=at;d.vel=Vector3(dir.x,.20+float(i)*.15,dir.y).rotated(Vector3.UP,(-.22 if i==0 else .22))*1.5;d.age=0.;d.life=.85;d.type=2;d.angle=float(emitted[1])*1.7
  active.append(small);emitted[1]+=1
 peak_active=maxi(peak_active,active.size())
func retire219(index: int) -> void:
 var slot=active[index]
 if slot<CAP_DANGER:free_danger.append(slot)
 else:free_decor.append(slot)
 active.remove_at(index)
func contact219() -> String:
 if world.hero.dodge_invulnerability>0.:
  dodge_count+=1;return "dodge"
 if world.hero.can_parry():
  world.hero.consume_parry();parry_count+=1;world.notice219("弹开一团棉花");return "parry"
 if world.hero.guarding109:
  guard_count+=1;return "guard"
 if invuln<=0.:
  invuln=.7;hit_count+=1;world.hearts219=maxi(0,world.hearts219-1);world.notice219("被棉团碰到了 · 仅扣试演心心")
 return "hit"
func advance219(delta: float) -> void:
 if not running or not enabled219:return
 var begin=Time.get_ticks_usec()
 invuln=maxf(0.,invuln-delta)
 for index in range(active.size()-1,-1,-1):
  var slot=active[index];var e: Dictionary=records[slot]
  var before: Vector3=e.pos
  e.age+=delta
  e.vel*=exp(-.40*delta)
  e.pos+=e.vel*delta
  if e.age>=e.life:
   retire219(index);continue
  if not e.danger:continue
  var at=Vector2(e.pos.x,e.pos.z)
  var ground: float=world.floor_height(at)
  if e.pos.y<ground+.03 or e.pos.y>ground+1.4:
   walls_count+=1;retire219(index);continue
  var ray=PhysicsRayQueryParameters3D.create(before,e.pos,1,[world.hero.get_rid(),pig.body.get_rid()])
  if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
   walls_count+=1;retire219(index);continue
  var hero_at=Vector2(world.hero.position.x,world.hero.position.z)
  var closest=Geometry2D.get_closest_point_to_segment(hero_at,Vector2(before.x,before.z),at)
  if closest.distance_squared_to(hero_at)<pow(float(e.radius)+.24,2.) and e.pos.y>=world.hero.position.y-.1 and e.pos.y<=world.hero.position.y+1.15:
   contact219();retire219(index)
 update_us=Time.get_ticks_usec()-begin
 if cpu_samples.size()<10000:cpu_samples.append(update_us)
func _physics_process(delta: float) -> void:
 if not manual219:advance219(delta)
func _process(_delta: float) -> void:
 if not is_instance_valid(world.camera):return
 var begin=Time.get_ticks_usec()
 var counts=[0,0,0]
 var normal=world.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))
 for batch in batches:batch.multimesh.mesh.material.set_shader_parameter("normal219",normal.normalized())
 for slot in active:
  var e: Dictionary=records[slot];var type: int=e.type
  var scale219=(.34 if e.danger else .10)*(1.-smoothstep(float(e.life)*.75,float(e.life),float(e.age))*.75)
  var basis219=Basis(world.camera.global_basis.z,float(e.angle)+float(e.age)*.7)*world.camera.global_basis
  var transform=Transform3D(basis219.scaled(Vector3.ONE*scale219),e.pos)
  var mm=batches[type].multimesh
  mm.set_instance_transform(counts[type],transform)
  mm.set_instance_color(counts[type],Color.WHITE if e.danger else Color(.76,.73,.83,1.))
  counts[type]+=1
 for i in 3:batches[i].multimesh.visible_instance_count=counts[i]
 upload_us=Time.get_ticks_usec()-begin
