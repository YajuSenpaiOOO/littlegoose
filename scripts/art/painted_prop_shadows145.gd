extends Node
## Common opt-in route for solid painted props, with deduplication and cleanup.
const PROJECTOR145=preload("res://scripts/art/grounded_prop_shadow145.gd")
var world: Node3D
var registered145: Dictionary={}
func _ready() -> void:
 name="AutomaticPaintedPropShadows145"
 get_tree().node_added.connect(_node_added145)
 scan145(world)
func scan145(node: Node) -> void:
 if node is Sprite3D and node.get_meta("painted_prop_shadow",false): register145(node)
 for child in node.get_children(): scan145(child)
func _node_added145(node: Node) -> void:
 if node is Sprite3D and node.get_meta("painted_prop_shadow",false): register145.call_deferred(node)
func register145(sprite: Sprite3D) -> void:
 if not is_instance_valid(sprite) or not sprite.is_inside_tree(): return
 var id := sprite.get_instance_id()
 if registered145.has(id): return
 var shadow: MeshInstance3D
 for candidate in get_tree().get_nodes_in_group("painted_prop_projectors"):
  if candidate.visual==sprite: shadow=candidate;break
 if shadow==null:
  shadow=PROJECTOR145.new();shadow.world=world;shadow.visual=sprite;add_child(shadow)
 else:
  var was_enabled: bool=shadow.enabled
  shadow.set_script(PROJECTOR145);shadow.world=world;shadow.visual=sprite;shadow.enabled=was_enabled
  shadow.ink=shadow.material_override;shadow.cache_key=[]
 shadow.update_shadow();registered145[id]=shadow
 sprite.tree_exiting.connect(_remove145.bind(id),CONNECT_ONE_SHOT)
 if is_instance_valid(world.breeze143): world.breeze143.bind143(shadow.ink)
func _remove145(id: int) -> void:
 if registered145.has(id):
  var shadow: Node=registered145[id]
  if is_instance_valid(shadow): shadow.queue_free()
  registered145.erase(id)
