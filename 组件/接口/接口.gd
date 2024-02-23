@tool
extends HBoxContainer
class_name 接口
## 用于[节点]之间图形化的关联与交互，分为[code]接收模式[/code]与[code]发送模式[/code]，两者可以相互连接。[br]
## 接口的连接、断开等功能，由[连接代理]承担。
## 当作为[code]发送接口[/code]时，在接点处[kbd]按住[/kbd]并[kbd]拖动[/kbd]连接线至接收接口可尝试连接。[br]
## 当作为[code]接收接口[/code]时，[kbd]左键[/kbd]是切换连接线隐蔽状态，[kbd]中键[/kbd]是切换直曲线，[kbd]右键[/kbd]是尝试断开。

static var 当前鼠标所在接口: 接口 ## 检测当前鼠标所在的接口，若当前鼠标不在任何接口，则为[code]null[/code]。
static var 连接线抗锯齿: bool = true ## 连接线是否抗锯齿。

const 连接线曲率: float = 100 ## 若使用贝塞尔曲线绘制连接线，控制连接线的曲率，数值越大，曲线越明显。
const 连接线段数: int = 42 ## 若使用贝塞尔曲线绘制连接线，控制连接线的段数，段数越多，曲线越平滑。
const 隐蔽连接线暗度: float = 0.5 ## 若对连接线实行隐蔽，则其较正常连接线颜色的暗度。

@export_subgroup("通用属性")
@export var 接口名称: String = "接口": ## 更改该名称会同步对应到UI的名称显示上。
	set = _设置接口名称

@export var 所属节点: Control ## 该接口所属的[节点]，由于当前版本无法指定派生类，请仅指定为[节点]。

@export_enum("发送模式", "接收模式") var 接口模式: String = "发送模式": ## 该接口用于发送多个连接，还是接收单个连接。
	set = _设置接口模式

@export_color_no_alpha var 接点颜色: Color = Color.WHITE: ## 接点和接口名称下方渐变背景的颜色。
	set = _设置接点颜色

@export_subgroup("接收模式属性")
## 仅接收者可以拥有配置文件。
## 若接收者未指定配置文件，则当发送者调用[method 连接配置.连接判断]时，直接得到[code]true[/code]，也就是允许建立连接。[br]
## 该变量的配置方法: [br]
## 1、创建一个继承自[连接配置]的命名派生类。[br]
## 2、添加子节点，选择[连接配置]的派生类，点击添加，即可得到一个该类的[Node]形式的实例。[br]
## 3、将创建的[Node]拖动到[接口]检查器的该变量处。[br]
## 注意，每个连接配置节点实例仅可挂载在一个接口上。
@export var 配置文件: 连接配置:
	set = _设置配置文件

@export var 允许断开: bool = true ## 是否允许接收者断开。仅接收模式有效。

@export var 将自动连接至: Array[接口] = [] ## 在游戏开始时该接口会自动连接至的接口。

@export_subgroup("发送模式属性")
@export var 允许连接同一节点接口: bool = false ## 若为[code]true[/code]，则该接口可以连接至自身所属节点的接口，这可能会导致循环。仅发送模式有效。

@export var 替代断开: bool = true ## 当尝试连接至某一已有发送者的接收接口时，若允许断开，是维持原发送者还是将发送者替换为该接口。仅发送模式有效。

@export var 使用直线绘制连接线: bool = false ## 使用贝塞尔曲线还是直线来绘制连接线。

@export var 虚直线: bool = false ## 如果使用直线作为连接线，则以虚线的方式来绘制。

@export var 连接线颜色: Color = Color.GRAY ## 仅发送者可绘制连接线。

@export var 连接线宽: float = 4 ## 仅发送者可绘制连接线。

@export var 隐蔽已有连接线: bool = false ## 若为[code]false[/code]，除尝试连接时外，隐藏该节点的所有连接线。


@onready var _名称: Label = $"名称"
@onready var _接点: Button = $"接点"
@onready var _绘画: Control = $"接点/绘画"
@onready var _渐变背景: StyleBoxFlat = $"名称/渐变背景".get_theme_stylebox("panel", "Panel")


var 连接中: bool = false ## 是否正尝试连接，此间绘制接点至鼠标的连接线。仅发送者可尝试连接。

var 代理: 连接代理 = 连接代理.new(self) ## 用于管理接口连接功能。


func _init() -> void:
	add_to_group("接口")


func _ready():
	_设置接口名称(接口名称)
	_设置接口模式(接口模式)
	_设置接点颜色(接点颜色)

	if 所属节点:
		所属节点.大小变化.connect(func():_绘画.queue_redraw())
	_接点.pressed.connect(_当接点按下)

	if 接口模式 == "发送模式":
		_绘画.draw.connect(_绘制连接线)
		_接点.gui_input.connect(func(事件:InputEvent):
			if not 事件 is InputEventMouseButton:
				return
			if 事件.pressed:
				return
			if 事件.button_index == MOUSE_BUTTON_MIDDLE:
				使用直线绘制连接线 = !使用直线绘制连接线
			if 事件.button_index == MOUSE_BUTTON_MASK_RIGHT:
				隐蔽已有连接线 = !隐蔽已有连接线)

		for i:接口 in 将自动连接至:
			if i == null:
				continue
			if i.接口模式 == "接收模式":
				代理.连接到(i.代理, false)

	elif 接口模式 == "接收模式":
		_接点.button_mask = MOUSE_BUTTON_MASK_RIGHT
		_接点.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE


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


