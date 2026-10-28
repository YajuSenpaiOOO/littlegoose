extends Control
var battle: Node3D
var clock117 := 0.
var acquired117 := 0.
var previous117 := 0
var active117 := false
var cursor_live117 := false
var owns_mouse117 := false
var sweets117: Array[ImageTexture]=[]
const ART117 := [
 "......ooooo........",
 "....ooCCCCCo.......",
 "...oCCPPPPCCo......",
 "..oCPPPCCCPPCo.....",
 "..oCPCCPPPPCPo.....",
 ".oCPCPPCCCPPCPo....",
 ".oCPCPCCPPCPCPo....",
 ".oCPCPCPPPCPCPo....",
 ".oCPCPCCCCCPCPo....",
 ".oCCPCPPPPPCPCo....",
 "..oCPCCCCCCPCo.....",
 "..oCCPPPPPPCCo.....",
 "...oCCCCCCCCo......",
 "....oooooCoo.......",
 ".........oCCo......",
 "..........oCCo.....",
 "...........oCCo....",
 "............oCCo...",
 ".............oCCo..",
 "..............oCo..",
 "...............o..."]
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 # Bake the hand-authored UI pixels once; one texture draw per frame, no particle nodes.
 for state in 4:
  var bitmap := Image.create(19,21,false,Image.FORMAT_RGBA8);bitmap.fill(Color.TRANSPARENT)
  for y in ART117.size():
   for x in ART117[y].length():
    var c: String=ART117[y].substr(x,1)
    if c==".": continue
    var tone := Color(.20,.24,.25) if c=="o" else (Color(1.,.95,.78) if c=="C" else (Color(1.,.65,.59) if state>=2 else Color(.88,.58,.66)))
    bitmap.set_pixel(x,y,tone)
  if state%2==1: bitmap.set_pixel(5,3,Color.WHITE)
  sweets117.append(ImageTexture.create_from_image(bitmap))
func _physics_process(_delta: float) -> void:
 # This replaces the refresh removed with the old A/B panel; fire uses this same cache.
 if battle.active114 and not battle.combat_paused and battle.hero.controls_enabled:
  battle._refresh_aim114(get_viewport().get_mouse_position())
func _process(delta: float) -> void:
 clock117+=delta
 var was_active := active117
 active117=battle.active114 and not battle.combat_paused and battle.hero.controls_enabled and not battle.memory_ui116.visible
 cursor_live117=active117 and get_window().has_focus() and get_viewport_rect().has_point(get_viewport().get_mouse_position())
 if cursor_live117 and not owns_mouse117:
  # Do not take ownership from a captured or otherwise hidden UI cursor.
  if Input.mouse_mode==Input.MOUSE_MODE_VISIBLE: Input.mouse_mode=Input.MOUSE_MODE_HIDDEN;owns_mouse117=true
 elif not cursor_live117: restore117()
 var id := 0
 if active117 and is_instance_valid(battle.target114) and not battle.target114.dead: id=battle.target114.get_instance_id()
 if id!=previous117: acquired117=.24 if id!=0 else 0.;previous117=id
 acquired117=maxf(0.,acquired117-delta)
 if active117 or was_active: queue_redraw()
func restore117() -> void:
 if owns_mouse117:
  if Input.mouse_mode==Input.MOUSE_MODE_HIDDEN: Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
  owns_mouse117=false
func _exit_tree() -> void: restore117()
func pixel117(at: Vector2,side: float,color: Color) -> void:
 draw_rect(Rect2(at.round(),Vector2.ONE*side),color)
func star117(at: Vector2,unit: float,color: Color) -> void:
 pixel117(at-Vector2(unit,unit*3.),unit*2.,color)
 pixel117(at-Vector2(unit*3.,unit),unit*2.,color)
 pixel117(at-Vector2(unit,unit),unit*2.,color)
 pixel117(at+Vector2(unit,-unit),unit*2.,color)
 pixel117(at+Vector2(-unit,unit),unit*2.,color)
func _draw() -> void:
 if not active117: return
 var scale117 := clampf(get_viewport_rect().size.y/1000.,.75,1.5)
 var targeted: bool=is_instance_valid(battle.target114) and not battle.target114.dead
 if targeted:
  var actor: CharacterBody3D=battle.target114
  # Use the authored visible height, excluding transparent margins in the pose image.
  var visual: Sprite3D=actor.visual
  var height: float=float(actor.poses.idle.visible_height)/24.*actor.body_scale110
  var top := actor.global_position+visual.position+Vector3.UP*height
  var marker: Vector2=battle.camera.unproject_position(top)+Vector2(0,-12.*scale117+roundf(sin(clock117*3.)*2.)*scale117)
  var unit := maxf(1.,roundf(scale117*2.))
  star117(marker,unit,Color(.17,.23,.22,.9))
  star117(marker,unit*.65,Color(1.,.87,.56))
  pixel117(marker+Vector2(-unit*.5,unit*3.5),unit,Color(1.,.93,.74))
 if not cursor_live117: return
 var at := get_viewport().get_mouse_position().round()
 var px := maxf(1.,roundf(scale117*2.))
 var origin := at-Vector2(8.,7.)*px
 var frame := (2 if targeted else 0)+(1 if int(clock117*2.)%4==0 else 0)
 draw_texture_rect(sweets117[frame],Rect2(origin,Vector2(19,21)*px),false)
 # The hotspot stays still; only the icing shine and a brief acquisition sparkle move.
 if targeted:
  var glint := at+Vector2(12.,-10.)*px
  if acquired117>0.: glint+=Vector2(1.,-1.)*roundf((.24-acquired117)*12.)*px
  star117(glint,px*.55,Color(1.,.88,.57,.7+acquired117))
