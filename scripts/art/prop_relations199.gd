extends Node
var world: Node3D
var cards: Array[Dictionary]=[]
var shadow_pairs: Array[Dictionary]=[]
var sight_trees199: Array[Dictionary]=[]
var root_feet199: Array[Vector3]=[]
func bind_card199(sprite: Sprite3D,foot: Vector3,lit := true) -> void:
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/card_depth199.gdshader")
 if not lit:
  var source := Shader.new()
  source.code=ink.shader.code.replace("render_mode cull_disabled;","render_mode unshaded,cull_disabled;")
  ink.shader=source
 ink.set_shader_parameter("paint",sprite.texture);ink.set_shader_parameter("foot199",foot)
 sprite.material_override=ink;sprite.extra_cull_margin=4.
 cards.append({"sprite":sprite,"ink":ink,"foot":foot})
func in_sight_lane199(point: Vector2) -> bool:
 var plan=preload("res://scripts/world/forest_plan188.gd")
 var local: Vector2=point-plan.CENTER
 # A static, regional camera sight corridor. Leave the side frame and north
 # canopy; do not repeatedly fade solid trees over the narrow approach.
 for i in range(1,plan.PATH.size()):
  var a: Vector2=plan.PATH[i-1];var b: Vector2=plan.PATH[i]
  var count := ceili(a.distance_to(b)/1.5)
  for k in count+1:
   var centre: Vector2=a.lerp(b,float(k)/maxi(count,1))
   var gap: Vector2=local-centre
   if gap.y>1.8 and gap.y<10. and absf(gap.x)<1.1+gap.y*.33: return true
 return false
func _ready() -> void:
 process_priority=160
 var art: Node3D=world.forest188
 for prop in art.props181:
  if prop.texture==preload("res://assets/forest188/post_top_nightlight_pixel.png"): bind_card199(prop,prop.global_position,false)
 bind_card199(art.nook194,art.nook194.global_position)
 bind_card199(art.cat194,art.nook194.global_position+world.camera.global_basis.z*.025)
 # Calibrate two trunk footprints from the painted lower root clusters.
 for i in 2:
  var uv := Vector2(.26,.97) if i==0 else Vector2(.82,.97)
  var painted: Vector3=art.painted_point193(art.nook194,uv)
  var ray: Vector3=-world.camera.global_basis.z
  var foot: Vector3=painted+ray*((art.nook194.global_position.y-painted.y)/ray.y)
  foot.y=world.floor_height(Vector2(foot.x,foot.z));root_feet199.append(foot)
  var body: StaticBody3D=art.trunk_bodies194[i]
  body.global_position=foot+Vector3.UP*.5
  var shape := CylinderShape3D.new();shape.radius=.43;shape.height=1.
  body.get_child(0).shape=shape
 for tree in world.trees:
  if tree.has("shadow19"): shadow_pairs.append({"visual":tree.visual,"shadow":tree.shadow19})
  if not tree.root.is_visible_in_tree() or not in_sight_lane199(Vector2(tree.root.global_position.x,tree.root.global_position.z)): continue
  sight_trees199.append(tree);tree.root.hide()
  for collision in tree.root.find_children("*","CollisionObject3D",true,false): collision.collision_layer=0
  for piece in world.root_pieces:
   if piece.sprite==tree.visual: piece.node.hide()
 # Theme perimeter trees have a separate list and previously escaped the
 # ordinary tree manager. Clear only those intruding into the same corridor.
 for tree in art.trees:
  if tree==art.stage_tree185 or not tree.is_visible_in_tree(): continue
  if not in_sight_lane199(Vector2(tree.global_position.x,tree.global_position.z)): continue
  tree.hide()
  for body in art.solids:
   if not is_instance_valid(body): continue
   var delta: Vector3=body.global_position-tree.global_position
   if Vector2(delta.x,delta.z).length()>.8: continue
   var shape_node: CollisionShape3D=body.get_child(0)
   if shape_node.shape is CylinderShape3D and shape_node.shape.radius>.3: body.collision_layer=0
 _process(0.)
func _process(_delta: float) -> void:
 var normal := Vector3(world.camera.global_basis.z.x,0.,world.camera.global_basis.z.z).normalized()
 for card in cards:
  card.ink.set_shader_parameter("camera199",world.camera.global_position)
  card.ink.set_shader_parameter("plane_normal199",normal)
 for pair in shadow_pairs:
  if not is_instance_valid(pair.visual) or not is_instance_valid(pair.shadow): continue
  var ink: ShaderMaterial=pair.visual.material_override
  var fade: Variant=ink.get_shader_parameter("fade")
  if fade!=null: pair.shadow.material_override.set_shader_parameter("fade",float(fade)*float(fade))
