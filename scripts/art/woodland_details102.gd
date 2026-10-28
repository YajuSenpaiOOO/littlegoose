extends "res://scripts/art/woodland_details101.gd"
var mushrooms102: Array[Node3D]=[]
var cones102: Array[RigidBody3D]=[]
var cone_cool102: Array[float]=[]
var leaf_batches102: Array[MultiMeshInstance3D]=[]
var leaf_textures102: Array[Texture2D]=[]
var leaf_states102: Array[Dictionary]=[]
var leaf_kicks102 := 0
var cone_kicks102 := 0
var leaf_updates102 := 0
var active102 := false
var scope_wait102 := 0.
var leaf_clock102 := 0.
var cap102: ShaderMaterial
var stem102: ShaderMaterial
var cone_mesh102: ArrayMesh
var cone_material102: ShaderMaterial
func _audio_script101() -> Script: return preload("res://scripts/art/woodland_audio102.gd")
func _material102(color: Color) -> ShaderMaterial:
 var mat := ShaderMaterial.new();mat.shader=preload("res://scripts/art/small_props102.gdshader");mat.set_shader_parameter("base_color",color);world.porch49.shade_material(mat);return mat
func _mesh102(mesh: Mesh,parent: Node3D,material: Material,at := Vector3.ZERO) -> MeshInstance3D:
 var node := MeshInstance3D.new();node.mesh=mesh;node.material_override=material;node.position=at;node.visibility_range_end=40.;parent.add_child(node);return node
func _cap_mesh102() -> ArrayMesh:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rings := [Vector2(0,.11),Vector2(.50,.09),Vector2(.91,.045),Vector2(1.,0.),Vector2(.83,-.022),Vector2(.24,-.035)]
 for row in rings.size()-1:
  for segment in 10:
   for corner in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
    var ring: Vector2=rings[row+corner.y];var a: float=TAU*(segment+corner.x)/10.
    var shade := .90+.10*sin(segment*2.7+row*.6)
    st.set_color(Color(shade,shade,shade));st.add_vertex(Vector3(cos(a)*ring.x*.15,ring.y,sin(a)*ring.x*.15))
 st.generate_normals();return st.commit()
func _prop(at: Vector2,kind: int,_width: float) -> void:
 if cap102==null:
  cap102=_material102(Color(.43,.29,.14));stem102=_material102(Color(.71,.67,.47));cone_material102=_material102(Color(.38,.25,.12));cone_mesh102=_cone_mesh102()
 if kind==1:
  for i in 2: _cone102(at+Vector2((i-.5)*.42,.12*sin(i*2.3)))
  return
 var group := Node3D.new();group.name="UprightMushrooms102";group.position=point(at);add_child(group);mushrooms102.append(group)
 var cap := _cap_mesh102()
 for i in 3:
  var size := 1.-i*.18;var offset := Vector3((i-1)*.19,0,sin(i*2.3)*.09)
  var stalk := CylinderMesh.new();stalk.top_radius=.037*size;stalk.bottom_radius=.045*size;stalk.height=.20*size;stalk.radial_segments=8
  _mesh102(stalk,group,stem102,offset+Vector3.UP*.10*size)
  var crown := _mesh102(cap,group,cap102,offset+Vector3.UP*.20*size);crown.scale=Vector3(size,size,size);crown.rotation=Vector3(.07*sin(i),i*2.7,.08*cos(i))
func _cone_mesh102() -> ArrayMesh:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for row in 7:
  var y := -.42+row*.14;var radius := .39*sin(PI*(row+.85)/8.5)
  for segment in 8:
   var angle := TAU*(segment+float(row%2)*.5)/8.
   var tangent := Vector3(-sin(angle),0,cos(angle));var outward := Vector3(cos(angle),0,sin(angle))
   var centre := outward*radius+Vector3.UP*y
   var points := [centre+tangent*.12+Vector3.UP*.085,centre-tangent*.12+Vector3.UP*.085,centre+outward*.12-Vector3.UP*.08,centre-outward*.10]
   for tri in [Vector3i(0,1,2),Vector3i(1,0,3),Vector3i(0,2,3),Vector3i(2,1,3)]:
    var shade := .82+float((segment+row)%3)*.12
    st.set_color(Color(shade,shade,shade))
    for index in [tri.x,tri.y,tri.z]: st.add_vertex(points[index])
 st.generate_normals();return st.commit()
