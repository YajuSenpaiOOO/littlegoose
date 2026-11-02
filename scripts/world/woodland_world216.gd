extends "res://scripts/world/woodland_world211.gd"
var cat216: CharacterBody3D
var ready216 := false
var spawn216 := Vector2.ZERO
func _init() -> void:
 super._init();memory_save116="user://fat_cat216_preview.cfg"
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 216 · 肥猫原版 / 地图角度与移动")
func _ready() -> void:
 await super._ready()
 ready206=false
 spawn216=choose_cat216((transport206.start_at+transport206.end_at)*.5)
 drops206.free();transport206.free()
 cat216=preload("res://scripts/art/fat_cat216.gd").new();cat216.world=self
 cat216.origin216=spawn216;cat216.goal216=spawn216+Vector2(-2.,.8);add_child(cat216)
 _teleport15(spawn216+Vector2(-2.1,0.))
 watch206=spawn216+Vector2(-2.1,0.)
 ready216=true
func _process(delta: float) -> void:
 super._process(delta)
 if not ready216: return
 guide206.text="216 肥猫 · 原版西南向 / 地图对照\nF4 原图/动画："+("原图" if cat216.original216 else "六帧14fps")+" · F5 走一小段 · F6 暂停 · F7 归位\nV 大小 "+str(cat216.width216)+"m · F8 观看点 · WASD绕行\nF3小院 / F10调色 / F12灯光 · 未接Boss/骑乘"+("\n【暂停】" if not cat216.running216 else "")+("\n前方有占地，已停下" if cat216.blocked216 else "")
func _input(event: InputEvent) -> void:
 if ready216 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  match event.physical_keycode:
   KEY_F4: cat216.original216=not cat216.original216;cat216.update_visual216()
   KEY_F5:
    cat216.moving216=not cat216.moving216;cat216.blocked216=false
   KEY_F6: cat216.running216=not cat216.running216
   KEY_F7: cat216.reset216();_teleport15(watch206)
   KEY_F8: _teleport15(watch206)
   KEY_V:
    cat216.width216=2.6 if cat216.width216>3.3 else snappedf(cat216.width216+.4,.1)
    cat216.update_visual216()
   _:
    super._input(event);return
  get_viewport().set_input_as_handled();return
 super._input(event)

func choose_cat216(center: Vector2) -> Vector2:
 var shape=SphereShape3D.new();shape.radius=.90
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1;query.exclude=[hero.get_rid(),transport206.body.get_rid()]
 for row in [3.,4.,2.,-2.,0.]:
  for col in [0.,1.,-1.]:
   var start=center+Vector2(col,row)
   var clear=true
   var base: float=floor_height(start)
   for i in 9:
    var at=start+Vector2(-2.,.8)*float(i)/8.
    var h: float=floor_height(at)
    query.transform.origin=Vector3(at.x,h+1.,at.y)
    if absf(h-base)>.15 or not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():
     clear=false;break
   if clear: return start
 return center
