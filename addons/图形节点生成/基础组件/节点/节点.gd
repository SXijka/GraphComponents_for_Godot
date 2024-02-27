@tool
class_name 节点
extends Control
## [code]幻华破碎[/code]游戏中的独立元素，是[color=RoyalBlue]游戏中势力、个体、思想、行为或物品的具象化身与代表[/color]，
## 支持自定义属性设置，如名称、颜色等。[br]
## [code]节点[/code]是[color=yellow]节点式交互游戏模式[/color]的基础，
## 允许通过编辑器配置属性，并可自动管理子节点作为内容物。[br]
## [br]
## [i]功能关联[/i]: [br]
## - 与 [接口] 相互作用，通过[接口]管理[code]节点[/code]间的连接逻辑，实现[code]节点[/code]之间的动态交互。[br]
## - 支持动态背景和标记颜色设置，增强视觉识别。[br]
## - 提供了垂直调整和自动内容管理的功能，适应不同的布局需求。[br]

@export_subgroup("节点外观")
## 节点的自定义名称，支持通过编辑器设置。
@export var 名称: String = "节点":
	set = _设置名称

## 节点标记的颜色，使用预设的皇家蓝色，不包含透明度。
@export_color_no_alpha var 标记颜色: Color = Color.ROYAL_BLUE:
	set = _设置标记颜色

## 节点背景的颜色，默认为深灰色。
@export var 背景颜色: Color = Color(0.15, 0.15, 0.15, 1.0):
	set = _设置背景颜色

## 节点背景点的颜色，默认为稍亮的灰色。
@export var 背景点颜色: Color = Color(0.2, 0.2, 0.2, 1.0):
	set = _设置背景点颜色

## 背景点的图案类型，可选值包括“点”、“叉”、“十”、“一”，默认为“十”。
@export_enum("点","叉","十","一") var 背景点图案: String = "十":
	set = _设置背景点图案

## 更改值可隐藏或显示面板内容。
@export var 隐藏面板: bool = false:
	set = _设置隐藏面板

## 更改值可使节点整体半透明。
@export var 半透明节点: bool = false:
	set = _设置半透明节点

@export_subgroup("节点行为")
## 节点就绪时自动加载至面板的内容物列表，[code]null[/code]被忽略，内容物自动[color=yellow]取消隐藏[/color]。
@export var 初始加载内容: Array[Control] = []

## 是否自动获取节点下的子节点作为内容物加入节点，默认关闭。
@export var 自动获取子节点为内容: bool = false

## 是否允许垂直调整节点垂直大小，默认关闭，可为专门用于展示的节点，如[文本节点]打开。
@export var 允许垂直调整: bool = false:
	set = _设置垂直调整

## 是否允许拖动节点大小，默认开启，可为不可移动的用于设定、叙事的节点关闭。
@export var 允许拖动: bool = true:
	set = _设置拖动

## 是否允许调整节点大小，默认打开，若关闭则[param 是否允许垂直调整]无意义。
@export var 允许调整: bool = true:
	set = _设置调整

## 在将内容加入节点时是否设置其为垂直扩展对齐，默认关闭。适用于单个内容的场景。
@export var 内容扩展对齐: bool = false

@export_subgroup("节点信息")
## 获取或设置节点的非全局大小。若要获取全局大小，使用[code]节点全局矩形.size[/code]
@export var 节点大小: Vector2:
	get = _获取节点大小,
	set = _设置节点大小

## 获取或设置节点的全局矩形（global_rect）。
@export var 节点全局矩形: Rect2:
	get = _获取节点全局矩形,
	set = _设置节点全局矩形

## 获取或设置节点的全局中心位置。
@export var 节点全局中心位置: Vector2:
	get = _获取节点全局中心位置,
	set = _设置节点全局中心位置


@onready var _节点名称: Label = $"可调整边框/节点内容/标题栏背景/标题栏边距/左右布局/节点名称"
@onready var _底部背景: Panel = $"可调整边框/节点内容/面板背景/底部背景"
@onready var _标题栏背景: PanelContainer = $"可调整边框/节点内容/标题栏背景"
@onready var _面板背景: PanelContainer = $"可调整边框/节点内容/面板背景"
@onready var _背景点: 点背景 = $"可调整边框/节点内容/面板背景/背景容器/点背景"
@onready var _面板: VBoxContainer = $"可调整边框/节点内容/面板背景/面板容器/面板"
@onready var _边框: 可调整边框 = $"可调整边框"
@onready var _隐蔽按钮: Button = $"可调整边框/节点内容/标题栏背景/标题栏边距/左右布局/隐蔽按钮"

signal 隐蔽键左击
signal 隐蔽键中击
signal 隐蔽键右击
signal 大小变化

