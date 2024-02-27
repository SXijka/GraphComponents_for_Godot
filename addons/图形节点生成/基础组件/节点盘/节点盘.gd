class_name 节点盘
extends Control
## 支持拖动和放置[节点]等行为的容器。
## 按[kbd]Q[/kbd]以将视角移至众节点的中心，按住[kbd]Ctrl[/kbd]并划动[kbd]滚轮[/kbd]以缩放界面。[br]
## 按住[kbd]右键[/kbd]向右可框选盘中[节点]。若同时按住[kbd]Ctrl[/kbd]，向右框选可持续选中多个节点，向左可取消选中特定节点。[br]
## 双击[kbd]左键[/kbd]可取消框选。

const 至众节点时间: float = 1.0

## 节点盘就绪时将自动加载至盘面的控件列表，[code]null[/code]被忽略。
@export var 初始加载内容: Array[Control] = []

## 是否将节点盘实例的子节点作为内容加入盘面的控件列表。与将节点加入[param 初始加载内容]有相同效果。
@export var 自动获取子节点为内容: bool = true

## 是否允许拖动节点盘。拖动时，位于盘面的控件将与节点盘同步移动。
@export var 允许拖动: bool = true:
	set = _设置拖动

## 选中节点后，节点向框的颜色插值转变的程度。
@export var 选中变色: float = 0.5

## 选择框的颜色。
@export var 框颜色: Color = Color.AQUA

## 选择框边缘的宽度。
@export var 框线宽:float = 2

## 选择框内部的透明度，若为[code]1[/code]，选择框为实心，若为[code]0[/code]，选择框为空心。
@export var 框内透明度: float = 0.1

var 选中节点: Array[节点] = []

var _正在框选: bool = false

var _选框: Rect2

var _正在拖动多个: bool = false

var _至众节点动画: Tween

var _上一个位置:Vector2

@onready var _背景盘: Panel = $"可调整边框/背景盘"
@onready var _盘边缘: ReferenceRect = $"可调整边框/背景盘/盘边距/盘边缘"
@onready var _边框: 可调整边框 = $"可调整边框"
@onready var _盘面: Control = $"可调整边框/背景盘/盘边距/盘边缘/盘面"

signal 选中节点集(节点集: Array[节点])

func _ready() -> void:
	_设置拖动(允许拖动)
	_上一个位置 = _边框.global_position

	添加_多个控件(初始加载内容)
	if 自动获取子节点为内容:
		添加_多个控件.call_deferred(_获取实例子节点())

	_背景盘.gui_input.connect(_框选)

	_盘边缘.draw.connect(绘制方框)


func _input(事件: InputEvent) -> void:
	if _边缘超出():
		_边框.global_position = _上一个位置
	else:
		_上一个位置 = _边框.global_position
		
	if 事件.is_action_pressed("视角移至众节点中心"):
		视角移至众节点中心()
		
	_拖动选中节点(事件)


func _拖动选中节点(事件: InputEvent) -> void:
	if 事件 is InputEventMouseMotion:

		if _正在拖动多个: # 前置拖动代码以确保响应，否则鼠标移动一快就会失去追踪，拖动就会停止，影响UI体验。
			for i in 选中节点:
				i.节点全局中心位置 += 事件.relative

		_正在拖动多个 = false
		if 选中节点.is_empty():
			return
		if not 事件.button_mask & MOUSE_BUTTON_LEFT:
			return
		if _正在框选:
			return

		var 鼠标在某个选中节点中:= false
		for i in 选中节点:
			if i.节点全局矩形.has_point(get_global_mouse_position()):
				鼠标在某个选中节点中 = true
		if not 鼠标在某个选中节点中:
			return
		_正在拖动多个 = true

	if 事件 is InputEventMouseButton:
		if 事件.button_index == MOUSE_BUTTON_LEFT and 事件.double_click:
			for n in 选中节点:
				n.允许拖动 = true
				n.modulate = Color.WHITE
			选中节点.clear()