func _cone102(at: Vector2) -> void:
 var body := RigidBody3D.new();body.name="KickableSinglePinecone102";body.position=point(at,.13)
 body.mass=.08;body.linear_damp=1.2;body.angular_damp=2.;body.collision_layer=32;body.collision_mask=3|32;body.continuous_cd=true
 var material := PhysicsMaterial.new();material.friction=.9;material.bounce=.12;body.physics_material_override=material
 var shape := SphereShape3D.new();shape.radius=.095;var collision := CollisionShape3D.new();collision.shape=shape;body.add_child(collision)
 var visual := _mesh102(cone_mesh102,body,cone_material102);visual.scale=Vector3.ONE*.21;visual.rotation=Vector3(.9,rng.randf()*TAU,.3)
 add_child(body);cones102.append(body);cone_cool102.append(0.)
func _split_leaves102() -> void:
 var atlas: Texture2D=load("res://assets/woodland101/woodland_details101.png");var half := atlas.get_width()/2
 var cell := atlas.get_image().get_region(Rect2i(0,half,half,half))
 for seed in [Vector2(.28,.24),Vector2(.64,.18),Vector2(.51,.47),Vector2(.25,.63),Vector2(.81,.47),Vector2(.68,.73)]:
  var start := Vector2i(seed*half)
  # Alpha-connected components isolate each existing leaf without repainting.
  var queue: Array[Vector2i]=[start];var seen := {start:true};var cursor := 0;var bounds := Rect2i(start,Vector2i.ONE)
  while cursor<queue.size():
   var pixel: Vector2i=queue[cursor];cursor+=1
   if cell.get_pixelv(pixel).a<.5: continue
   bounds=bounds.expand(pixel)
   for direction in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
    var next: Vector2i=pixel+direction
    if next.x<0 or next.y<0 or next.x>=half or next.y>=half or seen.has(next): continue
    seen[next]=true;queue.append(next)
  var tex := AtlasTexture.new();tex.atlas=atlas;tex.region=Rect2(Vector2i(0,half)+bounds.position,bounds.size+Vector2i.ONE);leaf_textures102.append(tex)
func _leaf_mesh102(texture: Texture2D) -> ArrayMesh:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for tri in [[Vector2(0,0),Vector2(.5,.5),Vector2(1,0)],[Vector2(1,0),Vector2(.5,.5),Vector2(1,1)],[Vector2(1,1),Vector2(.5,.5),Vector2(0,1)],[Vector2(0,1),Vector2(.5,.5),Vector2(0,0)]]:
  for uv in tri:
   st.set_uv(uv);st.set_normal(Vector3.UP);st.add_vertex(Vector3((uv.x-.5),.09 if uv==Vector2(.5,.5) else 0.,(uv.y-.5)*texture.get_height()/texture.get_width()))
 return st.commit()
func _leaf(at: Vector2,width: float) -> void:
 if leaf_textures102.is_empty():
  _split_leaves102()
  for texture in leaf_textures102:
   var poses: Array[Transform3D]=[]
   var mat := ShaderMaterial.new();mat.shader=preload("res://scripts/art/woodland_floor101.gdshader");mat.set_shader_parameter("paint",texture);world.porch49.shade_material(mat)
   leaf_batches102.append(_batch(_leaf_mesh102(texture),poses,mat,false))
 for i in 24:
  var offset := Vector2(rng.randf_range(-.5,.5),rng.randf_range(-.4,.4))*width
  var centre := at+offset;var variant := leaf_states102.size()%6
  leaf_states102.append({"at":centre,"velocity":Vector2.ZERO,"lift":0.,"bed":float(i)*.0012,"vertical":0.,"angle":rng.randf()*TAU,"size":rng.randf_range(.12,.20),"variant":variant,"index":leaf_states102.size()/6,"cool":0.,"moving":false})
func _ready() -> void:
 super._ready()
 name="InteractiveWoodlandDetails102"
 for batch in leaf_batches102: batch.multimesh.instance_count=leaf_states102.size()/6
 for leaf in leaf_states102: _leaf_pose102(leaf)
