extends CanvasLayer
var status371: Label
var started371:=0
var stable371:=0
func _process(_delta: float) -> void:
 var scene:=get_tree().current_scene
 var elapsed: float=(Time.get_ticks_msec()-started371)/1000.
 status371.text="正在构建小院与大地图… 已等待 %.1f 秒\n首次进入可能需要几十秒，正在准备场景。"%elapsed
 if scene!=null and "arc_shadows167" in scene and is_instance_valid(scene.arc_shadows167):
  stable371+=1
  if stable371>=30:
   print("YARD371_OVERLAY_FINISHED ms=",Time.get_ticks_msec()-started371)
   queue_free()
