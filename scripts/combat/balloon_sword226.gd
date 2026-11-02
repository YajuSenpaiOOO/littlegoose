extends "res://scripts/combat/balloon_sword159.gd"
## Reuse the same shaders, meshes, pads and shadows across short volleys.
const IDLE_LIMIT226 := 64
var blades226: Array[Sprite3D]=[]
var pads226: Array[Sprite3D]=[]
var births226 := 0
var reuses226 := 0
func wake226(node: Sprite3D) -> Sprite3D:
 node.show();node.modulate=Color.WHITE
 for child in node.get_children():
  if child.get_script()!=null and "enabled" in child:
   child.enabled=battle.silhouettes_enabled;child.set_process(true);child.set_physics_process(true)
 return node
func sprite153() -> Sprite3D:
 if blades226.is_empty():births226+=1;return super.sprite153()
 reuses226+=1
 var node=wake226(blades226.pop_back());var ink=ink154(node)
 for param in ["bend154","squash154","collapse154","clip_tip158"]:ink.set_shader_parameter(param,0.)
 ink.set_shader_parameter("fade154",1.)
 return node
func pad_sprite158() -> Sprite3D:
 if pads226.is_empty():births226+=1;return super.pad_sprite158()
 reuses226+=1;return wake226(pads226.pop_back())
func release_sprite153(node: Sprite3D) -> void:
 var pool=blades226 if node.has_meta("mesh154") else pads226
 if pool.size()>=IDLE_LIMIT226:node.queue_free();return
 node.hide()
 for child in node.get_children():
  if child.get_script()!=null and "enabled" in child:
   child.enabled=false;child.hide();child.set_process(false);child.set_physics_process(false)
 pool.append(node)
func reset153() -> void:
 super.reset153();flights154.clear()