## 更改该接口背景工具提示文本。
func 背景提示(提示: String) -> void:
	_渐变背景.tooltip_text = 提示


## 更改该接口接点工具提示文本。
func 接点提示(提示: String) -> void:
	_接点.tooltip_text = 提示


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


func _当接点按下():
	if 接口模式 == "接收模式":
		if not 允许断开:
			return
		if 代理 and 代理.发送者:
			代理.断开于(代理.发送者)
			if 配置文件:
				配置文件.断开时执行一次()
		return
	if 接口模式 == "发送模式":
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

	if (当前鼠标所在接口.代理.发送者 != 代理.默认发送者) or 当前鼠标所在接口.代理.发送者 != null:
		if not 当前鼠标所在接口.允许断开:
			return false
		if not 替代断开:
			return false
		if (not 当前鼠标所在接口.配置文件) or 当前鼠标所在接口.配置文件.连接判断(self):
			当前鼠标所在接口.代理.断开于(当前鼠标所在接口.代理.发送者)
			if 当前鼠标所在接口.配置文件:
				当前鼠标所在接口.配置文件.断开时执行一次()
			return true
		return false

	if not 当前鼠标所在接口.配置文件:
		return true
	return 当前鼠标所在接口.配置文件.连接判断(self)


func _绘制连接线():
	if 连接中:
		if 使用直线绘制连接线:
			if 虚直线:
				_绘画.draw_dashed_line(_绘画.get_rect().get_center(), _绘画.get_local_mouse_position(), 连接线颜色, 连接线宽, 3 * 连接线宽, 连接线抗锯齿)
				_绘画.draw_circle(_绘画.get_rect().get_center(), 连接线宽/2, 连接线颜色)
				_绘画.draw_circle(_绘画.get_local_mouse_position(), 连接线宽/2, 连接线颜色)
			else:
				_绘画.draw_line(_绘画.get_rect().get_center(), _绘画.get_local_mouse_position(), 连接线颜色, 连接线宽, 连接线抗锯齿)
				_绘画.draw_circle(_绘画.get_rect().get_center(), 连接线宽/2, 连接线颜色)
				_绘画.draw_circle(_绘画.get_local_mouse_position(), 连接线宽/2, 连接线颜色)
		else:
			_绘制贝塞尔曲线(_绘画, _绘画.get_rect().get_center(), _绘画.get_local_mouse_position(), 连接线曲率 , 连接线段数, 连接线颜色)
			_绘画.draw_circle(_绘画.get_rect().get_center(), 连接线宽/2, 连接线颜色)
			_绘画.draw_circle(_绘画.get_local_mouse_position(), 连接线宽/2, 连接线颜色)
	
	var 已有连接线颜色 = 连接线颜色
	if 隐蔽已有连接线:
		已有连接线颜色 = 连接线颜色.darkened(隐蔽连接线暗度)
		已有连接线颜色.a = 0.5
	for 已有接收者: 连接代理 in 代理.获取_接收者():
		var 接收者相对绘画的位置 = 已有接收者.所属接口._绘画.get_global_rect().get_center() - _绘画.global_position
		if 使用直线绘制连接线:
			if 虚直线:
				_绘画.draw_dashed_line(_绘画.get_rect().get_center(), 接收者相对绘画的位置, 已有连接线颜色, 连接线宽, 3 * 连接线宽, 连接线抗锯齿)
				_绘画.draw_circle(_绘画.get_rect().get_center(), 连接线宽/2, 已有连接线颜色)
				_绘画.draw_circle(接收者相对绘画的位置, 连接线宽/2, 已有连接线颜色)
			else:
				_绘画.draw_line(_绘画.get_rect().get_center(), 接收者相对绘画的位置, 已有连接线颜色, 连接线宽, 连接线抗锯齿)
				_绘画.draw_circle(_绘画.get_rect().get_center(), 连接线宽/2, 已有连接线颜色)
				_绘画.draw_circle(接收者相对绘画的位置, 连接线宽/2, 已有连接线颜色)
		else:
			_绘制贝塞尔曲线(_绘画, _绘画.get_rect().get_center(), 接收者相对绘画的位置, 连接线曲率, 连接线段数, 已有连接线颜色)
			_绘画.draw_circle(_绘画.get_rect().get_center(), 连接线宽/2, 已有连接线颜色)
			_绘画.draw_circle(接收者相对绘画的位置, 连接线宽/2, 已有连接线颜色)


func _绘制贝塞尔曲线(绘制者: Control, 起始点: Vector2, 结束点: Vector2, 曲率: float, 段数: int, 颜色: Color):
	var 各点:PackedVector2Array = []
	var 控制点A = 起始点 + Vector2(曲率, 0)
	var 控制点B = 结束点 - Vector2(曲率, 0)

	for i in range(段数 + 1):
		var 点所在 = i / float(段数)

		var 点 = _贝塞尔插值(起始点, 控制点A, 控制点B, 结束点, 点所在)
		各点.append(点)

	# 绘制曲线
	绘制者.draw_polyline(各点, 颜色, 连接线宽, 连接线抗锯齿)


func _贝塞尔插值(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u = 1.0 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t
	return uuu * p0 + 3 * uu * t * p1 + 3 * u * tt * p2 + ttt * p3

