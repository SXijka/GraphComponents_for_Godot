class_name 组件配置
extends Resource

@export var 默认名称: String = "你好"
@export var hel:int = 3


func 执行配置(目标: 组件):
	目标.名称 = 默认名称
	pass
