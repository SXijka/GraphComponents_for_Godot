class_name 区域
extends Control
## Control版Collider，用于实现Control元素的碰撞、响应与移出等。

## 若某控件处于区域内，对其运用移出，则会最多移动[param 移出尝试次数] * [param 弹出精度]个像素。
const 移出尝试次数: int = 1000

##若该类某函数的返回值与[param 不存在]相同，则说明未能成功获取。
const 不存在: Rect2 = Rect2(-1,-1,-1,-1)

## 该区域的识别名称。
@export var 名称: StringName = "区域":
	set = _当_改名

# 键为区域名称[String]，值为区域字典[Dictionary]；区域字典的键为区域实例哈希值[int]，值为区域矩形[Rect2]。
static var _区域: Dictionary = {}

var _哈希值: int = hash(self)


func _enter_tree() -> void:
	add_to_group("区域")
	_当_添加()


func _ready() -> void:
	connect("item_rect_changed", _当_移动)


func _input(_event: InputEvent) -> void:
	_当_移动()


func _exit_tree() -> void:
	_当_删除()


## 检测[param 控件矩形]是否相交于指定的区域。
static func 相交于(控件矩形: Rect2,区域名称: StringName) -> bool:
	if not _区域.has(区域名称):
		return false
	for 区:Rect2 in _区域[区域名称].values():
		if 区.intersects(控件矩形):
			return true
	return false


## 获取第一个与[param 控件矩形]相交的名称为[param 区域名称]的区域。
## 若无相交，返回[@区域.不存在]。[br]
## 与[method 相交于]搭配使用。
static func 获取_相交区域(控件矩形: Rect2, 区域名称: StringName) -> Rect2:
	if not _区域.has(区域名称):
		return 不存在
	for 区:Rect2 in _区域[区域名称].values():
		if 区.intersects(控件矩形):
			return 区
	return 不存在


## 在指定区域中存在[param 点]。
static func 存在点于(点: Vector2, 区域名称: StringName) -> bool:
	if not _区域.has(区域名称):
		return false
	for 区:Rect2 in _区域[区域名称].values():
		if 区.has_point(点):
			return true
	return false


## 将控件移出拥有指定名称的控件。
## [param 弹出精度]单位为像素，该参数[color=yellow]并不影响检测[/color]，
## 而是影响移出控件时的“作用力”效果和对性能开销的容忍度。[br]
## [param 弹出精度]数值越大，反弹效果越强，而若[param 弹出精度]过小，则可能难以完全移出控件或造成较大性能开销。
static func 移出(控件: Control, 区域名称: StringName, 弹出精度: float = 1.0) -> void:
	if not _区域.has(区域名称):
		return

	for i in range(移出尝试次数):
		var 相交 := false
		for 区: Rect2 in _区域[区域名称].values():
			var 控件矩形 = 控件.get_global_rect()
			if not 区.intersects(控件矩形):
				continue
			var 区中心 = 区.get_center()
			var 控件中心 = 控件矩形.get_center()
			var 全局方向 = (控件中心 - 区中心).normalized()
			控件.global_position += 全局方向 * 弹出精度
			相交 = true
			break
		if not 相交:
			break
	return


## [method 移出]的扩展方法，可以单独传入[param 控件矩形]用于检测，若时间大于0.0，则给予移出行为一个相应时长的动画。若[param 全局]为假，则使用控件局部坐标进行移出。
static func 移出_扩展(控件: Control, 区域名称: StringName, 控件矩形: Rect2, 弹出精度: float = 1.0, 时间: float = 0.0, 全局: bool = true) -> void:
	if not _区域.has(区域名称):
		return

	var 偏移量 := Vector2.ZERO

	for i in range(移出尝试次数):
		var 相交 := false

		for 区: Rect2 in _区域[区域名称].values():
			if not 区.intersects(控件矩形):
				continue

			var 区中心 = 区.get_center()
			var 控件中心 = 控件矩形.get_center()
			var 全局方向: Vector2
			if (控件中心 - 区中心).is_zero_approx(): # 防止控件矩形中点与区域中点重合时方向为零值造成不移动。
				全局方向 = Vector2.DOWN
			else:
				全局方向 = (控件中心 - 区中心).normalized()
			控件矩形.position += 全局方向 * 弹出精度
			偏移量 += 全局方向 * 弹出精度
			相交 = true
			break

		if not 相交:
			break

		if 时间 <= 0.0:
			if 全局:
				控件.global_position += 偏移量
			else:
				控件.position += 偏移量
		else:
			var 平滑移出动画 := 控件.create_tween()
			平滑移出动画.set_trans(Tween.TRANS_CUBIC)
			平滑移出动画.set_ease(Tween.EASE_OUT)
			if 全局:
				平滑移出动画.tween_property(控件, "global_position", 控件.global_position + 偏移量, 时间)
			else:
				平滑移出动画.tween_property(控件, "position", 控件.position + 偏移量, 时间)
	return


## 获取拥有该名称的全部区域的矩形，若无该名称的区域则返回[code][][/code]。
static func 获取矩形(区域名称: StringName) -> Array[Rect2]:
	var 区域矩形: Array[Rect2] = []
	if not _区域.has(区域名称):
		return 区域矩形
	if (_区域[区域名称] as Dictionary).is_empty():
		return 区域矩形
	for r:Rect2 in _区域[区域名称].values():
		区域矩形.append(r)
	return 区域矩形


## 随机返回一个该区域的矩形，若无该名称的区域，返回[code]不存在[/code]。[br]
static func 获取任一矩形(区域名称: StringName) -> Rect2:
	if not _区域.has(区域名称):
		return 不存在
	if _区域[区域名称].is_empty():
		return 不存在
	return _区域[区域名称].values().pick_random()


func _当_移动():
	_区域[名称][_哈希值] = get_global_rect()


func _当_添加():
	if not _区域.has(名称):
		_区域[名称] = {}
	_区域[名称][_哈希值] = get_global_rect()


func _当_删除():
	if _区域[名称].has(_哈希值):
		_区域[名称].erase(_哈希值)


func _当_改名(新名称: StringName):
	if _区域.has(名称):
		_当_删除()
	名称 = 新名称
	_当_添加()
