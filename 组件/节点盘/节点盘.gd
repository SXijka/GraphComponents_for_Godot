class_name 节点盘
extends Control
## 按[kbd]Q[/kbd]以将视角移至众节点的中心，按住[kbd]Ctrl[/kbd]并划动[kbd]滚轮[/kbd]以缩放界面。

const 至众节点时间: float = 1.0


@export var 自动获取子节点为内容: bool = true

var _至众节点动画: Tween

var _上一个位置:Vector2

@onready var _盘边缘: ReferenceRect = $"可调整边框/背景盘/盘边距/盘边缘"
@onready var _边框: 可调整边框 = $"可调整边框"
@onready var _盘面: Control = $"可调整边框/背景盘/盘边距/盘边缘/盘面"


func _ready() -> void:
	_上一个位置 = _边框.global_position
	if 自动获取子节点为内容:
		添加_多个控件.call_deferred(_获取实例子节点())


func _input(事件: InputEvent) -> void:
	if _边缘超出():
		_边框.global_position = _上一个位置
	else:
		_上一个位置 = _边框.global_position
		
	if 事件.is_action_pressed("视角移至众节点中心"):
		视角移至众节点中心()



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
