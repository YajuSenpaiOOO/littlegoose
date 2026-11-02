extends "res://scripts/combat/paper_squad169.gd"
## Physics, payloads and markers stay inherited; update the final HUD once.
var hud_clock226 := .1
var legacy_canvas227 := false # Diagnostic A/B only; normal gameplay uses ground depth.
var markers227: MultiMeshInstance3D
var marker_clock227 := 0.
func _ready() -> void:
 super._ready()
 markers227=preload("res://scripts/combat/paper_markers227.gd").new();markers227.battle=battle;add_child(markers227)
func reset146() -> void:
 super.reset146()
 if is_instance_valid(markers227):markers227.clear227()
func draw146() -> void:
 # World indicators now live in the depth-tested ground mesh. Keep notebook UI.
 if legacy_canvas227:super.draw146()
 else:draw_notes146()
func _process(delta: float) -> void:
 if not is_instance_valid(battle.hero):return
 var active: bool=battle.active114 and not battle.result_open
 var plane: bool=battle.buffs.level("paper_plane")>0
 var notes: bool=battle.buffs.level("homework")>0
 if not battle.combat_paused:float_age162+=delta
 book146.visible=active and notes and (writing146 or not pages146.is_empty() or not pending146.is_empty())
 if book146.visible:update_book_pose146(delta)
 else:book_follow162.reset()
 hud146.visible=active and (plane or notes)
 hud_clock226+=delta
 if hud146.visible and hud_clock226>=.1:
  hud_clock226=0.
  var words="纸飞机 · 辅助六连投 · 在空%d架"%planes149.size() if plane else "直接射击"
  if notes:
   words+="\n笔记 %d/3 · "%pages146.size()+(("翻阅中 %.0f%%"%(write_age146/.65*100.)) if writing146 else "Q翻阅 · 闪避中止并保留")
  if hud146.text!=words:hud146.text=words
  hud146.position=Vector2(28,battle.get_viewport().get_visible_rect().size.y-108)
 if not battle.combat_paused:marker_clock227+=delta
 if marker_clock227>=1./30.:
  marker_clock227=0.;markers227.update227(self,active and plane and not legacy_canvas227)
 if active:art146.queue_redraw()
