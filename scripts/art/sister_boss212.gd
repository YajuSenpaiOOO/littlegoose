extends "res://scripts/art/sister_transport211.gd"
## Isolated encounter prototype: no world combat/progression mutation.
var phase212 := "prepare"
var clock212 := 0.
var hp212 := 6
var hit_gate212 := 0.
var interrupted212 := false
var end_lift212 := .70
var lowered_at212 := Vector2.ZERO
var threads212: MeshInstance3D
const TIMES212 = {"prepare":1.4,"send":2.8,"pounce":3.0,"recall":2.6,"lower":1.,"open":4.,"rise":1.2,"done":99999.}
const FLOW212 = ["prepare","send","pounce","recall","lower","open","rise"]

func _ready() -> void:
 super._ready()
 threads212=MeshInstance3D.new();threads212.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink=StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color("f3cfe9")
 threads212.material_override=ink;add_child(threads212)
 restart()

func restart() -> void:
 super.restart()
 phase212="prepare";clock212=0.;hp212=6;hit_gate212=0.;interrupted212=false
 if is_instance_valid(world.get("drops206")): world.drops206.clear206()
 evaluate()

func change212(next: String) -> void:
 phase212=next;clock212=0.;state_history.append(next)
 if next=="send": emitted206=0;interrupted212=false
 if next=="recall": world.drops206.begin_recall212()
 if next=="lower":
  end_lift212=lift;lowered_at212=person_at
  world.drops206.clear206()
 if next=="rise":
  var old=start_at;start_at=person_at;end_at=old
 if next=="done": world.drops206.clear206()

func parried212() -> void:
 if phase212 in ["send","pounce","recall"]:
  interrupted212=true
  # Defer clearing records until their current collision iteration finishes.
  world.notice206("弹反牵动丝线！蝙蝠失衡，吊床准备下降")

func advance(delta: float) -> void:
 if not running: return
 elapsed+=delta;clock212+=delta;hit_gate212=maxf(0.,hit_gate212-delta)
 if interrupted212 and phase212 in ["send","pounce","recall"]:
  change212("lower")
 elif clock212>=float(TIMES212[phase212]):
  var index=FLOW212.find(phase212)
  change212(FLOW212[(index+1)%FLOW212.size()])
 evaluate()
 if phase212=="send" and drop_enabled206 and emitted206<2 and clock212>=[.65,1.5][emitted206]:
  emitted206+=1
  var desired=Vector2(world.hero.position.x,world.hero.position.z)
  # Toys land near the carrier, then their existing pounce targets the hero.
  var origin=world.drops206.safe_target206(person_at,person_at+(desired-person_at).limit_length(2.4))
  world.drops206.spawn206(origin,ground(person_at)+Vector3.UP*(lift+.65))
 swing206=sin(elapsed*3.)*(.065 if interrupted212 and phase212=="lower" else .018)

func evaluate() -> void:
 state="travel";age=0.
 var t=clampf(clock212/float(TIMES212[phase212]),0.,1.)
 var at=end_at if phase212 in ["pounce","recall","lower","open","done"] else start_at
 if phase212 in ["lower","open","done"]: at=lowered_at212
 if phase212=="send": at=start_at.lerp(end_at,ease205(t))
 person_at=at;rig_at=at;rig_visible=true;sitting=true;lift=.70
 if phase212=="lower": lift=lerpf(end_lift212,.08,ease205(t))
 if phase212 in ["open","done"]: lift=.08
 if phase212=="rise": lift=lerpf(.08,.70,ease205(t))
 body.global_position=ground(at)
 contact.global_position=ground(at)+Vector3.UP*.03
 contact_ink.set_shader_parameter("strength",.20)

func counter212() -> bool:
 if not running or phase212!="open" or hit_gate212>0.: return false
 var here=Vector2(world.hero.position.x,world.hero.position.z)
 if here.distance_to(person_at)>1.65 or absf(world.hero.position.y-ground(person_at).y)>.65:
  world.notice206("再靠近一点，吊床落地时按 E 轻拍");return false
 hp212=maxi(0,hp212-1);hit_gate212=.7
 world.notice206("轻拍成功！姐姐抱紧了玩偶")
 if hp212==0: change212("done")
 return true

func label() -> String:
 return {"prepare":"蝙蝠蓄力 · 准备投放","send":"低空投放","pounce":"玩偶锁定后扑击","recall":"丝线绷紧 → 玩偶回收","lower":"吊床缓缓下降","open":"反击窗口 · 靠近按 E 轻拍","rise":"蝙蝠重新抬床","done":"试演完成 · F7 重开"}[phase212]

func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(threads212): return
 seated.scale=Vector3(1.+hit_gate212*.07,1.-hit_gate212*.07,1.)
 threads212.visible=phase212=="recall" and not world.drops206.records.is_empty()
 if not threads212.visible: return
 var mesh=ImmediateMesh.new();mesh.surface_begin(Mesh.PRIMITIVE_LINES)
 for item in world.drops206.records:
  mesh.surface_add_vertex(to_local(ground(person_at)+Vector3.UP*(lift+.8)))
  mesh.surface_add_vertex(to_local(item.card.global_position+Vector3.UP*.15))
 mesh.surface_end();threads212.mesh=mesh
