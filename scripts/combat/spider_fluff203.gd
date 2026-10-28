extends Node3D
var world: Node3D
var motes: Array=[]
var emitted203 := 0
var rng := RandomNumberGenerator.new()
func _ready() -> void: rng.seed=203
func burst(at: Vector3,direction: Vector3,finishing: bool) -> void:
 var right: Vector3=world.camera.global_basis.x;var up: Vector3=world.camera.global_basis.y
 for i in (7 if finishing else 4):
  if motes.size()>=48: break
  var tuft := MeshInstance3D.new();var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
  # Three stepped pixel clusters, not liquid droplets or round smoke puffs.
  for rect in [Rect2(-.045,-.02,.09,.04),Rect2(-.02,-.045,.04,.09),Rect2(.015,.015,.04,.035)]:
   for uv in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
    var p: Vector2=rect.position+rect.size*uv;st.add_vertex(Vector3(p.x,p.y,0))
  tuft.mesh=st.commit();tuft.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  var material := StandardMaterial3D.new();material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;material.cull_mode=BaseMaterial3D.CULL_DISABLED
  var color: Color=[Color("fff1dc"),Color("dbc3e5"),Color("b19acb")][i%3]
  tuft.material_override=material;tuft.position=at;add_child(tuft)
  tuft.global_basis=world.camera.global_basis
  var velocity: Vector3=right*rng.randf_range(-.75,.75)+up*rng.randf_range(.45,1.1)+direction.normalized()*.25
  motes.append({"node":tuft,"velocity":velocity,"age":0.,"life":rng.randf_range(.4,.65),"color":color});emitted203+=1
func clear203() -> void:
 for entry in motes: entry.node.queue_free()
 motes.clear()
func _process(delta: float) -> void:
 for i in range(motes.size()-1,-1,-1):
  var entry: Dictionary=motes[i];entry.age+=delta
  if entry.age>=entry.life: entry.node.queue_free();motes.remove_at(i);continue
  entry.velocity-=Vector3.UP*delta*.6;entry.node.position+=entry.velocity*delta
  var shade: Color=world.combat_tint111.color;shade.b=minf(shade.b,maxf(shade.r,shade.g)*1.25)
  var color: Color=entry.color*shade;color.a=1.-smoothstep(.5,1.,entry.age/entry.life)
  entry.node.material_override.albedo_color=color
