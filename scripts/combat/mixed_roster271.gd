extends RefCounted
const TOTAL=4
const WAVES=[]
var spawned=4
var defeated=0
var wave=0
var incoming=0
var seconds=0.
var retry_left=0.
func live_cap() -> int:return 4
func complete() -> bool:return defeated==4
func needs_entry(_alive: int) -> bool:return false
func snapshot() -> Dictionary:return {"total":4,"spawned":4,"defeated":defeated,"seconds":seconds,"wave":0,"cap":4}
