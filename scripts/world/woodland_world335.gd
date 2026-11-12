extends "res://scripts/world/woodland_world334.gd"
var normal_form335:=0
var ring_turn335:=0
var gap_left335:=0.
var structure335: Dictionary={}
var structure_ui335: Control
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 335 · 缺口纸环 / 城防瞄准框")
func stage_script314() -> Script: return preload("res://scripts/art/paper_stage335.gd")
func _ready() -> void:
 await super._ready()
 var layer:=CanvasLayer.new()
 add_child(layer)
 structure_ui335=preload("res://scripts/combat/structure_aim335.gd").new()
 structure_ui335.battle=self
 layer.add_child(structure_ui335)
 hint288.text="335 缺口纸环 / 城防瞄准框\n金色开口是穿行方向 · 炮台16 / 城堡144"
func restart301() -> void:
 normal_form335=0
 ring_turn335=0
 structure335.clear()
 gap_left335=0.
 super.restart301()
func scatter327(source: int) -> void:
 var form:=normal_form335%4
 normal_form335+=1
 if form<3:
  salvo334=form
  super.scatter327(source)
  return
 var at: Vector3=theatre314.muzzle330(source)
 var fixed: Vector3=theatre314.to_global(Vector3(0.,0.,6.5))
 var forward:=Vector2(fixed.x-at.x,fixed.z-at.z).normalized()
 var gap:=forward.rotated(-.45+float(ring_turn335%4)*.3)
 ring_turn335+=1
 # Twenty-one paper scraps around a 24-slot circle; three slots form the opening.
 for i in range(2,23):
  paper_queue334.append({"source":source,"aim":gap.rotated(TAU*float(i)/24.),"delay":.5})
 theatre314.show_gap335(at,gap,true)
 gap_left335=.65
func boss_step314(delta: float) -> void:
 super.boss_step314(delta)
 gap_left335=maxf(0.,gap_left335-delta)
 if gap_left335==0. and is_instance_valid(theatre314): theatre314.show_gap335(Vector3.ZERO,Vector2.DOWN,false)
func interrupt327(source := -1) -> void:
 super.interrupt327(source)
 if paper_queue334.is_empty():
  gap_left335=0.
  if is_instance_valid(theatre314): theatre314.show_gap335(Vector3.ZERO,Vector2.DOWN,false)
func clear_patterns327() -> void:
 super.clear_patterns327()
 structure335.clear()
 gap_left335=0.
 if is_instance_valid(theatre314): theatre314.show_gap335(Vector3.ZERO,Vector2.DOWN,false)
func structure_rect335(shape: CollisionShape3D) -> Rect2:
 var size: Vector3=(shape.shape as BoxShape3D).size*.5
 var result:=Rect2()
 var first:=true
 for x in [-1.,1.]:
  for y in [-1.,1.]:
   for z in [-1.,1.]:
    var at:=shape.to_global(size*Vector3(x,y,z))
    if camera.is_position_behind(at): continue
    var point:=camera.unproject_position(at)
    if first:
     result=Rect2(point,Vector2.ZERO)
     first=false
    else: result=result.expand(point)
 return result
func structure_ray335(cursor: Vector2) -> Dictionary:
 var from:=camera.project_ray_origin(cursor)
 var direction:=camera.project_ray_normal(cursor)
 var query:=PhysicsRayQueryParameters3D.create(from,from+direction*250.,1|2|8,[hero.get_rid()])
 query.collide_with_areas=true
 var hit:=get_world_3d().direct_space_state.intersect_ray(query)
 if hit.is_empty(): return {}
 var collider: Node=hit.collider
 var gun: int=theatre314.cannon_areas326.find(collider) if collider is Area3D else -1
 if gun>=0 and cannon_hp326[gun]<=0.: return {}
 if collider==theatre314.bodies[0].get_parent():
  if theatre314.castle_target327.collision_layer==0: return {}
  for wall in theatre314.castle_target327.get_children():
   if wall is CollisionShape3D and structure_rect335(wall).has_point(cursor):
    return {"shape":wall,"at":hit.position+direction*.04,"collider":theatre314.castle_target327}
  return {}
 if collider!=theatre314.castle_target327 and gun<0: return {}
 var shape: CollisionShape3D=collider.shape_owner_get_owner(collider.shape_find_owner(hit.shape))
 return {"shape":shape,"at":hit.position+direction*.04,"collider":collider}
func acquire_structure335(cursor: Vector2) -> Dictionary:
 if not active114 or waiting_intro314 or fastener_hp321<=0. or not is_instance_valid(theatre314): return {}
 var hit:=structure_ray335(cursor)
 if not hit.is_empty(): return hit
 # Match light aim assistance near target edges, and confirm visibility by ray.
 var best:=15.
 var result: Dictionary={}
 var areas: Array=[theatre314.castle_target327]
 areas.append_array(theatre314.cannon_areas326)
 for area in areas:
  if area.collision_layer==0: continue
  for shape in area.get_children():
   if not shape is CollisionShape3D or shape.disabled: continue
   var rect:=structure_rect335(shape)
   if rect.size.x<2. or rect.size.y<2.: continue
   var point:=cursor.clamp(rect.position+Vector2.ONE,rect.end-Vector2.ONE)
   var distance:=cursor.distance_to(point)
   if distance>=best: continue
   var candidate:=structure_ray335(point)
   if not candidate.is_empty():
    best=distance
    result=candidate
 return result
func cursor_fastener321(cursor: Vector2) -> Vector3:
 structure335=acquire_structure335(cursor)
 return Vector3.INF if structure335.is_empty() else Vector3(structure335.at)
func _refresh_aim114(cursor: Vector2) -> void:
 super._refresh_aim114(cursor)
 if not is_instance_valid(theatre314): return
 structure335=acquire_structure335(cursor)
 if not structure335.is_empty():
  target114=null
  aim114=structure335.at
func fire_input_held() -> bool:
 if auto114 and active114 and not combat_paused and is_instance_valid(hero) and hero.controls_enabled and not hero.guarding109 and not hero.knocked_down:
  _refresh_aim114(get_viewport().get_mouse_position())
  if not structure335.is_empty(): return true
 return super.fire_input_held()
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(theatre314): guide206.text=guide206.text.replace("334 城防弹幕","335 城防弹幕")
