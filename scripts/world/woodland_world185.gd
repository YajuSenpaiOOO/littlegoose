extends "res://scripts/world/woodland_world173.gd"
const FOREST185=preload("res://scripts/world/forest_plan183.gd")
var forest185: Node3D
var forest_ready185 := false
var removed_trees185 := 0
var connection185 := PackedVector2Array()
class YardRoute185:
 extends "res://scripts/combat/woodland_navigation21.gd"
 func grid_half_extent21() -> Vector2i: return Vector2i(28,20)
func _init() -> void:
 super._init();memory_save116="user://forest185_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 185 · 大地图 / 紫布舞台树 / 接地阴影")
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface183.gd").new()
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces183.gd")
func _hero_script() -> Script: return preload("res://scripts/combat/hero183.gd")
func _build_woodland() -> void:
 super._build_woodland()
 var keep: Array[Dictionary]=[]
 for tree in trees:
  if FOREST185.tree_clear183(Vector2(tree.root.position.x,tree.root.position.z)):
   tree.root.free();removed_trees185+=1
  else: keep.append(tree)
 trees.assign(keep)
func _grass_growth92(at: Vector2) -> float:
 if FOREST185.affects183(at) and preload("res://scripts/world/forest_dressing183.gd").distance183(at-FOREST185.CENTER)<1.: return 0.
 if FOREST185.affects183(at):
  return .0 if FOREST185.path_sample(at-FOREST185.CENTER).x<1.9 else .24
 return super._grass_growth92(at)
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 # Later inherited scenery passes also plant trees. Keep references valid for
 # their lighting services, while clearing only the new bowl and yard approach.
 for tree in trees:
  if FOREST185.tree_clear183(Vector2(tree.root.position.x,tree.root.position.z)):
   tree.root.hide()
   for child in tree.root.find_children("*","CollisionObject3D",true,false): child.collision_layer=0
 # Existing decorative rocks in the new bowl must not float at the old grade.
 for rock in forest87.rocks87:
  if FOREST185.tree_clear183(rock.at):
   rock.visual.hide();rock.body.collision_layer=0;rock.shadow.hide()
 for plant in forest87.plants87:
  if FOREST185.tree_clear183(Vector2(plant.position.x,plant.position.z)): plant.hide()
 forest185=preload("res://scripts/art/forest_art185.gd").new();forest185.world=self;add_child(forest185)
 await get_tree().physics_frame;await get_tree().physics_frame
 var route := YardRoute185.new();route.bake(get_world_3d().direct_space_state,meadow,Vector2(-13.,0.))
 connection185=route.path(Vector2(-4.7,-2.6),FOREST185.CENTER+FOREST185.ENTRY)
 # A short stepping-stone trail follows the existing workshop's real collision
 # gaps, instead of moving its biscuit tin, pot, benches or low stone edging.
 var last := Vector2.INF
 for point in connection185:
  if point.distance_to(last)<1.15 or point.x> -6.: continue
  last=point;var local := point-FOREST185.CENTER
  forest185.box(Vector3(.24,.025,.16),Vector3(local.x,floor_height(point)+.025,local.y),forest185.ink("a59978"))
 # Cached grass poses predate the new worn trail. Trim only this local strip,
 # including the stair mouths, so blades do not poke through the tread art.
 for batch in grass_batches:
  for i in batch.points.size():
   var at: Vector3=batch.points[i].origin;var p := Vector2(at.x,at.z)
   if not Rect2(-67.,-18.,54.,33.).has_point(p): continue
   if preload("res://scripts/world/forest_dressing183.gd").distance183(p-FOREST185.CENTER)>1.0: continue
   var pose: Transform3D=batch.node.multimesh.get_instance_transform(i);pose.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);batch.node.multimesh.set_instance_transform(i,pose)
 forest_ready185=true;_teleport15(FOREST185.CENTER+Vector2(10.,6.8));_title35()
 var canvas := CanvasLayer.new();canvas.layer=12;add_child(canvas)
 var text := Label.new();text.text="185 错落枝叶 / 紫布小舞台 / 接地阴影\nF8 样板 / F6 入口 / F7 小屋 / F3 小院\n岩壁凹窝小屋 · F9 阴影对照";text.position=Vector2(24,200);text.add_theme_font_size_override("font_size",17);text.add_theme_color_override("font_shadow_color",Color.BLACK);text.add_theme_constant_override("shadow_outline_size",5);text.mouse_filter=Control.MOUSE_FILTER_IGNORE;canvas.add_child(text)
func _input(event: InputEvent) -> void:
 if forest_ready185 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F9:
  forest185.set_grounding184(not forest185.grounding_on184);get_viewport().set_input_as_handled();return
 if forest_ready185 and not active114 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed:
  if event.physical_keycode==KEY_F8:
   _teleport15(FOREST185.CENTER+Vector2(10.,6.8));get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_F6,KEY_F7]:
   _teleport15(FOREST185.CENTER+(FOREST185.ENTRY if event.physical_keycode==KEY_F6 else Vector2(-10.4,-8.1)));get_viewport().set_input_as_handled();return
 super._input(event)




