extends SceneTree
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world374.gd").new();root.add_child(w);current_scene=w
 while not is_instance_valid(w.companion373) or not w.companion373.ready373:await physics_frame
 var c=w.companion373;c.hold373();c.set_physics_process(false);w.set_pair372(true)
 for side in ["left","right"]:
  c.direction373=side
  for frame in [1,3]:
   c.apply_frame373(frame)
   if c.visual.texture!=c.atlas373[side].frames[frame]:failures.append(side+str(frame))
   if absf(c.visual.pixel_size*c.atlas373[side].height-1.44)>.001:failures.append("height")
   if absf(c.visual.texture.get_height()*.5+c.visual.offset.y-c.atlas373[side].foot.y)>.001:failures.append("foot")
   for i in 5:await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://docs/room374-arm-"+side+"-"+str(frame)+".png")
  var sequence: Array=[]
  for tick in range(4):
   c.clock373=float(tick)/8.+.001;sequence.append(c.frame_index373(true))
  if sequence!=[1,2,3,2]:failures.append("sequence "+side)
 c.set_physics_process(true)
 var event:=InputEventKey.new();event.pressed=true;event.physical_keycode=KEY_U
 w._input(event)
 if c.preview374!=1:failures.append("preview left")
 w._input(event)
 if c.preview374!=2:failures.append("preview right")
 w._input(event)
 if c.preview374!=0 or c.mode373!="follow":failures.append("preview resume")
 print("ARMS374_DONE ",failures);quit(0 if failures.is_empty() else 1)
