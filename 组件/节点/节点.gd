@tool
class_name 节点
extends Control


@export var 名称: String = "节点":
	set = _设置名称

@export_color_no_alpha var 标记颜色: Color = Color.ROYAL_BLUE:
	set = _设置标记颜色

@export var 背景颜色: Color = Color(0.15, 0.15, 0.15, 1.0):
	set = _设置背景颜色

@export var 背景点颜色: Color = Color(0.2, 0.2, 0.2, 1.0):
	set = _设置背景点颜色

@export_enum("点","叉","十","一") var 背景点图案: String = "十":
	set = _设置背景点图案

@export var 展开: bool = true

@export var 初始加载内容: Array[Control] = [] ## 在节点就绪时将其中的项加入节点，空值被忽略，各项自动取消隐藏。

@export var 自动获取子节点为内容: bool = false ## 是否自动获取节点实例下的子节点作为内容物加入节点。

@onready var 节点名称: Label = $"可调整边框/节点内容/标题栏背景/标题栏边距/左右布局/节点名称"
@onready var 底部背景: Panel = $"可调整边框/节点内容/面板背景/面板容器/底部背景"
@onready var 标题栏背景: PanelContainer = $"可调整边框/节点内容/标题栏背景"
@onready var 面板背景: PanelContainer = $"可调整边框/节点内容/面板背景"
@onready var 背景点: 点背景 = $"可调整边框/节点内容/面板背景/背景容器/点背景"
@onready var 面板: VBoxContainer = $"可调整边框/节点内容/面板背景/面板容器/面板"
@onready var 边框: 可调整边框 = $"可调整边框"

func _init() -> void:
	add_to_group("节点")


func _ready() -> void:
	_设置名称(名称)
	_设置标记颜色(标记颜色)
	_设置背景颜色(背景颜色)
	_设置背景点图案(背景点图案)
	_设置背景点颜色(背景点颜色)

	if not Engine.is_editor_hint():
		添加_多个内容(初始加载内容)

		if 自动获取子节点为内容:
			if get_child_count() <= 1:
				pass
			var 子节点 := get_children()
			子节点.erase(边框)
			for i in 子节点:
				添加_内容(i as Control)


func 添加_内容(内容物: Control) -> void: ## 向节点中添加内容物，自动取消隐藏。
	内容物.show()
	if 内容物.get_parent():
		内容物.reparent(面板)
	else:
		面板.add_child(内容物)


func 添加_多个内容(内容物: Array[Control]) -> void: ## 传入一个列表，将其中所有项均作为内容物加入节点，自动取消隐藏。
	for i in 内容物:
		if not i:
			continue
		elif i.get_parent():
			i.show()
			i.reparent(面板)
		else:
			i.show()
			面板.add_child(i)


func 弹出_内容(内容物: Control) -> Control: ## 将一个内容物移出节点并返回，若返回值为null，则节点不包含该内容物。
	if not 存在_内容(内容物):
		return null
	面板.remove_child(内容物)
	return 内容物


func 删除_内容(内容物: Control) -> void:
	if not 存在_内容(内容物):
		return
	内容物.queue_free()


func 按索引_删除(索引: int) -> bool:
	if 索引 >= 获取_内容().size():
		return false
	else:
		获取_内容()[索引].queue_free()
		return true


func 清空_内容() -> void:
	for i in 获取_内容():
		i.queue_free()


func 获取_内容() -> Array[Control]:
	if 面板.get_child_count() == 0:
		return []
	else:
		return 面板.get_children() as Array[Control]


func 存在_内容(内容物: Control) -> bool:
	if not 内容物:
		return false
	if 内容物 not in 获取_内容():
		return false
	return true


func _设置名称(新名称):
	名称 = 新名称
	if not 节点名称:
		return
	节点名称.text = 新名称


func _设置标记颜色(新颜色: Color):
	标记颜色 = 新颜色
	if not 标题栏背景:
		return
	if not 底部背景:
		return
	标题栏背景.self_modulate = 新颜色
	底部背景.modulate = 新颜色


func _设置背景颜色(新颜色: Color):
	背景颜色 = 新颜色
	if not 面板背景:
		return
	面板背景.self_modulate = 新颜色


func _设置背景点颜色(新颜色: Color):
	背景点颜色 = 新颜色
	if not 背景点:
		return
	(背景点 as 点背景).点颜色 = 新颜色


func _设置背景点图案(新图案: String):
	背景点图案 = 新图案
	if not 背景点:
		print("na")
		return
	背景点.图案 = 新图案
