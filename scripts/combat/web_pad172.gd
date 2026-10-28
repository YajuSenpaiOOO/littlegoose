extends "res://scripts/combat/silk_ball171.gd"
const RADIUS172 := 2.4
const LIFE172 := 6.
var live172 := false
var build172 := 0.
var owner172: WeakRef
var ground172: MeshInstance3D
func _ready() -> void:
 super._ready();set_meta("web_pad172",true);hit_area.collision_layer=0
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
 add_child(ground172);_render_legacy(0.)
func commit172() -> void:
 live172=true;clock171=0.;build172=1.;hit_area.collision_layer=8
func covers172(at: Vector3) -> bool:
 return live172 and not retired171 and absf(at.y-position.y)<.65 and Vector2(at.x-position.x,at.z-position.z).length()<RADIUS172
func _render_legacy(_lift: float) -> void:
 if not is_instance_valid(visual): return
 _pose("idle",0.);visual.pixel_size*=.70;visual.rotation.z=0.;visual.visible=live172
 if not is_instance_valid(ground172): return
 var grow := .30+.70*build172
 ground172.scale=Vector3(grow,1.,grow);ground172.transparency=.58 if not live172 else 0.
 if retired171:
  var t := clampf(fade171/UNRAVEL171,0.,1.);ground172.transparency=t;visual.transparency=t
 elif live172 and clock171>LIFE172-.65: ground172.transparency=.25+.20*sin(clock171*18.)
func retire171(reason: String) -> void:
 if retired171: return
 retired171=true;reason171=reason;dead=true;hp=0.;hit_area.collision_layer=0
 if reason=="shot": battle.web_clears172+=1
func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 if not battle.active114 or battle.player_hp<=0.: battle.remove_pad172(self);return
 if retired171:
  fade171+=delta;_render_legacy(0.)
  if fade171>=UNRAVEL171: battle.remove_pad172(self)
  return
 if not live172:
  var maker: Variant=owner172.get_ref() if owner172!=null else null
  if not is_instance_valid(maker) or maker.dead: battle.remove_pad172(self);return
 else:
  clock171+=delta
  if clock171>=LIFE172: retire171("timeout")
 _render_legacy(0.)
