extends RefCounted
const POOL := [
	{"id":"slingshot","name":"橡皮筋弹弓","desc":"课间自制的小枪枪～","line":"是巴雷特啦……","fx":"按住开火蓄力，松手发射穿透重弹（满蓄 12×）","fx2":"威力增强：满蓄 14×，蓄力更快","max":2},
	{"id":"eye_exercise","name":"眼保健操","desc":"那个小朋友在疯狂眨眼睛呀？","line":"我还不想戴眼镜…","fx":"射速 +50%，弹幕微追踪","fx2":"射速 +25%，追踪增强","max":2},
	{"id":"cup_phone","name":"纸杯电话","desc":"我们是在使用对讲机的高级特工！","line":"侦察兵小黑鹅出动！","fx":"小黑鹅自由移动并造成接触伤害","max":1},
]
var levels: Dictionary={}

func level(id: String) -> int: return int(levels.get(id,0))
func eligible() -> Array[Dictionary]:
	var result: Array[Dictionary]=[]
	for card in POOL:
		if level(card.id)<card.max: result.append(card.duplicate(true))
	return result
func apply(id: String) -> bool:
	for card in eligible():
		if card.id==id: levels[id]=level(id)+1; return true
	return false
func rate() -> float:
	return 1. if level("eye_exercise")==0 else (1.5 if level("eye_exercise")==1 else 1.875)
func description(card: Dictionary) -> String:
	return str(card.fx2) if level(card.id)>0 and card.has("fx2") else str(card.fx)
func summary() -> String:
	var names := PackedStringArray()
	for card in POOL:
		if level(card.id)>0: names.append(str(card.name)+(" Ⅱ" if level(card.id)>1 else ""))
	return " · ".join(names)
