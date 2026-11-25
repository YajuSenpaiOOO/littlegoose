extends "res://scripts/combat/goose_speech265.gd"

class GooseBubble:
 extends AnchoredBubble

 var dialogue_side:=0.
 var use_vertical_placement:=false

 func place_bubble265(goose: Node3D, extent: Vector2) -> void:
  if screen_anchor.is_finite():
   super.place_bubble265(goose,extent)
   return
  var sprite:Sprite3D=goose.visual
  var bounds:=sprite.get_aabb()
  var pose:=sprite.get_global_transform_interpolated()
  var screen_right:=camera.global_basis.x.normalized()*pose.basis.x.length()
  var head:=pose.origin+pose.basis.y*bounds.end.y
  var feet:=pose.origin+pose.basis.y*bounds.position.y
  var left:=camera.unproject_position(head+screen_right*bounds.position.x)
  var right:=camera.unproject_position(head+screen_right*bounds.end.x)
  var head_top:=camera.unproject_position(head).y
  var foot_screen:=camera.unproject_position(feet).y
  visible=right.x>=-20. and left.x<=extent.x+20. and head_top<=extent.y+20. and foot_screen>=-20.
  if not visible:return
  var head_line:=lerpf(head_top,foot_screen,.19)
  if dialogue_side==0.:
   dialogue_side=1. if extent.x-right.x>=left.x else -1.
  var side:=dialogue_side
  var edge:=right.x if side>0. else left.x
  var side_space:=extent.x-right.x if side>0. else left.x
  var half_width:=box.x*.5
  var padding:=10.
  if not use_vertical_placement and side_space>=box.x+2.*padding:
   position=Vector2(edge+side*(half_width+padding),clampf(head_top+box.y*.5-12.,box.y+padding,extent.y-padding))
   speaker_screen265=Vector2(edge+side*2.,head_line)
   pointer265=to_local(speaker_screen265)
   base265=Vector2(-side*half_width,clampf(pointer265.y,-box.y+12.,-12.))
   tail_axis265=Vector2.DOWN
   return
  # Once the chosen side runs out of room, keep the balloon vertical until
  # this line ends so small camera movements cannot toggle the placement.
  use_vertical_placement=true
  var below:=head_top<box.y+2.*padding and extent.y-foot_screen>=box.y+2.*padding
  position.x=clampf((left.x+right.x)*.5,half_width+padding,extent.x-half_width-padding)
  position.y=foot_screen+box.y+padding if below else maxf(box.y+padding,head_top-padding)
  speaker_screen265=Vector2((left.x+right.x)*.5,foot_screen if below else head_top)
  pointer265=to_local(speaker_screen265)
  base265=Vector2(clampf(pointer265.x,-half_width+12.,half_width-12.),-box.y if below else 0.)
  tail_axis265=Vector2.RIGHT

func make_anchored_bubble265() -> AnchoredBubble:
 return GooseBubble.new()

func say_across_table(words: String, lens: Camera3D) -> void:
 dismiss()
 layer=30
 var bubble:=make_anchored_bubble265()
 bubble.battle265=battle
 bubble.anchor=weakref(battle.goose)
 bubble.camera=lens
 bubble.screen_anchor=Vector2(.60,.055)
 bubble.words=words
 bubble.duration=maxf(4.,float(bubble.words.length())/22.+1.8)
 add_child(bubble)
 live=bubble

func dismiss() -> void:
 super.dismiss()
 layer=14
