extends RefCounted
const BATCHES=[["normal","normal","normal"],["normal","normal","normal","normal"],["predict","normal","normal","normal"],["roller","normal","normal","normal"],["predict","roller","normal","normal","normal"],["roller","roller","roller","normal"]]
const TOTAL=24
const WAVES=[4,4,4,5,4]
var spawned=3
var defeated=0
var wave=0
var incoming=0
var seconds=0.
var retry_left=0.
var final_called=false
var replacements=0
var queue: Array=[]
var cancelled_kind="normal"
func live_cap() -> int:return 4 if wave<4 else 5
func complete() -> bool:return spawned==TOTAL and defeated==TOTAL
func needs_entry(alive: int) -> bool:
 if queue.is_empty() and wave<5 and alive-incoming<=2 and defeated>0:
  wave+=1;queue=BATCHES[wave].duplicate()
 return not queue.is_empty() and alive<live_cap() and retry_left<=0.
func entered() -> bool:
 queue.pop_front();spawned+=1;retry_left=.45
 var final=wave==5 and not final_called
 if final:final_called=true
 return final
func cancelled() -> void:
 spawned-=1;queue.push_front(cancelled_kind);replacements+=1;retry_left=.6
func snapshot() -> Dictionary:return {"total":TOTAL,"spawned":spawned,"defeated":defeated,"seconds":seconds,"wave":wave,"cap":live_cap(),"pending":queue.size(),"replacement_entries":replacements,"batches":BATCHES}
