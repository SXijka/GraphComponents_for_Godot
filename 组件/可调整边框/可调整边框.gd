@tool
## 提供一个可供调整的边框，确保本体不可将输入继续传递到该组件，否则会影响该UI逻辑。
class_name 可调整边框
extends MarginContainer

## 可调整边框的本体，其gui输入影响判断边框的调整和拖动。
## 若运行时未设置本体，会自动尝试获取该节点下第一个子节点为本体。
@export var 本体: Control:
	get = _获取本体

@export var 边框宽度: float = 5: ## 该参数用以更方便地设置边框宽度。
	set = _设置边框宽度

@export var 允许调整: bool = true: ## 若为false，则无法进行调整。
	set = _许可调整

@export var 允许垂直调整: bool = true ## 控制是否允许垂直调整。

@export var 允许拖动: bool = true ## 若为false，则无法进行拖动。

@export var 区域反应表: Dictionary = {} ## [code]键[/code]为区域名称，[code]值[/code]为相交时所调用的无参数[Callable]。

var 正在_调整: bool = false ## 是否正在调整。不可与拖动同时为true，请只读。
var 正在_拖动: bool = false ## 是否正在调整。不可与拖动同时为true，请只读。

var _最近方向: String = ""
var _拖动量: Vector2 = Vector2.ZERO


signal 调整 ## 在边框进行调整后立刻发出。
signal 拖动 ## 在边框进行拖动后立刻发出。


func _ready() -> void:
	_设置边框宽度(边框宽度)
	本体.connect("gui_input", _进行拖动)
	connect("gui_input", _获取鼠标方向)


func _获取本体() -> Control:
	if Engine.is_editor_hint():
		return 本体
	if 本体 == null and not is_inside_tree():
		push_warning(self, "在进入场景树前试图获取本体，检查器内序列化值尚未填入，当前变量“本体”为null")
	elif 本体 == null:
		if get_child_count() != 0:
			本体 = get_child(0)
			push_warning(self, "未指定本体， 已获取第一个子节点为本体")
		else:
			push_warning(self, "未指定本体， 其下没有子节点， 当前变量“本体”为null")
	return 本体


func _设置边框宽度(新宽度):
	边框宽度 = 新宽度
	add_theme_constant_override("margin_bottom", 新宽度)
	add_theme_constant_override("margin_top", 新宽度)
	add_theme_constant_override("margin_left", 新宽度)
	add_theme_constant_override("margin_right", 新宽度)


func _进行调整(方向: String, 相对运动: Vector2):
	if not 正在_调整:
		return
	var 新尺寸 := size
	var 新位置 := global_position
	# 当进行某一方向的拖动后，再朝相反方向拖动，可能偶然超越边界导致无法检测
	# 反转最近方向可得到当前的方向
	if 方向.is_empty():
		方向 = _最近方向
	# 若不允许垂直调整，则直接返回，不进行垂直方向的调整
	if not 允许垂直调整 and (方向 == "上" or 方向 == "下" or 方向.contains("上") or 方向.contains("下")):
		return 

	match 方向:
		"上":
			新尺寸.y -= 相对运动.y
			新位置.y += 相对运动.y
		"下":
			新尺寸.y += 相对运动.y
		"左":
			新尺寸.x -= 相对运动.x
			新位置.x += 相对运动.x
		"右":
			新尺寸.x += 相对运动.x
		"左上":
			新尺寸 -= 相对运动
			新位置 += 相对运动
		"右上":
			新尺寸.x += 相对运动.x
			新尺寸.y -= 相对运动.y
			新位置.y += 相对运动.y
		"左下":
			新尺寸.x -= 相对运动.x
			新尺寸.y += 相对运动.y
			新位置.x += 相对运动.x
		"右下":
			新尺寸 += 相对运动

	size = 新尺寸
	global_position = 新位置
	emit_signal("调整")


func _获取鼠标方向(事件: InputEvent):
	if not 允许调整:
		return

	var 鼠标 = 本体.get_local_mouse_position()
	var 容器尺寸 = 本体.size
	var 方向:String = ""
	# 设置光标
	if (鼠标.x >= 容器尺寸.x and 鼠标.y >= 容器尺寸.y) or (鼠标.x <= 0 and 鼠标.y <= 0):
		if 鼠标.x >= 容器尺寸.x and 鼠标.y >= 容器尺寸.y:
			方向 = "右下"
		else:
			方向 = "左上"
		mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	elif (鼠标.x >= 容器尺寸.x and 鼠标.y <= 0) or (鼠标.x<= 0 and 鼠标.y >= 容器尺寸.y):
		if 鼠标.x >= 容器尺寸.x and 鼠标.y <= 0:
			方向 = "右上"
		else:
			方向 = "左下"
		mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
	elif (鼠标.x >= 容器尺寸.x) or 鼠标.x <= 0:
		if 鼠标.x >= 容器尺寸.x:
			方向 = "右"
		else:
			方向 = "左"
		mouse_default_cursor_shape = Control.CURSOR_HSIZE
	elif (鼠标.y >= 容器尺寸.y) or 鼠标.y <= 0:
		if 鼠标.y <= 0:
			方向 = "上"
		else:
			方向 = "下"
		mouse_default_cursor_shape = Control.CURSOR_VSIZE

	if 事件 is InputEventMouseButton:
		if 事件.button_index == MOUSE_BUTTON_LEFT and 事件.pressed:
			_最近方向 = 方向 # 鼠标按下时获取最近方向
			正在_调整 = true
		elif 事件.button_index == MOUSE_BUTTON_LEFT and not 事件.pressed:
			正在_调整 = false
			正在_拖动 = false

	# 鼠标拖动时传入方向与鼠标移动数据，进行尺寸设置
	elif 事件 is InputEventMouseMotion and 事件.button_mask & MOUSE_BUTTON_LEFT:
		_进行调整(方向, 事件.relative)
		
	else:
		正在_调整 = false


func _进行拖动(事件: InputEvent):
	if not 允许拖动:
		本体.mouse_default_cursor_shape = Control.CURSOR_ARROW
		正在_拖动 = false
		return
	if 正在_调整:
		正在_拖动 = false
		本体.mouse_default_cursor_shape = Control.CURSOR_ARROW
		return

	if 事件 is InputEventMouseButton:
		if 事件.button_index == MOUSE_BUTTON_LEFT and 事件.pressed:
			_拖动量 = 本体.global_position - 本体.get_global_mouse_position()
			正在_拖动 = true
			本体.mouse_default_cursor_shape = Control.CURSOR_DRAG
		elif 事件.button_index == MOUSE_BUTTON_LEFT and not 事件.pressed:
			正在_拖动 = false
			本体.mouse_default_cursor_shape = Control.CURSOR_ARROW

	elif 事件 is InputEventMouseMotion and 正在_拖动:
		global_position = get_global_mouse_position() + _拖动量
		emit_signal("拖动")



func _许可调整(允许: bool):
	允许调整 = 允许
	if not 允许:
		mouse_default_cursor_shape = Control.CURSOR_ARROW

