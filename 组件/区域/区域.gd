class_name 区域
extends Control
## Control版Collider，用于实现Control元素的碰撞、响应与移出。

## 若某控件处于区域内，对其运用移出，则会最多移动[param 移出尝试次数] * [param 弹出精度]个像素。
const 移出尝试次数: int = 1000

## 该区域的识别名称。
@export var 名称: StringName = "区域"

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


## [method 移出]的扩展方法，可以单独传入[param 控件矩形]用于检测，若时间大于0.0，则给予移出行为一个相应时长的动画。
static func 移出_扩展(控件: Control, 区域名称: StringName, 控件矩形: Rect2, 弹出精度: float = 1.0, 时间: float = 0.0) -> void:
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
			var 全局方向 = (控件中心 - 区中心).normalized()
			控件矩形.position += 全局方向 * 弹出精度
			偏移量 += 全局方向 * 弹出精度
			相交 = true
			break

		if not 相交:
			break

		if 时间 <= 0.0:
			控件.global_position += 偏移量
		else:
			var 平滑移出动画 := 控件.create_tween()
			平滑移出动画.set_trans(Tween.TRANS_CUBIC)
			平滑移出动画.set_ease(Tween.EASE_OUT)
			平滑移出动画.tween_property(控件, "global_position", 控件.global_position + 偏移量, 时间)
	return


func _当_移动():
	_区域[名称][_哈希值] = get_global_rect()


func _当_添加():
	if not _区域.has(名称):
		_区域[名称] = {}
	_区域[名称][_哈希值] = get_global_rect()


func _当_删除():
	if _区域[名称].has(_哈希值):
		_区域[名称].erase(_哈希值)

