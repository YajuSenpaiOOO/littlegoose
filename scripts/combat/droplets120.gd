extends Node3D
var world: Node3D
var items120: Array[Dictionary]=[]
var clock120 := 0.
var force_collect120 := false
var picked120 := 0
var ink120: ShaderMaterial
func _ready() -> void:
 ink120=ShaderMaterial.new();ink120.shader=preload("res://scripts/art/forest_cutout13.gdshader")
 ink120.set_shader_parameter("paint",preload("res://assets/collectibles119/blue_elastic_drop.png"));ink120.set_shader_parameter("alpha_threshold",.15)
 world.porch49.shade_material(ink120)
func drop_limit120() -> int:return 15
func spawn120(at: Vector3,velocity: Vector3) -> void:
 if items120.size()>=drop_limit120(): return
 var root := Node3D.new();root.position=at;add_child(root)
 var sprite := Sprite3D.new();sprite.texture=preload("res://scripts/combat/elastic_drop119.gd").texture119();sprite.pixel_size=.24/750.;sprite.billboard=BaseMaterial3D.BILLBOARD_FIXED_Y;sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(sprite)
 sprite.shaded=true;sprite.material_override=ink120
 var shadow := MeshInstance3D.new();var plane := PlaneMesh.new();plane.size=Vector2(.25,.18);shadow.mesh=plane
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/foot_contact16.gdshader");shadow.material_override=ink;shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(shadow)
 items120.append({"root":root,"sprite":sprite,"shadow":shadow,"velocity":velocity,"age":0.,"bounces":0,"retry":0.})
func clear120() -> void:
 for item in items120: item.root.queue_free();item.shadow.queue_free()
 items120.clear();force_collect120=false;picked120=0
func collect120(index: int) -> bool:
 if not world.collect_gel120(): return false
 var item: Dictionary=items120[index];item.root.queue_free();item.shadow.queue_free();items120.remove_at(index);picked120+=1;return true
func _physics_process(delta: float) -> void:
 if world.combat_paused: return
 clock120+=delta
 for i in range(items120.size()-1,-1,-1):
  var item: Dictionary=items120[i];var root: Node3D=item.root;var hero: Vector3=world.hero.global_position+Vector3.UP*.35
  item.age+=delta
  var distance := root.position.distance_to(hero)
  if item.age>.3 and (force_collect120 or distance<1.9):
   root.position=root.position.move_toward(hero,delta*(8. if force_collect120 else 4.5))
   if root.position.distance_to(hero)<.3 and clock120>=float(item.retry):
    if not collect120(i): item.retry=clock120+1.
    continue
  else:
   var velocity: Vector3=item.velocity
   if int(item.bounces)<2:
    velocity.y-=9.*delta;root.position+=velocity*delta
    var floor_y: float=world.floor_height(Vector2(root.position.x,root.position.z))+.14
    if root.position.y<=floor_y:
     root.position.y=floor_y;velocity.y=absf(velocity.y)*.42;velocity.x*=.55;velocity.z*=.55;item.bounces+=1;item.sprite.scale=Vector3(1.35,.7,1.)
   else: root.position.y=world.floor_height(Vector2(root.position.x,root.position.z))+.17+sin(clock120*3.+i)*.025
   item.velocity=velocity
  item.sprite.scale=item.sprite.scale.lerp(Vector3.ONE,minf(1.,delta*10.))
  item.shadow.position=Vector3(root.position.x,world.floor_height(Vector2(root.position.x,root.position.z))+.024,root.position.z)