func _init() -> void:
	add_to_group("节点")


func _ready() -> void:
	_边框.item_rect_changed.connect(func():emit_signal("大小变化"))

	# 右键按钮以隐藏面板
	# 中键按钮以使面板半透明
	# 左键按钮以隐藏接口连接线
	_隐蔽按钮.gui_input.connect(
		func(e:InputEvent): 
			if e is InputEventMouseButton: 
				if e.button_index == MOUSE_BUTTON_RIGHT and !e.pressed:
					隐藏面板 = !隐藏面板
					emit_signal("隐蔽键右击")
				elif e.button_index == MOUSE_BUTTON_MIDDLE and !e.pressed:
					半透明节点 = !半透明节点
					emit_signal("隐蔽键中击")
				elif e.button_index == MOUSE_BUTTON_LEFT and !e.pressed:
					emit_signal("隐蔽键左击"))
	_隐蔽按钮.toggled.connect(接口连接线隐蔽)

	if not Engine.is_editor_hint():
		添加_多个内容(初始加载内容)

		if 自动获取子节点为内容:
			添加_多个内容(获取实例子节点())


## 添加单个内容物到节点，自动显示。
## [param 内容物] 要添加的控件。
func 添加_内容(内容物: Control) -> void: ## 向节点中添加内容物，自动取消隐藏。
	内容物.show()
	if 内容物.get_parent():
		内容物.reparent(_面板)
	else:
		_面板.add_child(内容物)
	if not 内容扩展对齐:
		return
	for 属性 in 内容物.get_property_list():
		if 属性["name"] == "size_flags_vertical":
			内容物.set("size_flags_vertical", SIZE_EXPAND_FILL)


## 添加多个内容物到节点，自动显示每个内容物。
## [param 内容物集] 要添加的控件列表。
func 添加_多个内容(内容物集: Array[Control]) -> void: ## 传入一个列表，将其中所有项均作为内容物加入节点，自动取消隐藏。
	for 内容物 in 内容物集:
		if not 内容物:
			continue

		elif 内容物.get_parent():
			内容物.show()
			内容物.reparent(_面板)

		else:
			内容物.show()
			_面板.add_child(内容物)

		if not 内容扩展对齐:
			continue
		for 属性 in 内容物.get_property_list():
			if 属性["name"] != "size_flags_vertical":
				continue
			内容物.set("size_flags_vertical", SIZE_EXPAND_FILL)


## 从节点移除指定内容物并返回。
## [param 内容物] 要移除的控件。
## 移除的控件，如果控件不存在则返回[code]null[/code]。
func 弹出_内容(内容物: Control) -> Control: ## 将一个内容物移出节点并返回，若返回值为[code]null[/code]，则节点不包含该内容物。
	if not 存在_内容(内容物):
		return null
	_面板.remove_child(内容物)
	return 内容物


## 删除指定的内容物。
## [param 内容物] 要删除的控件。
func 删除_内容(内容物: Control) -> void:
	if not 存在_内容(内容物):
		return
	内容物.queue_free()


## 从节点移除指定内容物并返回。
## [param 内容物] 要移除的控件。
## 移除的控件，如果控件不存在则返回[code]null[/code]。
func 按索引_删除(索引: int) -> bool:
	if 索引 >= 获取_内容().size():
		return false
	else:
		获取_内容()[索引].queue_free()
		return true


## 清空节点中的所有内容物。
func 清空_内容() -> void:
	for i in 获取_内容():
		i.queue_free()


## 获取节点中的所有内容物。
## 节点中所有内容物组成的数组。
func 获取_内容() -> Array[Control]:
	if _面板.get_child_count() == 0:
		return []
	else:
		var 内容物集: Array[Control] = []
		内容物集.append_array(_面板.get_children())
		return 内容物集


## 检查指定内容物是否存在于节点中。
## [param 内容物] 要检查的控件。
## 如果内容物存在则返回[code]true[/code]，否则返回[code]false[/code]。
func 存在_内容(内容物: Control) -> bool:
	if not 内容物:
		return false
	if 内容物 not in 获取_内容():
		return false
	return true


## 设置接口连接线的显示或隐藏状态。
## [param 是隐蔽] 指定是否隐藏连接线。
func 接口连接线隐蔽(是隐蔽: bool) -> void:
	for i in 获取_内容():
		if i is 接口:
			i.隐蔽已有连接线 = 是隐蔽


## 获取节点下的所有子节点（除了边框节点）。
## 子节点组成的数组。
func 获取实例子节点() -> Array[Control]:
	var 节点集: Array[Control] = []
	节点集.append_array(get_children())
	节点集.erase(_边框)
	return 节点集


## 返回该节点唯一的[可调整边框]，边框负责节点的调整和拖动。
func 获取_边框() -> 可调整边框:
	return _边框


