extends "res://scripts/world/woodland_world226.gd"
var cat_nav227=preload("res://scripts/combat/woodland_navigation21.gd").new()
var ready227 := false
var support227: CharacterBody3D
var called227 := false
func _init() -> void:
 super._init();memory_save116="user://plush_boss227_preview.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 227 · 肥猫绕障 / 二次修补蜘蛛支援")
func _ready() -> void:
 await super._ready()
 cat_nav227.bake(get_world_3d().direct_space_state,meadow,arena220)
 var query=PhysicsShapeQueryParameters3D.new();var shape=SphereShape3D.new();shape.radius=1.04;query.shape=shape;query.collision_mask=1|2;query.exclude=[hero.get_rid()]
 for y in cat_nav227.grid.region.size.y:
  for x in cat_nav227.grid.region.size.x:
   var at=cat_nav227.origin+Vector2(x,y)*cat_nav227.CELL;var h=floor_height(at)
   query.transform.origin=Vector3(at.x,h+1.15,at.y)
   cat_nav227.grid.set_point_solid(Vector2i(x,y),absf(h-FOREST188.BASE)>.25 or not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty())
 ready227=true
func cat_path227(at: Vector2,to: Vector2) -> PackedVector2Array:
 return cat_nav227.path(at,to) if ready227 else navigation.path(at,to)
func cat_can_roll227(at: Vector2,to: Vector2) -> bool:
 var distance=at.distance_to(to)
 return distance<.1 or cat220.clear_distance221((to-at).normalized(),distance)>=distance-.35
func pig_target225() -> Vector2:
 return Vector2(hero.position.x,hero.position.z)+(Vector2(hero.velocity.x,hero.velocity.z)*.9).limit_length(1.6)
func clear_support227() -> void:
 if is_instance_valid(support227):
  enemies.erase(support227);support227.hide();support227.set_physics_process(false);support227.hit_area.collision_layer=0;support227.queue_free()
 support227=null;called227=false
 for pad in pads172.duplicate():remove_pad172(pad)
 clear_silk171();attacker170=null
func support_script227() -> Script:return preload("res://scripts/combat/spider_support227.gd")
func spawn_support227() -> void:
 if called227:return
 var player=Vector2(hero.position.x,hero.position.z)
 for offset in [Vector2(3.8,1.),Vector2(-3.8,1.),Vector2(1.,3.8),Vector2(-1.,-3.8)]:
  var at=player+offset
  if not open_drop225(at) or at.distance_to(Vector2(cat220.position.x,cat220.position.z))<2.:continue
  support227=support_script227().new();support227.battle=self;support227.poses=combat_poses.duplicate(true);support227.textures=combat_textures.duplicate();support227.home=at;support227.position=Vector3(at.x,floor_height(at),at.y)
  add_child(support227);support227.hp=8.;support227.max_hp110=8.;support227.touch110=2.;support227.play119();enemies.append(support227);_add_actor_shadow(support227,support227.visual);called227=true;rebuild_cells110();notice219("小蜘蛛跑来帮姐姐织网了");return
func start_battle225(keep_player: bool) -> void:
 clear_support227();super.start_battle225(keep_player)
func stop225() -> void:
 clear_support227();super.stop225()
func end220(victory: bool) -> void:
 clear_support227();super.end220(victory)
func _process(delta: float) -> void:
 super._process(delta)
 if ready227 and active114 and not combat_paused and repairs220>=2 and not called227:spawn_support227()
