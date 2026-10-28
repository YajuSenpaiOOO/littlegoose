extends Node3D
## Visual swords and independently expiring adhesive layers share one lifetime.
const LIFETIME := 3.
const LIMIT := 5
const SLOW := .08
const RESIDUE_LIMIT := 160
var battle: Node3D
var texture153: Texture2D
var flying153 := {}
var resting153: Array[Dictionary]=[]
var layers153 := {}
var serial153 := 0
var landed153 := 0
func _ready() -> void:
 name="ElasticBalloonSwords153"
 var img := Image.load_from_file("res://assets/balloon_sword153/sword.png")
 img.generate_mipmaps();texture153=ImageTexture.create_from_image(img)
func sprite153() -> Sprite3D:
 var node := Sprite3D.new();node.texture=texture153;node.pixel_size=1.05/texture153.get_height()
 node.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/combat/balloon_sword153.gdshader")
 ink.set_shader_parameter("art153",texture153);node.material_override=ink
 add_child(node);return node
func orient153(node: Sprite3D,tip: Vector3,direction: Vector3,length_gain := 1.) -> void:
 var screen: Vector2=battle.screen_direction(tip,direction)
 node.basis=battle.camera.global_basis*Basis(Vector3.BACK,-screen.angle()-PI*.5)
 node.scale=Vector3.ONE*length_gain
 node.position=tip-node.basis.y*.48
func attach153(enemy: Variant,tip: Vector3,direction: Vector3,gain := 1.,_surface: Dictionary={}) -> void:
 var entry := {"node":sprite153(),"enemy":weakref(enemy) if is_instance_valid(enemy) else null,"enemy_id":enemy.get_instance_id() if is_instance_valid(enemy) else 0,"offset":tip-enemy.hit_area.global_position if is_instance_valid(enemy) else tip,"direction":direction.normalized(),"age":0.,"life":LIFETIME,"gain":gain,"phase":float(serial153)*2.4}
 if is_instance_valid(enemy):
  # The generous hurt capsule extends above the artwork. Keep the visible
  # adhesive tip on the creature instead of floating at the capsule's crown.
  entry.offset.y=clampf(entry.offset.y,-.28,.25 if enemy.has_method("separation132") else .08)
 serial153+=1;landed153+=1
 if is_instance_valid(enemy):
  var id: int=enemy.get_instance_id()
  if not layers153.has(id): layers153[id]=[]
  var list: Array=layers153[id]
  if list.size()>=LIMIT:
   var old: Dictionary=list.pop_front();old.age=old.life
  list.append(entry);enemy.set_meta("locomotion_scale153",1.-SLOW*list.size())
 resting153.append(entry)
 while resting153.size()>RESIDUE_LIMIT: remove153(0)
func remove153(index: int) -> void:
 var entry: Dictionary=resting153[index];var enemy: Variant=entry.enemy.get_ref() if entry.enemy!=null else null
 if entry.enemy_id!=0:
  var id: int=entry.enemy_id;var list: Array=layers153.get(id,[])
  list.erase(entry)
  if is_instance_valid(enemy): enemy.set_meta("locomotion_scale153",1.-SLOW*list.size())
  if list.is_empty(): layers153.erase(id)
 if is_instance_valid(entry.node): entry.node.queue_free()
 resting153.remove_at(index)
func reset153() -> void:
 for i in range(resting153.size()-1,-1,-1): remove153(i)
 layers153.clear()
 for node in flying153.values(): if is_instance_valid(node): node.queue_free()
 flying153.clear()
func step153(delta: float) -> void:
 if not battle.active114 or battle.player_hp<=0.: reset153();return
 if battle.combat_paused: return
 for i in range(resting153.size()-1,-1,-1):
  var entry: Dictionary=resting153[i];entry.age+=delta
  var enemy: Variant=entry.enemy.get_ref() if entry.enemy!=null else null
  if entry.age>=entry.life or (entry.enemy!=null and (not is_instance_valid(enemy) or enemy.dead)):
   remove153(i)
func _process(_delta: float) -> void:
 if not is_instance_valid(battle.camera): return
 var seen := {}
 for shot in battle.shots:
  if not shot.get("sword153",false): continue
  var id: int=shot.serial153;seen[id]=true
  if not flying153.has(id): flying153[id]=sprite153()
  orient153(flying153[id],shot.node.get_global_transform_interpolated().origin,shot.velocity,float(shot.get("sword_gain153",1.)))
 for id in flying153.keys():
  if not seen.has(id): flying153[id].queue_free();flying153.erase(id)
 for entry in resting153:
  var enemy: Variant=entry.enemy.get_ref() if entry.enemy!=null else null
  var tip: Vector3=enemy.hit_area.global_position+entry.offset if is_instance_valid(enemy) else entry.offset
  var direction: Vector3=entry.direction
  # Ground swords keep their blade tip planted, hilt up; enemy swords retain impact direction.
  if entry.enemy==null: direction=Vector3.DOWN+Vector3.RIGHT*sin(entry.phase)*.18
  else: direction=direction.rotated(battle.camera.global_basis.z,sin(entry.phase)*.22)
  orient153(entry.node,tip,direction,entry.gain)
  var ink: ShaderMaterial=entry.node.material_override
  ink.set_shader_parameter("bend153",sin(entry.age*12.+entry.phase)*.055*exp(-entry.age*1.6)+sin(entry.age*5.+entry.phase)*.018)
  ink.set_shader_parameter("flatten153",smoothstep(2.35,3.,entry.age))
  ink.set_shader_parameter("fade153",1.-smoothstep(2.65,3.,entry.age))
