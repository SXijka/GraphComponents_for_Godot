class_name 槽位
extends 组件

@export var 最小接口数量: int

func _ready() -> void:
	if 最小接口数量 > 宾客_数量():
		for i in range(最小接口数量 - 宾客_数量()):
			var 默认接口 = 接口.new()
			add_child(默认接口)
			连接到(默认接口,false)
	#for i in 获取_宾客():
		#print("K"+str(i))
		#请求断开(i)
	print(名称)
