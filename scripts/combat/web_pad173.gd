extends CharacterBody3D
# A temporary ground region, never an enemy or projectile target.
const RADIUS172 := 2.4
const LIFE173 := 10.
const FADE173 := .45
var battle: Node3D
var owner172: WeakRef
var live172 := false
var build172 := 0.
var retired171 := false
var dead := false
var clock171 := 0.
var fade173 := 0.
var ground172: MeshInstance3D
func _ready() -> void:
 collision_layer=0;collision_mask=0
 ground172=MeshInstance3D.new()
 var surface := SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for y in 24:
  for x in 24:
   for d in [Vector2i(0,0),Vector2i(1,1),Vector2i(1,0),Vector2i(0,0),Vector2i(0,1),Vector2i(1,1)]:
    var uv := (Vector2(x,y)+Vector2(d))/24.
    var p := (uv-Vector2(.5,.5))*RADIUS172*2.
    var at := Vector2(position.x,position.z)+p
    surface.set_uv(uv);surface.set_normal(Vector3.UP);surface.add_vertex(Vector3(p.x,battle.floor_height(at)-position.y+.035,p.y))
 ground172.mesh=surface.commit();ground172.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;ink.alpha_scissor_threshold=.35;ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 ink.albedo_texture=load("res://assets/spider172/mat.png");ink.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;ground172.material_override=ink
 add_child(ground172);render173()
func commit172() -> void:
 live172=true;clock171=0.;build172=1.;render173()
func covers172(at: Vector3) -> bool:
 return live172 and not retired171 and absf(at.y-position.y)<.65 and Vector2(at.x-position.x,at.z-position.z).length()<RADIUS172
func render173() -> void:
 if not is_instance_valid(ground172): return
 var grow := .08+.92*build172
 ground172.scale=Vector3(grow,1.,grow);ground172.transparency=.58 if not live172 else 0.
 if retired171: ground172.transparency=clampf(fade173/FADE173,0.,1.)
 elif live172 and clock171>LIFE173-.8: ground172.transparency=.25+.20*sin(clock171*18.)
func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 if not battle.active114 or battle.player_hp<=0.: battle.remove_pad172(self);return
 if retired171:
  fade173+=delta;render173()
  if fade173>=FADE173: battle.remove_pad172(self)
  return
 if not live172:
  var maker: Variant=owner172.get_ref() if owner172!=null else null
  if not is_instance_valid(maker) or maker.dead: battle.remove_pad172(self);return
 else:
  clock171+=delta
  if clock171>=LIFE173: retired171=true;dead=true
 render173()
