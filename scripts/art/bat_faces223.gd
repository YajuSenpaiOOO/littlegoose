extends "res://scripts/art/sister_repair222.gd"
var bat_sheet223: Texture2D
var bat_layout223: Dictionary
var bat_frames223: Array[AtlasTexture]=[]
var stages223 := [0,0]
var ready223 := false
func _ready() -> void:
 super._ready();name="BatExpressions223"
 bat_sheet223=load("res://assets/bat223/expressions.png")
 bat_layout223=JSON.parse_string(FileAccess.get_file_as_string("res://assets/bat223/layout.json"))
 for data in bat_layout223.frames:
  var atlas=AtlasTexture.new();atlas.atlas=bat_sheet223;atlas.region=Rect2(data.region[0],data.region[1],data.region[2],data.region[3]);atlas.filter_clip=true;bat_frames223.append(atlas)
 ready223=true
func health_stage223(index: int) -> int:
 if world.bats220.size()<=index or not is_instance_valid(world.bats220[index]):return 0
 var actor=world.bats220[index]
 # High-altitude actors use dead=true to opt out of targeting, even with full HP.
 # Expression therefore follows HP, never the targeting/dead flag.
 if actor.hp<=0.:return 3
 var ratio: float=actor.hp/maxf(actor.max_hp110,.001)
 return 0 if ratio>2./3. else (1 if ratio>1./3. else 2)
func _process(delta: float) -> void:
 super._process(delta)
 if not ready223:return
 # Gentle seated breathing, rebuilt after the parent resets the camera basis.
 # The seated card origin is its registered foot anchor; the rig is unchanged.
 var breath=sin(elapsed*TAU/3.4)*.006
 seated.scale=Vector3(1.-breath*.5,1.+breath,1.)
 for i in 2:
  var bat=bats[i];var stage=health_stage223(i);stages223[i]=stage
  var wing=(int(elapsed*8.)+i)%2
  var anchor: Vector2;var bounds: Rect2
  if stage==0:
   var key="bat_up" if wing==0 else "bat_down"
   bat.texture=textures[key];anchor=bat_anchor(wing);bounds=Rect2(manifests[key])
   bat.pixel_size=.80*display_scale206/float((manifests.bat_up as Rect2i).size.y)
   (bat.material_override as ShaderMaterial).set_shader_parameter("paint",bat.texture)
  else:
   var index=4 if stage==3 else (stage-1)*2+wing
   var data: Dictionary=bat_layout223.frames[index]
   bat.texture=bat_frames223[index];anchor=Vector2(data.anchor[0],data.anchor[1])
   bounds=Rect2(data.bounds[0],data.bounds[1],data.bounds[2],data.bounds[3])
   # Silhouette height changes with ear/wing poses. Register the round torso
   # instead, so taking damage never makes the whole plush shrink.
   bat.pixel_size=.80*display_scale206/float(bat_layout223.reference_alpha_height)*float(bat_layout223.reference_body_width)/float(data.body_width)
   (bat.material_override as ShaderMaterial).set_shader_parameter("paint",bat_sheet223)
  bat.set_meta("anchor205",anchor);bat.set_meta("aim_bounds223",bounds)
  var size=bat.texture.get_size();bat.offset=Vector2(size.x*.5-anchor.x,anchor.y-size.y*.5)
  # Legacy victory presentation shrank the lost bat to .75 on top of new art.
  # Keep its tilt and folded wings, but retain full physical-looking body size.
  bat.scale=Vector3.ONE
  # Parent computes each hook from the unchanged hammock, so changing art cannot
  # shift suspension rings or move the physical hit capsule.
