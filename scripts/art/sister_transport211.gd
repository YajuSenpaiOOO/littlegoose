extends "res://scripts/art/sister_transport206.gd"
## Selected A design with matching standing/seated art; transport remains inherited.
func make_card(file: String,height: float,pivot: Vector2) -> Sprite3D:
 if file in ["idle","seated"]:
  textures[file]=load("res://assets/sister211/idle.png" if file=="idle" else "res://assets/sister211/seated_character_v2.png")
  manifests[file]=opaque_bounds(textures[file].get_image())
 # Sitting bends the legs; preserve approximately the standing head size.
 var card=super.make_card(file,2.10 if file=="seated" else height,pivot)
 if file in ["idle","seated"]:
  (card.material_override as ShaderMaterial).shader=preload("res://scripts/art/sister_receiver207.gdshader")
 return card

func _ready() -> void:
 super._ready();name="SisterTransport211"

func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(standing): return
 # Match hero192's world-space lighting normal without rotating either actor.
 var normal=world.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))
 for card in [standing,seated]:
  (card.material_override as ShaderMaterial).set_shader_parameter("receiver_normal207",normal.normalized())
