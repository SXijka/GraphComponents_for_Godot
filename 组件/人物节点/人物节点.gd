@tool
class_name 人物节点
extends 节点
## 代表可移动的人或物的[节点]。[br]
## 被名称为“禁区”的[区域]禁止进入的[节点]。[br]
## 可被限制在名称为“活动区”的[区域]的[节点]。[br]
## 可在进入[code]自定义的区域[/code]时执行[param 自定义响应脚本]中指定的[code]响应方法[/code]。[br]

@export_subgroup("区域设置")
@export var 禁区模式: bool = true:
	set = _设置禁区模式

@export var 禁区名称: StringName = "禁区"

@export var 活动区模式: bool = false:
	set = _设置活动区模式

@export var 活动区名称: StringName = "活动区"

@export var 自定义区域名称: StringName = ""

@export_file(".gd") var 自定义响应脚本: String: ## 若不为空，该脚本中必须有名称为[param 响应方法名]的方法。
	set = _设置自定义响应脚本

## [param 自定义响应脚本]中调用的方法的名称，若[param 自定义响应脚本]为空则无效。方法需要有一个代表响应的节点的形参。
@export var 响应方法名:String


@export_subgroup("禁区弹出")
@export var 碰撞弹出时间: float = 0.2

@export var 碰撞弹出距离: float = 10.0

@export var 自内部弹出时间: float = 1.0

@export var 自内部弹出距离: float = 40.0


var _正在移出: bool = false

var _上一个中心: Vector2

var 响应实例


func _init() -> void:
	super._init()
	add_to_group("人物节点")


func _ready() -> void:
	super._ready()

	_上一个中心 = _获取节点全局中心位置()

	if 禁区模式:
		if not _边框.拖动.is_connected(_被禁区弹出):
			_边框.拖动.connect(_被禁区弹出)
		_被禁区弹出()
	if 活动区模式:
		if not _边框.拖动.is_connected(_被活动区束缚):
			_边框.拖动.connect(_被活动区束缚)
		_被活动区束缚()


func _被禁区弹出() -> void:
	if _正在移出:
		return

	if 区域.相交于(节点全局矩形, 禁区名称):
		if 区域.存在点于(节点全局中心位置, 禁区名称):
			# 自内部弹出
			_正在移出 = true
			允许拖动 = false
			区域.移出_扩展(self, 禁区名称, 节点全局矩形, 自内部弹出距离, 自内部弹出时间, false)
			await get_tree().create_timer(自内部弹出时间).timeout
			允许拖动 = true
			_正在移出 = false

		else:
			# 碰撞弹出
			_正在移出 = true
			允许拖动 = false
			区域.移出_扩展(self, 禁区名称, 节点全局矩形, 碰撞弹出距离, 碰撞弹出时间, false)
			await get_tree().create_timer(碰撞弹出时间).timeout
			允许拖动 = true
			_正在移出 = false


func _被活动区束缚() -> void:
	if 区域.存在点于(节点全局中心位置, 活动区名称):
		_上一个中心 = 节点全局中心位置
		return
	if 区域.存在点于(_上一个中心, 活动区名称):
		节点全局中心位置 = _上一个中心
		return
	if 区域.获取任一矩形(活动区名称) == 区域.不存在:
		return
	节点全局中心位置 = 区域.获取任一矩形(活动区名称).get_center()


func _响应自定义区域() -> void:
	if 自定义区域名称 == null or 自定义区域名称.is_empty():
		return
	if 响应实例 == null:
		return
	if not 响应实例.has_method(响应方法名):
		return
	if 区域.相交于(节点全局矩形, 自定义区域名称):
		响应实例.call(响应方法名, self)


func _设置禁区模式(新模式: bool) -> void:
	禁区模式 = 新模式
	if not _边框:
		return
	if 禁区模式:
		if not _边框.拖动.is_connected(_被禁区弹出):
			_边框.拖动.connect(_被禁区弹出)
	else:
		_边框.拖动.disconnect(_被禁区弹出)


func _设置活动区模式(新模式: bool) -> void:
	活动区模式 = 新模式
	if not _边框:
		return
	if 活动区模式:
		if not _边框.拖动.is_connected(_被活动区束缚):
			_边框.拖动.connect(_被活动区束缚)
	else:
		_边框.拖动.disconnect(_被活动区束缚)


func _设置自定义响应脚本(脚本地址: String) -> void:
	自定义响应脚本 = 脚本地址
	if 脚本地址 and not 脚本地址.is_empty():
		var 实例 = load(脚本地址).new()
		响应实例 = 实例