func _leaf_pose102(leaf: Dictionary) -> void:
 var pos := point(leaf.at,.018+leaf.bed+leaf.lift)
 var basis := (Basis(Vector3.UP,leaf.angle)*Basis(Vector3.RIGHT,sin(leaf.angle*2.)*minf(leaf.lift*5.,.5))).scaled(Vector3.ONE*leaf.size)
 leaf_batches102[leaf.variant].multimesh.set_instance_transform(leaf.index,Transform3D(basis,pos-Vector3(grove.x,0,grove.y)))
func _physics_process(delta: float) -> void:
 scope_wait102-=delta
 if scope_wait102<=0.:
  scope_wait102=.25
  active102=world.hero.position.distance_to(point(Vector2(1,2)))<24. and world.effect_scope95.near_view95(point(Vector2(1,2)),14.)
  if not active102:
   for leaf in leaf_states102:
    if leaf.moving: leaf.velocity=Vector2.ZERO;leaf.lift=0.;leaf.vertical=0.;leaf.moving=false;_leaf_pose102(leaf)
 if not active102: return
 var hero := Vector2(world.hero.position.x,world.hero.position.z);var direction := Vector2(world.hero.velocity.x,world.hero.velocity.z)
 _step_cones102(delta,hero,direction)
 leaf_clock102+=delta
 if leaf_clock102<1./30.: return
 var dt := minf(leaf_clock102,.08);leaf_clock102=0.
 var disturbed := false
 for leaf in leaf_states102:
  leaf.cool=maxf(0.,leaf.cool-dt)
  var away: Vector2=grove+leaf.at-hero
  if direction.length()>.5 and away.length()<.55 and absf(world.hero.position.y-point(leaf.at).y)<.35 and leaf.cool<=0.:
   leaf.velocity=(away.normalized()*.8+direction.normalized()*.6)*rng.randf_range(.7,1.25);leaf.vertical=rng.randf_range(.65,1.15);leaf.moving=true;leaf.cool=.4;leaf_kicks102+=1;disturbed=true
  if not leaf.moving: continue
  var wanted: Vector2=leaf.at+leaf.velocity*dt
  if world.meadow.normal_at(grove.x+wanted.x,grove.y+wanted.y,true).y>.94 and not world.PARK99.on_stairs99(wanted): leaf.at=wanted
  else: leaf.velocity=Vector2.ZERO
  leaf.velocity=leaf.velocity.move_toward(Vector2.ZERO,dt*1.7);leaf.vertical-=3.6*dt;leaf.lift=maxf(0.,leaf.lift+leaf.vertical*dt);leaf.angle+=leaf.velocity.length()*dt*2.1
  if leaf.lift<=0. and leaf.velocity.length()<.025: leaf.moving=false;leaf.vertical=0.
  _leaf_pose102(leaf);leaf_updates102+=1
 if disturbed: audio.rustle102(world.hero.position,true)

func _edges() -> void:
 super._edges()
 for i in grass.multimesh.instance_count:
  var pose := grass.multimesh.get_instance_transform(i)
  var point: Vector3=grass.to_global(pose.origin)
  if world.forest87.slab102(Vector2(point.x,point.z)-grove):
   pose.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);grass.multimesh.set_instance_transform(i,pose)

func _step_cones102(delta: float,hero: Vector2,direction: Vector2) -> void:
 for i in cones102.size():
  cone_cool102[i]=maxf(0.,cone_cool102[i]-delta)
  var cone := cones102[i];var away := Vector2(cone.position.x,cone.position.z)-hero
  if direction.length()>.5 and away.length()<.48 and absf(world.hero.position.y-(cone.position.y-.1))<.45 and cone_cool102[i]<=0. and direction.dot(away)>-.15:
   cone.sleeping=false;var kick := (direction.normalized()*.7+away.normalized()*.3).normalized()
   cone.apply_central_impulse(Vector3(kick.x,.38,kick.y)*.13);cone.apply_torque_impulse(Vector3(kick.y,0,-kick.x)*.003)
   cone_cool102[i]=.45;cone_kicks102+=1
