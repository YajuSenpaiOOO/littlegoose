extends "res://scripts/combat/goose_speech112.gd"
class AnchoredBubble:
 extends "res://scripts/combat/goose_speech112.gd".Bubble
 var battle265: Node3D
 var pointer265 := Vector2.ZERO
 var base265 := Vector2.ZERO
 var tail_axis265 := Vector2.RIGHT
 var speaker_screen265 := Vector2.ZERO
 func _process(delta: float) -> void:
  if not battle265.combat_paused or screen_anchor.is_finite():super._process(delta)
  if is_queued_for_deletion():return
  var goose: Node3D=anchor.get_ref() if anchor!=null else null
  if not is_instance_valid(goose) or not is_instance_valid(camera):return
  var extent=get_viewport().get_visible_rect().size
  if screen_anchor.is_finite():
   visible=true
   speaker_screen265=extent*screen_anchor
  else:
   var at=goose.visual.get_global_transform_interpolated()*Vector3(0,.55,0)
   visible=not camera.is_position_behind(at)
   if not visible:return
   speaker_screen265=camera.unproject_position(at)
  place_bubble265(goose,extent)
  queue_redraw()
 func place_bubble265(_goose: Node3D, extent: Vector2) -> void:
  var below=speaker_screen265.y<box.y+45.
  position=Vector2(clampf(speaker_screen265.x+box.x*.25,box.x*.5+10.,maxf(box.x*.5+10.,extent.x-box.x*.5-10.)),speaker_screen265.y+box.y+20. if below else speaker_screen265.y-20.)
  position.y=clampf(position.y,box.y+10.,extent.y-14.)
  pointer265=(speaker_screen265-position)/maxf(.001,scale.x)
  base265=Vector2(clampf(pointer265.x,-box.x*.5+18.,box.x*.5-18.),-box.y+2. if below else -2.)
 func _draw() -> void:
  draw_set_transform(Vector2.ZERO,0.,Vector2.ONE*.035);draw_style_box(frame,Rect2(Vector2(-box.x*.5,-box.y)/.035,box/.035));draw_set_transform(Vector2.ZERO,0.)
  var a=base265-tail_axis265*6.;var b=base265+tail_axis265*6.
  draw_colored_polygon(PackedVector2Array([a,b,pointer265]),Color("ffe5e4"))
  draw_polyline(PackedVector2Array([a,pointer265,b]),Color("ba839b"),1.,false)
func make_anchored_bubble265() -> AnchoredBubble:
 return AnchoredBubble.new()
func _advance() -> void:
 if pending.is_empty():return
 var next: Dictionary=pending.pop_front();var owner: Node=next.anchor.get_ref()
 if not is_instance_valid(owner) or not owner.is_inside_tree():_advance();return
 if is_instance_valid(live):live.queue_free()
 var bubble=make_anchored_bubble265();bubble.battle265=battle;bubble.anchor=next.anchor;bubble.camera=battle.camera;bubble.words=next.text
 bubble.duration=maxf(3.,float(bubble.words.length())/22.+1.3);add_child(bubble);live=bubble;wait_left=bubble.duration
 history.append({"anchor":owner.get_instance_id(),"text":bubble.words})
 if history.size()>16:history.pop_front()
func _process(delta: float) -> void:
 if battle.combat_paused:return
 super._process(delta)