## 检查控件是否与节点的边框相交。
## [param 控件] 要检查的控件。
## 如果相交则返回[code]true[/code]，否则返回[code]false[/code]。
func 相交于(控件: Control) -> bool:
	return 控件.get_global_rect().intersects(_边框.get_global_rect())


## 检查控件是否完全被节点的边框包含。
## [param 控件] 要检查的控件。
## 如果被包含则返回[code]true[/code]，否则返回[code]false[/code]。
func 被包含(控件: Control) -> bool:
	return 控件.get_global_rect().encloses(_边框.get_global_rect())


## 检查节点的边框是否完全包含一个控件。
## [param 控件] 要检查的控件。
## 如果节点包含控件则返回[code]true[/code]，否则返回[code]false[/code]。
func 包含(控件: Control) -> bool:
	return _边框.get_global_rect().encloses(控件.get_global_rect())


## 更改该节点隐蔽按钮工具提示文本。
func 按钮提示(提示: String) -> void:
	_隐蔽按钮.tooltip_text = 提示


## 更改该节点标题栏工具提示文本。
func 标题栏提示(提示: String) -> void:
	_标题栏背景.tooltip_text = 提示


## 节点的隐藏方式。
func 隐藏():
	hide()


## 节点的展现方式。
func 展现():
	show()


## 将满足筛选条件的所有[code]节点[/code]集中到给定坐标。[br]
## 若[param 坐标]保留为[constant @Vector2.INF]，则集中至[color=yellow]鼠标位置[/color]，
## 若[param 筛选条件]不填，则集中所有[code]节点[/code]。
static func 所有节点回归至(场景树: SceneTree, 坐标: Vector2 = Vector2.INF, 筛选条件:Callable = func():return true) -> void:
	var 节点集 := 场景树.get_nodes_in_group("节点").filter(筛选条件)
	if 节点集.size() == 0:
		return
	if 坐标 == Vector2.INF:
		坐标 = (场景树.get_first_node_in_group("节点") as 节点).get_global_mouse_position()
	for n:节点 in 节点集:
		n.节点全局中心位置 = 坐标


func _获取节点大小() -> Vector2:
	return _边框.size


func _设置节点大小(新大小: Vector2) -> void:
	节点大小 = 新大小
	if not _边框:
		await ready
	_边框.size = 新大小


func _获取节点全局矩形() -> Rect2:
	return _边框.get_global_rect()


func _设置节点全局矩形(新矩形: Rect2) -> void:
	节点全局矩形 = 新矩形
	if not _边框:
		await ready
	_边框.size = 新矩形.size * (_边框.size / _边框.get_global_rect().size)
	_设置节点全局中心位置(新矩形.get_center())


func _获取节点全局中心位置() -> Vector2:
	return _边框.get_global_rect().get_center()


func _设置节点全局中心位置(新中心: Vector2) -> void:
	节点全局中心位置 = 新中心
	if not _边框:
		await ready
	var 新位置 = position + (新中心 - _边框.get_global_rect().get_center())
	position = 新位置


func _设置隐藏面板(是隐藏: bool):
	隐藏面板 = 是隐藏
	if not _面板背景:
		await ready
	if 是隐藏:
		_面板背景.hide()
	else:
		_面板背景.show()


func _设置名称(新名称):
	名称 = 新名称
	if not _节点名称:
		await ready
	_节点名称.text = 新名称


func _设置标记颜色(新颜色: Color):
	标记颜色 = 新颜色
	if not _标题栏背景 or not _底部背景:
		await ready
	_标题栏背景.self_modulate = 新颜色
	_底部背景.modulate = 新颜色


func _设置背景颜色(新颜色: Color):
	背景颜色 = 新颜色
	if not _面板背景:
		await ready
	_面板背景.self_modulate = 新颜色


func _设置背景点颜色(新颜色: Color):
	背景点颜色 = 新颜色
	if not _背景点:
		await ready
	(_背景点 as 点背景).点颜色 = 新颜色


func _设置背景点图案(新图案: String):
	背景点图案 = 新图案
	if not _背景点:
		await ready
	_背景点.图案 = 新图案


func _设置垂直调整(允许: bool):
	允许垂直调整 = 允许
	if not _边框:
		await ready
	_边框.允许垂直调整 = 允许


func _设置调整(允许: bool):
	允许调整 = 允许
	if not _边框:
		await ready
	_边框.允许调整 = 允许


func _设置拖动(允许: bool):
	允许拖动 = 允许
	if not _边框:
		await ready
	_边框.允许拖动 = 允许


func _设置半透明节点(是半透明: bool):
	半透明节点 = 是半透明
	if 是半透明:
		modulate.a = 0.5
	else:
		modulate.a = 1.0

