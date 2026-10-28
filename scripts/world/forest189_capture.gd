extends "res://scripts/world/forest180_probe.gd"
const P189=preload("res://scripts/world/forest_plan188.gd")
func picture189(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest189_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := preload("res://scripts/world/woodland_world189.gd").new();s.memory_save116="user://forest189_test.cfg";root.add_child(s)
 while not s.forest_ready188: await physics_frame
 var art: Node3D=s.forest188;var mood: Node=s.forest_mood188
 verify(art.flowers189.size()==11,"all eleven lilac tufts use touch bending")
 var flower: Sprite3D=art.flowers189[0].visual
 s._teleport15(Vector2(flower.global_position.x+.18,flower.global_position.z));await settle(30)
 var pushed: float=Vector3(art.flowers189[0].push).length()
 verify(pushed>.05,"hero contact drives flower displacement")
 s._teleport15(P189.CENTER+Vector2(4.,3.));s.hero.facing="down";s.hero.render_pose();await settle(100)
 verify(Vector3(art.flowers189[0].push).length()<.01,"flowers recover after hero leaves")
 verify(is_instance_valid(art.hammock_cat189) and art.hammock_cat189.visible,"new hammock cat is instantiated")
 await picture189("central_purple")
 var prev := -1.;var rising := true
 for p in mood.approach189:
  var weight: float=mood.route_weight189(Vector2(p.x,p.y))
  rising=rising and weight+0.02>=prev;prev=weight
 verify(rising and prev>.7,"entire connection route gains atmosphere progressively")
 var middle: Vector4=mood.approach189[mood.approach189.size()/2]
 s._teleport15(Vector2(middle.x,middle.y));await settle(100);await picture189("path_middle")
 s._teleport15(P189.CENTER+P189.ENTRY);await settle(100);await picture189("entry")
 s._teleport15(P189.CENTER+Vector2(-10.4,-7.5));await settle(100);await picture189("cottage")
 s._teleport15(Vector2(-4.7,-2.6));await settle(100);await picture189("home")
 verify(mood.amount<.02,"home remains outside the forest transition")
 FileAccess.open("res://docs/forest189-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("FOREST189_DONE ",failures);quit(0 if failures.is_empty() else 1)
