extends RefCounted
const TOTAL=1
const WAVES=[]
var spawned=1
var defeated=0
var wave=0
var incoming=0
var seconds=0.
var retry_left=0.
func live_cap() -> int:return 1
func complete() -> bool:return defeated==1
func needs_entry(_alive: int) -> bool:return false
func snapshot() -> Dictionary:return {"total":1,"spawned":1,"defeated":defeated,"seconds":seconds,"wave":0,"cap":1}
