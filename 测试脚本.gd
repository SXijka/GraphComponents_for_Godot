extends Control

@onready var a: 节点 = $"节点盘/节点A"
@onready var r: 区域 = $"节点盘/ReferenceRect"






func _process(delta: float) -> void:
	print((a as 节点).节点全局矩形,r.get_global_rect())
	if 区域.相交于((a as 节点).节点全局矩形, "kar"):
		print("zzz")
		a.允许拖动 = false
		区域.移出_扩展(a, "kar", a.节点全局矩形,40,0.5)
		await get_tree().create_timer(0.5).timeout
		a.允许拖动 = true
