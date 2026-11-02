extends RefCounted
const PERIOD := .5
const WINDOW := .08
const GOOD := .16
var time := 0.
var last := 0
var perfects := 0
var normals := 0
var misses := 0
var events: Array[Dictionary]=[]
func reset() -> void:
 time=0.;last=0;perfects=0;normals=0;misses=0;events.clear()
func result237(beat: int,kind: String,offset := 0.) -> void:
 var hit=kind in ["perfect","early","late","auto"]
 events.append({"beat":beat,"kind":kind,"perfect":kind=="perfect","gain":1.4 if kind=="perfect" else (1. if hit else 0.),"offset":offset})
func press() -> void:
 var beat=maxi(1,roundi(time/period237()))
 var offset=time-beat*period237()
 if beat<=last:result237(beat,"too_late",offset);return
 if absf(offset)>great_window237()+.000001:result237(beat,"too_early" if offset<0. else "too_late",offset);return
 last=beat
 var perfect=absf(offset)<=perfect_window237()+.000001
 if perfect:perfects+=1
 else:normals+=1
 result237(beat,"perfect" if perfect else ("early" if offset<0. else "late"),offset)
func step(delta: float,held: bool,allowed: bool) -> void:
 time+=delta
 var due=floori((time-great_window237()-.000001)/period237())
 if due<=last:return
 # Retire crossed notes; only the latest can auto-fire, never catch-up volleys.
 var first=maxi(last+1,due-7)
 for beat in range(first,due+1):
  if allowed and held and beat==due:normals+=1;result237(beat,"auto")
  elif allowed:misses+=1;result237(beat,"miss")
  else:result237(beat,"skip")
 last=due
func drain() -> Array[Dictionary]:
 var result=events.duplicate();events.clear();return result

func period237() -> float:return PERIOD
func perfect_window237() -> float:return WINDOW
func great_window237() -> float:return GOOD
