extends Control
var battle: Node3D
var drawn335:=Rect2()
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
func _process(_delta: float) -> void: queue_redraw()
func _draw() -> void:
 drawn335=Rect2()
 if not battle.active114 or battle.combat_paused or battle.waiting_intro314 or battle.fastener_hp321<=0.: return
 var target: Dictionary=battle.structure335
 if target.is_empty(): return
 if target.collider.collision_layer==0: return
 var gun: int=battle.theatre314.cannon_areas326.find(target.collider)
 if gun>=0 and battle.cannon_hp326[gun]<=0.: return
 var box: Rect2=battle.structure_rect335(target.shape)
 box=box.grow(5.).intersection(get_viewport_rect().grow(-6.))
 if box.size.x<4. or box.size.y<4.: return
 drawn335=box
 var color:=Color(.65,.9,.85,.9) if battle.auto114 else Color(1.,.84,.42,.95)
 for x in [0.,1.]:
  for y in [0.,1.]:
   var at:=box.position+box.size*Vector2(x,y)
   draw_line(at,at+Vector2(12.*(1.-2.*x),0.),color,2.,true)
   draw_line(at,at+Vector2(0.,12.*(1.-2.*y)),color,2.,true)
