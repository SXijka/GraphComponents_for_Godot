@tool
extends HBoxContainer
class_name 接口

# 定义属性
@export var 接口名称: String = "接口":
	set = _设置接口名称

@export_enum("发送模式", "接收模式") var 接口模式: String = "发送模式": # 默认为发送模式
	set = _设置接口模式
	
@export_color_no_alpha var 接点颜色: Color = Color.WHITE:
	set = _设置接点颜色

@export var 连接线颜色: Color = Color.GRAY

@export var 连接线宽: float = 8.0

@export var 连接: 连接代理


@onready var _名称: Label = $"名称"
@onready var _接点: Button = $"接点"
@onready var _绘画: Control = $"接点/绘画"

@onready var _渐变背景: StyleBoxFlat = $"名称/渐变背景".get_theme_stylebox("panel", "Panel")

var 连接中: bool = false

var _连接初始位置: Vector2 = Vector2.ZERO




func _ready():
	_设置接口名称(接口名称)
	_设置接口模式(接口模式)
	_设置接点颜色(接点颜色)
	_接点.pressed.connect(_开始连接)
	_绘画.draw.connect(_绘制连接线)


func _设置接口名称(新名称: String):
	接口名称 = 新名称
	if _名称 == null:
		return
	_名称.text = 接口名称


# 设置接口模式，根据接口模式调整接点位置和对齐方式
func _设置接口模式(新模式: String):
	接口模式 = 新模式
	# 在变量初始化时会调用一次，此时子节点尚未加载因此需要return。
	if (_名称 == null) or (_接点 == null):
		return

	# 更新接点位置
	var 接点位置 = "左侧" if 接口模式 == "接收模式" else "右侧"
	if 接点位置 == "左侧":
		move_child(_接点, 0)
		_名称.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_接点.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_渐变背景.border_width_right = 30
		_渐变背景.border_width_left = 0
	else:
		move_child(_接点, 1)
		_名称.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_接点.size_flags_horizontal = Control.SIZE_SHRINK_END
		_渐变背景.border_width_left = 30
		_渐变背景.border_width_right = 0


func _设置接点颜色(新颜色: Color):
	接点颜色 = 新颜色
	if _接点 == null:
		return
	_接点.self_modulate = 接点颜色
	if _渐变背景 == null:
		return
	_渐变背景.border_color = Color(新颜色, 0.5)


func _开始连接():
	连接中 = true
	print("开始")
	_连接初始位置 = get_global_mouse_position()
	pass

func _input(事件: InputEvent) -> void:
	if not 连接中:
		return
	_绘画.queue_redraw()

	if 事件 is InputEventMouseButton:
		if 事件.button_index != MOUSE_BUTTON_LEFT:
			return
		连接中 = false
		_绘画.queue_redraw()
		检测连接()
		


func 检测连接():
	pass
	
func _绘制连接线():
	if 连接中:
		_绘画.draw_line(计算中点位置(_绘画), _绘画.get_local_mouse_position(), 连接线颜色, 连接线宽, true)

func 计算中点位置(控件: Control) -> Vector2:
	return 控件.position + 控件.size/2
#func _draw() -> void:
	#if not 连接中:
		#return
	#no()
#var 开始点位置: Vector2
#var 结束点位置: Vector2
#var 控制点1位置: Vector2= Vector2(100, 100)
#var 控制点2位置: Vector2= Vector2(200, 200)
#var 使用贝塞尔曲线: bool = true
#var 当前鼠标位置: Vector2
#var 连接中: bool = false
#
##
#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index != MOUSE_BUTTON_LEFT:
			#pass
		#if event.pressed:
			## 开始连接
			#开始点位置 = event.position
			#当前鼠标位置 = event.position
			#连接中 = true
		#else:
			## 结束连接
			#连接中 = false
			#
			#print("连接结束")
		#queue_redraw()
	#elif event is InputEventMouseMotion and 连接中:
		## 更新当前鼠标位置用于绘制连接线
		#当前鼠标位置 = event.position
		#queue_redraw()
#
#func _draw():
	#if 连接中:
		#if 使用贝塞尔曲线:
			## 使用贝塞尔曲线绘制
			#var points = 计算贝塞尔曲线点(开始点位置, 控制点1位置, 控制点2位置, 当前鼠标位置)
			#for i in range(points.size() - 1):
				#draw_line(points[i], points[i + 1], Color(1, 0, 0, 1), 2)
		#else:
			## 使用直线绘制
			#draw_line(开始点位置, 当前鼠标位置, Color(1, 0, 0, 1), 2)
#
#func 计算贝塞尔曲线点(开始点: Vector2, 控制点1: Vector2, 控制点2: Vector2, 结束点: Vector2, 分割数: int = 20) -> Array[Vector2]:
	#var points: Array[Vector2] = []
	#for i in range(分割数 + 1):
		#var t = i / float(分割数)
		#var point = 计算贝塞尔曲线上的点(t, 开始点, 控制点1, 控制点2, 结束点)
		#points.append(point)
	#return points
#
#func 计算贝塞尔曲线上的点(t: float, 开始点: Vector2, 控制点1: Vector2, 控制点2: Vector2, 结束点: Vector2) -> Vector2:
	#return (1 - t) ** 3 * 开始点 + 3 * (1 - t) ** 2 * t * 控制点1 + 3 * (1 - t) * t ** 2 * 控制点2 + t ** 3 * 结束点
#
#func 更新曲线(新开始点位置: Vector2, 新结束点位置: Vector2, 新控制点1位置: Vector2, 新控制点2位置: Vector2, 使用贝塞尔: bool):
	#开始点位置 = 新开始点位置
	#结束点位置 = 新结束点位置
	#控制点1位置 = 新控制点1位置
	#控制点2位置 = 新控制点2位置
	#使用贝塞尔曲线 = 使用贝塞尔
	#queue_redraw()  # 触发重新绘制
#

# 占位函数，以后根据需要实现
func 在连接时执行():
	pass

func 连接中执行():
	pass

func 断开时执行():
	pass
