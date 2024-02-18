@tool
extends HBoxContainer
class_name 接口

static var 当前鼠标所在接口: 接口 ## 检测当前鼠标所在的接口，若当前鼠标不在任何接口，则为null。

const 连接线曲率: float = 100 ## 若使用贝塞尔曲线绘制连接线，控制连接线的曲率，数值越大，曲线越明显。

const 连接线段数: int = 42 ## 若使用贝塞尔曲线绘制连接线，控制连接线的段数，段数越多，曲线越平滑。

@export_subgroup("属性配置")
@export var 接口名称: String = "接口":
	set = _设置接口名称

@export_enum("发送模式", "接收模式") var 接口模式: String = "发送模式": ## 该接口用于发送多个连接，还是接收单个连接。
	set = _设置接口模式

@export var 所属节点: 节点 ## 该接口所属的节点。

## 仅接收者可以拥有配置文件。
## 若接收者未指定配置文件，则当发送者调用[method 连接配置.连接判断]时，直接得到true，也就是允许建立连接。[br]
## 该变量的配置方法: [br]
## 1、创建一个继承自“连接配置”类的命名派生类。[br]
## 2、添加子节点，选择“连接配置”的派生类，点击添加，即可得到一个该类的Node形式的实例。[br]
## 3、将创建的Node拖动到接口检查器的该变量处。[br]
## 注意，每个连接配置节点仅可挂载在一个接口上。
@export var 配置文件: 连接配置:
	set = _设置配置文件

@export var 允许连接同一节点接口: bool = false ## 若为true，则该接口可以连接至自身所属节点的接口，这可能会导致循环。


@export_subgroup("接口UI绘制")
@export var 使用直线绘制连接线: bool = false ##　使用贝塞尔曲线还是直线来绘制连接线。

@export_color_no_alpha var 接点颜色: Color = Color.WHITE:
	set = _设置接点颜色

@export var 连接线颜色: Color = Color.GRAY ## 仅发送者可绘制连接线。

@export var 连接线宽: float = 4 ## 仅发送者可绘制连接线。


@onready var _名称: Label = $"名称"
@onready var _接点: Button = $"接点"
@onready var _绘画: Control = $"接点/_绘画"
@onready var _渐变背景: StyleBoxFlat = $"名称/渐变背景".get_theme_stylebox("panel", "Panel")

var 连接中: bool = false ## 仅发送者可尝试连接。

var 代理: 连接代理 = 连接代理.new(self) ## 用于管理接口连接功能。


func _ready():
	_设置接口名称(接口名称)
	_设置接口模式(接口模式)
	_设置接点颜色(接点颜色)
	_接点.pressed.connect(_开始连接)
	if 接口模式 == "发送模式":
		_绘画.draw.connect(_绘制连接线)


func _process(delta: float) -> void:
	if 接口模式 != "接收模式":
		return
	if not 配置文件:
		return
	if 代理.发送者 == null:
		return
	配置文件.连接时不断执行(delta)


func _input(事件: InputEvent) -> void:
	_绘画.queue_redraw()
	_检测鼠标是否在当前接口()
	if not 连接中:
		return

	if 事件 is InputEventMouseButton:
		if 事件.button_index != MOUSE_BUTTON_LEFT:
			return
		连接中 = false
		_绘画.queue_redraw()

		if not 事件.pressed:
			if _检测连接():
				代理.连接到(当前鼠标所在接口.代理, false)
				if 当前鼠标所在接口.配置文件:
					当前鼠标所在接口.配置文件.在连接成功时执行()


func _检测鼠标是否在当前接口() -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		当前鼠标所在接口 = self 
	elif 当前鼠标所在接口 == self:
		当前鼠标所在接口 = null


func _设置接口名称(新名称: String):
	接口名称 = 新名称
	if _名称 == null:
		return
	_名称.text = 接口名称


func _设置接口模式(新模式: String): # 设置接口模式，根据接口模式调整接点位置和对齐方式
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


func _设置配置文件(新配置: 连接配置):
	配置文件 = 新配置
	if not 新配置:
		return
	新配置.所属接口 = self


func _开始连接():
	if 接口模式 == "接收模式":
		return
	连接中 = true


func _检测连接() -> bool:
	if not 当前鼠标所在接口:
		return false
	if 当前鼠标所在接口 == self:
		return false
	if not 允许连接同一节点接口:
		var 目标接口节点 = 当前鼠标所在接口.所属节点
		if 目标接口节点 and 目标接口节点 == 所属节点:
			return false
	if 当前鼠标所在接口.接口模式 != "接收模式":
		return false
	if not 当前鼠标所在接口.配置文件:
		return true
	return 当前鼠标所在接口.配置文件.连接判断(self)


func _绘制连接线():
	if 连接中:
		if 使用直线绘制连接线:
			_绘画.draw_line(_绘画.get_rect().get_center(), _绘画.get_local_mouse_position(), 连接线颜色, 连接线宽, true)
		else:
			绘制贝塞尔曲线(_绘画, _绘画.get_rect().get_center(), _绘画.get_local_mouse_position(), 连接线曲率 , 连接线段数)
			
	for 已有接收者: 连接代理 in 代理.获取_接收者():
		var 接收者相对绘画的位置 = 已有接收者.所属接口._绘画.get_global_rect().get_center() - _绘画.global_position
		if 使用直线绘制连接线:
			_绘画.draw_line(_绘画.get_rect().get_center(), 接收者相对绘画的位置, 连接线颜色, 连接线宽, true)
		else:
			绘制贝塞尔曲线(_绘画, _绘画.get_rect().get_center(), 接收者相对绘画的位置, 连接线曲率, 连接线段数)


func 绘制贝塞尔曲线(绘制者: Control, 起始点: Vector2, 结束点: Vector2, 曲率: float, 段数: int):
	var 各点:PackedVector2Array = []
	var 控制点A = 起始点 + Vector2(曲率, 0)
	var 控制点B = 结束点 - Vector2(曲率, 0)

	for i in range(段数 + 1):
		var 点所在 = i / float(段数)

		var 点 = 贝塞尔插值(起始点, 控制点A, 控制点B, 结束点, 点所在)
		各点.append(点)

	# 绘制曲线
	绘制者.draw_polyline(各点, 连接线颜色, 连接线宽, true)


func 贝塞尔插值(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u = 1.0 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t
	return uuu * p0 + 3 * uu * t * p1 + 3 * u * tt * p2 + ttt * p3

