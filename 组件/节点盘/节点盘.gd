class_name 节点盘
extends Control
## 按[kbd]Q[/kbd]以将视角移至众节点的中心，按住[kbd]Ctrl[/kbd]并划动[kbd]滚轮[/kbd]以缩放界面。


const 至众节点时间: float = 1.0

var 至众节点动画: Tween

var _上一个位置:Vector2

@onready var 背景盘: Panel = $"可调整边框/背景盘"
@onready var 盘边缘: ReferenceRect = $"可调整边框/背景盘/盘边距/盘边缘"
@onready var 边框: 可调整边框 = $"可调整边框"


func _ready() -> void:
	_上一个位置 = 边框.global_position


func _input(事件: InputEvent) -> void:
	if _边缘超出():
		边框.global_position = _上一个位置
	else:
		_上一个位置 = 边框.global_position
		
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
	边框.允许拖动 = false
	if 至众节点动画:
		至众节点动画.kill()
	至众节点动画 = create_tween()
	至众节点动画.set_trans(Tween.TRANS_CUBIC)
	至众节点动画.tween_property(边框, "global_position", 边框.global_position + _全局中心() - _计算中间(节点集合), 至众节点时间)
	至众节点动画.tween_callback(func(): 边框.允许拖动 = true)


func _计算中间(各位置: Array) -> Vector2:
	var _总和 = Vector2()
	for _位置 in 各位置:
		_总和 += _位置
	return _总和 / 各位置.size()


func _全局中心()-> Vector2:
	return get_global_rect().get_center()

func _边框全局中心()-> Vector2:
	return 边框.get_global_rect().get_center()

func _边缘超出() -> bool:
	return !盘边缘.get_global_rect().encloses(get_global_rect())
