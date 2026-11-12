extends "res://scripts/world/validate_paper304.gd"
class Harness305:
 extends "res://scripts/world/woodland_world305.gd"
 func export_stats226() -> Error:return OK
func world_script301() -> Script:return Harness305
func report304() -> String:return "res://docs/paper305-validation.json"
func shot301(tag: String) -> void:
 for i in 4:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/paper305-"+tag+".png")
func extra304() -> void:
 var c=solo303("knight");await settle(3);c.enter301("warn");var first=c.direction301
 w._teleport15(Vector2(c.position.x+3.,c.position.z));advance303(c,.8)
 check(c.direction301.distance_to(first)>.3,"knight follows player during charge")
 c.clock301=1.16;var locked=c.direction301;w._teleport15(Vector2(c.position.x-3.,c.position.z));advance303(c,.12)
 check((c.direction301==locked)==c.uses_legacy_aim305(),"charge tracking follows the version-specific lock timing")
 await shot301("charge-track")
 c.enter301("attack");check(c.ring_limit304==7.,"release reach adapts to moving target distance")
 c=solo303("monster");await settle(3);c.enter301("attack");c.height303=1.;c.vertical303=0.;var start=c.position
 w._teleport15(Vector2(c.position.x+2.,c.position.z))
 for i in 6:c.move301(Vector2.ZERO,1./60.)
 check(c.position.x>start.x+.1,"monster pursues player while suspended")
 c.height303=.4;c.vertical303=-3.;start=c.position;c.move301(Vector2.ZERO,.1)
 check(Vector2(c.position.x-start.x,c.position.z-start.z).length()<.01,"fast downswing commits instead of homing")
 c=solo303("dinosaur");await settle(3);c.enter301("attack");start=c.position;w._teleport15(Vector2(c.position.x-2.8,c.position.z+2.));c.direction301=Vector2.LEFT
 for i in 6:c.move301(Vector2.ZERO,1./60.)
 check(c.position.z>start.z+.1,"spraying dinosaur chases lateral alignment")
 check(c.visual.rotation.x==0. and c.fire303.width_axis303(Vector3.ZERO,Vector3.RIGHT,Vector3.ONE)==Vector3.UP,"tracking retains upright actor and fire planes")
 await shot301("spray-track")