func _框选(事件: InputEvent) -> void:
	if 事件 is InputEventMouseButton:
		if 事件.button_index == MOUSE_BUTTON_RIGHT and 事件.pressed:
			_选框.position = get_global_mouse_position()
			_选框.end = get_global_mouse_position()
			_正在框选 = true

			if not 事件.is_command_or_control_pressed():
				for n in 选中节点:
					n.允许拖动 = true
					n.modulate = Color.WHITE
				选中节点.clear()

		elif 事件.button_index == MOUSE_BUTTON_RIGHT and !事件.pressed:
			_正在框选 = false
			_选框.end = get_global_mouse_position()
			_盘边缘.queue_redraw()
			
			var 右框选 := true
			if _选框.size.x < 0:
				_选框.position.x += _选框.size.x
				_选框.size.x = abs(_选框.size.x)
				右框选 = false
			if _选框.size.y < 0:
				_选框.position.y += _选框.size.y
				_选框.size.y = abs(_选框.size.y)

			var 框选区域 := 区域.new()
			框选区域.名称 = "框选"
			框选区域.global_position = _选框.position
			框选区域.size = _选框.size
			add_child(框选区域)

			if 右框选:
				var 盘中节点 := get_tree().get_nodes_in_group("节点")
				for n: 节点 in 盘中节点:
					if 区域.相交于(n.节点全局矩形, "框选") and n.visible and n.允许拖动 and not n.半透明节点:
						if n in 选中节点:
							continue
						选中节点.append(n)
						n.modulate = n.modulate.lerp(框颜色, 选中变色)
						n.允许拖动 = false

			elif 事件.is_command_or_control_pressed():
				for n:节点 in 选中节点:
					if 区域.相交于(n.节点全局矩形, "框选"):
						n.允许拖动 = true
						n.modulate = Color.WHITE
						选中节点.erase(n)

			框选区域.queue_free()



	if 事件 is InputEventMouseMotion:
		_盘边缘.queue_redraw()
		if 事件.button_mask & MOUSE_BUTTON_MASK_RIGHT and _正在框选:
			_选框.end = get_global_mouse_position()


func 绘制方框():
	if not _正在框选:
		return
	var 方框 := _选框
	方框.position = _盘边缘.make_canvas_position_local(方框.position)
	var 方框颜色 = 框颜色
	_盘边缘.draw_rect(方框, 方框颜色, false, 框线宽)
	方框颜色.a = 框内透明度
	_盘边缘.draw_rect(方框, 方框颜色, true)


func 视角移至众节点中心() -> void:
	var 节点集合: Array[Vector2] = []
	for n:节点 in get_tree().get_nodes_in_group("节点"):
		if not n.visible:
			continue
		节点集合.append(n.节点全局中心位置)
	if 节点集合.is_empty():
		return
	_边框.允许拖动 = false
	if _至众节点动画:
		_至众节点动画.kill()
	_至众节点动画 = create_tween()
	_至众节点动画.set_trans(Tween.TRANS_CUBIC)
	_至众节点动画.tween_property(_边框, "global_position", _边框.global_position + _全局中心() - _计算中间(节点集合), 至众节点时间)
	_至众节点动画.tween_callback(func(): _边框.允许拖动 = true)


## 添加多个控件到节点盘的盘面。
## [param 待添加] 要添加的控件列表。
func 添加_多个控件(待添加: Array[Control]) -> void:
	for i in 待添加:
		if not i:
			continue

		elif i.get_parent():
			i.reparent(_盘面)

		else:
			_盘面.add_child(i)


## 仅返回盘面的下一级类型为Control的子节点，盘面子节点的子节点不会被包含。[br]
## 若填写[param 组筛选]，则会筛除不属于所填节点组的子节点。
func 获取_盘面中控件(组筛选: StringName = "") -> Array[Control]:
	var 节点集 := _盘面.get_children()
	节点集.filter(func(n:Control): return n.get_parent() == _盘面)
	if not 组筛选.is_empty():
		节点集.filter(func(n:Control): return n.is_in_group(组筛选))
	var 盘面中: Array[Control] = []
	盘面中.assign(节点集)
	return 盘面中


func _设置拖动(允许: bool) -> void:
	允许拖动 = 允许
	if not _边框:
		return
	_边框.允许拖动 = 允许


func _计算中间(各位置: Array) -> Vector2:
	var _总和 = Vector2()
	for _位置 in 各位置:
		_总和 += _位置
	return _总和 / 各位置.size()


func _全局中心()-> Vector2:
	return get_global_rect().get_center()


func _边框全局中心()-> Vector2:
	return _边框.get_global_rect().get_center()


func _边缘超出() -> bool:
	return !_盘边缘.get_global_rect().encloses(get_global_rect())


## 获取节点下的所有子节点（除了边框节点）。
## 子节点组成的数组。
func _获取实例子节点() -> Array[Control]:
	var 节点集: Array[Control] = []
	节点集.append_array(get_children())
	节点集.erase(_边框)
	return 节点集
