@tool
class_name 组件
extends Control
## 一切拥有嵌套或连接功能的组件的基类。
## 可接受一个配置文件，在进入场景树时执行其[method 组件配置.执行配置]。

## 若该配置文件不为空，则自动加载该配置文件，并执行其[method 组件配置.执行配置]。
@export var 配置文件: 组件配置

## 该组件的名称，可被用于UI显示和报错信息。
@export var 名称: String

## 该组件所归属的另一个组件。与宾客的区别是，宾客可以有多个，宿主只能有一个。
@export var 宿主: 组件: 
	set = _设置宿主

## 当该组件作为一个宾客被断开后，会将宿主设置为默认宿主
@export var 默认宿主:组件 = null

var _宾客: Array[组件] = []

signal 宾客改变(宿主: 组件, 是_添加: bool, 宾客: 组件)
signal 宿主改变(自身:组件, 新宿主:组件)
signal 连接(组件_:组件, 接收者:组件, 组件_为宿主:bool)
signal 断开(组件_:组件, 接收者:组件)


## 连接自己的宾客改变、宿主改变、连接、断开信号，以便在接收到信号时能够自动处理。
func _init():
	connect("连接",_接收_连接)
	connect("断开",_接收_断开)
	connect("宾客改变",当宾客改变)
	connect("宿主改变",当宿主改变)


## 若配置文件不为空，则在进入场景树时执行[method 组件配置.执行配置]。
## 无法更早，因为直到对象被实例化并添加到场景树之后，属性才会被设置为编辑器中指定的值，之前则是默认值。
func _enter_tree() -> void:
	if 配置文件:
		配置文件.执行配置(self)


## 当宾客改变时被调用的虚方法
@warning_ignore("unused_parameter")
func 当宾客改变(_自身: 组件, 是_添加: bool, 宾客: 组件) -> void:
	pass


## 当宿主改变时被调用的虚方法
@warning_ignore("unused_parameter")
func 当宿主改变(_自身: 组件, 新宾客: 组件) -> void:
	pass


## 令组件_与该组件连接。
func 连接到(组件_: 组件, 组件_为宿主: bool) -> void:
	emit_signal("连接", 组件_, self, 组件_为宿主)


## 令组件_与该组件断开。
func 断开于(组件_: 组件):
	emit_signal("断开", 组件_, self)


## 获取宾客数组。并非返回引用本身，而是复制。
func 获取_宾客() -> Array[组件]:
	return _宾客.duplicate()


## 获取宾客数量。
func 宾客_数量() -> int:
	return _宾客.size()


## 判断两个组件之间是否存在连接。
## 注意，若存在单向连接，会根据断开单向的值对组件间的连接状态进行纠正，此时返回值与断开单向的值相同。
static func 存在连接(组件A: 组件, 组件B: 组件, 断开单向: bool = true) -> bool:
	if (组件A.宿主 == 组件B) and (组件A in 组件B.获取_宾客()):
		return true
	if (组件B.宿主 == 组件A) and (组件B in 组件A.获取_宾客()):
		return true
	if not 存在单向连接(组件A, 组件B, 断开单向):
		return false
	return 断开单向


## 判断两个组件之间是否存在单向连接。注意，无论返回值如何，都会根据断开单向的值对连接状态进行纠正。
## 在存在单向连接时，若断开连接为true，则会断开单向连接；若断开连接为false，则会补全为正常连接。
static func 存在单向连接(组件A: 组件, 组件B: 组件, 断开单向: bool = true) -> bool:
	if 组件A == 组件B:
		push_warning(组件A._信息() + "  自己诊断与自己是否存在单向连接")
		return false
	if (组件A.宿主 == 组件B) and (组件A not in 组件B.获取_宾客()):
		if 断开单向:
			组件A.宿主 = null
		else:
			组件B._宾客_添加(组件A)
		return true
	elif (组件B.宿主 == 组件A) and (组件B not in 组件A.获取_宾客()):
		if 断开单向:
			组件B.宿主 = null
		else:
			组件A._宾客_添加(组件A)
		return true
	return false


func _接收_连接(组件_: 组件, 目标: 组件, 组件_为宿主: bool) -> void:
	if 组件_ == self:
		push_warning(组件_._信息() + "  自己当自己的宿主")
		return
	if 组件_为宿主:
		# 组件_希望成为宿主，将目标添加为组件_的宾客
		组件_._宾客_添加(目标)
		# 目标的宿主设置为组件_
		宿主 = 组件_
	else:
		# 组件_希望成为宾客，将组件_添加到自身的宾客列表中
		_宾客_添加(组件_)
		# 组件_的宿主设置为自身
		组件_.宿主 = self


func _接收_断开(组件A:组件, 组件B: 组件) -> void:
	if 组件A.宿主 == 组件B:
		组件A._设置宿主(默认宿主)
		组件B._宾客_删除(组件A)
		print(组件B)
	elif 组件B.宿主 == 组件A:
		print(组件A)
		组件B._设置宿主(默认宿主)
		组件A._宾客_删除(组件B)


func _设置宿主(新宿主: 组件) -> void:
	宿主 = 新宿主
	emit_signal("宿主改变", self, 新宿主)


func _宾客_添加(组件_: 组件) -> void:
	if 组件_ in _宾客 :
		return
	_宾客.append(组件_)
	emit_signal("宾客改变", self, true, 组件_)


func _宾客_删除(组件_: 组件) -> void:
	if 组件_ in _宾客:
		_宾客.erase(组件_)
		emit_signal("宾客改变", self, false, 组件_)


func _宾客_清空() -> void:
	for 组件_ in _宾客.duplicate():
		_宾客_删除(组件_)
	_宾客.clear()


func _信息() -> String:
	return str(self) + "  |名称： " + 名称 + "  |宾客： " + str(_宾客) + "  |宿主： " + str(宿主)

