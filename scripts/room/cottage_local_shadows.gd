extends Node3D
## Local casters for the same room lights. The cut facade has its own
## opaque shadow copies, so framing the room never widens the apertures.

const ROOM_LAYER := 1<<10
var facade_casters: Array[MeshInstance3D]=[]
var actors: Array[Sprite3D]=[]
var original_layers: Array[int]=[]
var original_casting: Array[int]=[]
var old_projections: Array[Node]=[]
var previous_projection_states: Array[bool]=[]
var active := false

func build(home: Node3D) -> void:
 for part in [home.house.shell, home.house.joinery, home.room]:
  for item in part.find_children("*","GeometryInstance3D",true,false):
   item.layers|=ROOM_LAYER
 var facade:=Node3D.new()
 facade.name="IntactFacadeCasters"
 add_child(facade)
 var opaque:=StandardMaterial3D.new()
 opaque.cull_mode=BaseMaterial3D.CULL_DISABLED
 for entry in home.house.front_cut:
  var source=entry.node
  if not source is MeshInstance3D or source.mesh==null or source in home.house.front_glass:continue
  var proxy:=MeshInstance3D.new()
  proxy.mesh=source.mesh
  proxy.material_override=opaque
  proxy.layers=ROOM_LAYER
  proxy.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
  # A door proxy inherits the hinge, while all facade pieces retain
  # their authored positions and stay present through the cut.
  if home.house.pivot.is_ancestor_of(source):
   home.house.pivot.add_child(proxy)
  else:
   facade.add_child(proxy)
  proxy.global_transform=source.global_transform
  facade_casters.append(proxy)
  proxy.hide()
 actors=[home.hero.visual,home.companion.visual]
 for sprite in actors:
  original_layers.append(sprite.layers)
  original_casting.append(sprite.cast_shadow)
 for actor in [home.hero,home.companion]:
  for shadow in actor.get_children():
   if shadow is MeshInstance3D and shadow.get("visual")==actor.visual and shadow.get("enabled")!=null:
    old_projections.append(shadow)
    previous_projection_states.append(shadow.enabled)

func configure(light: Light3D,opacity: float) -> void:
 light.light_cull_mask=ROOM_LAYER
 light.shadow_caster_mask=ROOM_LAYER
 light.shadow_bias=.045
 light.shadow_normal_bias=.55
 light.shadow_opacity=opacity
 light.shadow_enabled=false

func apply(value: bool) -> void:
 if value==active:return
 active=value
 for proxy in facade_casters:
  proxy.visible=active
 for i in actors.size():
  var sprite:=actors[i]
  sprite.layers=original_layers[i]|ROOM_LAYER if active else original_layers[i]
  sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED if active else original_casting[i]
 for i in old_projections.size():
  old_projections[i].enabled=false if active else previous_projection_states[i]
