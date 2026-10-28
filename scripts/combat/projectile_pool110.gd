extends RefCounted
# Physics remains native ray queries; bullets themselves need no scene nodes.
class ShadowState:
 extends RefCounted
 class SizeState:
  extends RefCounted
  var size := Vector2(.28,.18)
 var mesh := SizeState.new()
 var material_override := RefCounted.new()
 var cast_shadow := 0
 func get_parent() -> Variant: return null
 func hide() -> void: pass
class BulletState:
 extends RefCounted
 var at := Vector3.ZERO
 var previous := Vector3.ZERO
 var position: Vector3:
  get: return at
  set(value):
   previous=at
   at=value
 var global_position: Vector3:
  get: return at
  set(value): position=value
 var cast_shadow := 0
 var mesh: Variant=null
 var material_override: Variant=null
 var basis := Basis.IDENTITY
 var scale := Vector3.ONE
 var physics_interpolation_mode := 1
 var shadow := ShadowState.new()
 func reset_physics_interpolation() -> void: previous=at
 func get_global_transform_interpolated() -> Transform3D:
  return Transform3D(Basis.IDENTITY,previous.lerp(at,Engine.get_physics_interpolation_fraction()))
 func add_child(_child: Variant) -> void: pass
class ArtState:
 extends RefCounted
 var battle: Variant
 var at := Vector3.ZERO
 var follow: Variant
 var projectile := true
 var age := 0.
 var scale_gain := 1.
 var modulate := Color.WHITE
 var facing := Vector2.RIGHT
 func is_processing() -> bool: return false
var nodes: Array[BulletState]=[]
var arts: Array[ArtState]=[]
var records: Array[Dictionary]=[]
var births := 0
var reused := 0
const IDLE_LIMIT := 1024
func take_node() -> BulletState:
 var node: BulletState
 if nodes.is_empty(): node=BulletState.new();births+=1
 else: node=nodes.pop_back();reused+=1
 node.mesh=null;node.basis=Basis.IDENTITY;node.scale=Vector3.ONE;return node
func record(node: Variant,velocity: Vector3) -> Dictionary:
 var result: Dictionary={} if records.is_empty() else records.pop_back()
 result.clear();result.node=node;result.velocity=velocity;result.life=3.;return result
func take_art(world: Node3D) -> ArtState:
 var art: ArtState=ArtState.new() if arts.is_empty() else arts.pop_back()
 art.battle=world;art.at=Vector3.ZERO;art.follow=null;art.projectile=false;art.age=0.;art.scale_gain=1.;art.modulate=Color.WHITE
 art.set_meta("batched105",true);return art
func retire(shot: Dictionary) -> void:
 var node: BulletState=shot.node
 var art: ArtState=shot.get("art")
 if art!=null: art.follow=null;art.battle=null
 if nodes.size()<IDLE_LIMIT:
  nodes.append(node)
  if art!=null: arts.append(art)
  records.append(shot)
func dispose() -> void:
 nodes.clear();arts.clear();records.clear()
