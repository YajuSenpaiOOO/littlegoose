extends Resource
## One reusable asset definition; instances supply only position and size factor.
@export var texture: Texture2D
@export var art_scene: PackedScene
@export var anchor_px := Vector2.ZERO
@export var draw_scale := 1.0
@export var footprint := Vector2.ZERO
@export var footprint_offset := Vector2.ZERO
@export_enum("Rectangle", "Rounded trunk") var footprint_shape := 0
@export var contact_size := Vector2(24,8)
@export_enum("Alpha silhouette","Raised plane","None") var projection_kind := 0
@export var height := 60.0
@export var max_shadow_length := 120.0
@export var raised_plane := Rect2(-20,-5,40,10)
@export var contacts := PackedVector2Array()
@export var wind := 0.0
@export var light_profile: Resource
