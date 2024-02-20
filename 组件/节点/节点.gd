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

@export var 自动获取子节点为内容: bool = false ## 是否自动获取节点实例下的子节点作为内容物加入节点。

@export var 允许垂直调整: bool = false:
	set = _设置垂直调整

@export var 初始加载内容: Array[Control] = [] ## 在节点就绪时将其中的项加入节点，空值被忽略，各项自动取消隐藏。

@export var 内容扩展对齐: bool = false ## 在将内容加入节点时设置其为垂直扩展对齐，特别适用于仅有一个内容的节点。

@export var 节点大小: Vector2:
	get = _获取节点大小,
	set = _设置节点大小

@export var 节点全局中心位置: Vector2:
	get = _获取节点全局中心位置,
	set = _设置节点全局中心位置


@onready var 节点名称: Label = $"可调整边框/节点内容/标题栏背景/标题栏边距/左右布局/节点名称"
@onready var 底部背景: Panel = $"可调整边框/节点内容/面板背景/底部背景"
@onready var 标题栏背景: PanelContainer = $"可调整边框/节点内容/标题栏背景"
@onready var 面板背景: PanelContainer = $"可调整边框/节点内容/面板背景"
@onready var 背景点: 点背景 = $"可调整边框/节点内容/面板背景/背景容器/点背景"
@onready var 面板: VBoxContainer = $"可调整边框/节点内容/面板背景/面板容器/面板"
@onready var 边框: 可调整边框 = $"可调整边框"
@onready var 隐蔽连接线按钮: Button = $"可调整边框/节点内容/标题栏背景/标题栏边距/左右布局/隐蔽连接线按钮"


func _init() -> void:
	add_to_group("节点")


func _ready() -> void:
	_设置名称(名称)
	_设置标记颜色(标记颜色)
	_设置背景颜色(背景颜色)
	_设置背景点图案(背景点图案)
	_设置背景点颜色(背景点颜色)
	_设置垂直调整(允许垂直调整)
	隐蔽连接线按钮.toggled.connect(接口连接线隐蔽)

	if not Engine.is_editor_hint():
		添加_多个内容(初始加载内容)

		if 自动获取子节点为内容:
			添加_多个内容(获取实例子节点())


func 添加_内容(内容物: Control) -> void: ## 向节点中添加内容物，自动取消隐藏。
	内容物.show()
	if 内容物.get_parent():
		内容物.reparent(面板)
	else:
		面板.add_child(内容物)
	if not 内容扩展对齐:
		return
	for 属性 in 内容物.get_property_list():
		if 属性["name"] == "size_flags_vertical":
			内容物.set("size_flags_vertical", SIZE_EXPAND_FILL)


func 添加_多个内容(内容物集: Array[Control]) -> void: ## 传入一个列表，将其中所有项均作为内容物加入节点，自动取消隐藏。
	for 内容物 in 内容物集:
		if not 内容物:
			continue

		elif 内容物.get_parent():
			内容物.show()
			内容物.reparent(面板)

		else:
			内容物.show()
			面板.add_child(内容物)

		if not 内容扩展对齐:
			continue
		for 属性 in 内容物.get_property_list():
			if 属性["name"] != "size_flags_vertical":
				continue
			内容物.set("size_flags_vertical", SIZE_EXPAND_FILL)


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
		var 内容物集: Array[Control] = []
		内容物集.append_array(面板.get_children())
		return 内容物集


func 存在_内容(内容物: Control) -> bool:
	if not 内容物:
		return false
	if 内容物 not in 获取_内容():
		return false
	return true


func 接口连接线隐蔽(是隐蔽: bool):
	print(是隐蔽)
	for i in 获取_内容():
		if i is 接口:
			i.隐蔽已有连接线 = 是隐蔽


func 获取实例子节点() -> Array[Control]:
	var 节点集: Array[Control] = []
	节点集.append_array(get_children())
	节点集.erase(边框)
	return 节点集


func _获取节点大小() -> Vector2:
	return 边框.size


func _设置节点大小(新大小: Vector2) -> void:
	节点大小 = 新大小
	if not 边框:
		return
	边框.size = 新大小


func _获取节点全局中心位置() -> Vector2:
	return 边框.get_global_rect().get_center()


func _设置节点全局中心位置(新中心: Vector2) -> void:
	if not 边框:
		return
	var 新位置 = position + (新中心 - 边框.get_global_rect().get_center())
	position = 新位置


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
		return
	背景点.图案 = 新图案


func _设置垂直调整(允许: bool):
	允许垂直调整 = 允许
	if not 边框:
		return
	边框.允许垂直调整 = 允许
