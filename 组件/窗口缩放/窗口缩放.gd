## 用于设置、储存、读取窗口缩放系数，以提供窗口缩放功能的类。
## 可根据不同的场景，分别设置窗口缩放系数，在打开场景时自动加载。
class_name 窗口缩放
extends Control

const 存档文件地址: String = "user://窗口缩放系数/"  ## 各场景窗口缩放系数的储存路径。

@export var 最大缩放倍数: float = 5.0 ## 设置最大缩放倍数。

@export var 最小缩放倍数: float = 0.1 ## 设置最小缩放倍数。

@export var 场景:String = "默认" ## 可导出变量场景，允许在编辑器中设置，用于定义不同场景的缩放系数。

@export var 当前缩放倍数: float ## 当前缩放倍数，get-only，对该值的设置无效。

@onready var _显示条: ProgressBar = $"HBoxContainer/VBoxContainer/VBoxContainer/显示条" # 获取ProgressBar节点，用于显示当前缩放比例。

var _显示动画: Tween # 声明变量以存储Tween动画，用于渐变效果。

var _原始窗口维度 = Vector2i( # 存储项目设置中定义的原始窗口尺寸。
	ProjectSettings.get_setting("display/window/size/viewport_width",2048),
	ProjectSettings.get_setting("display/window/size/viewport_height",1024))


func _ready() -> void:
	# 将当前节点的颜色设置为透明。
	$".".modulate = Color.TRANSPARENT
	# 如果当前窗口缩放系数不是1.0，则根据存储的缩放系数调整窗口大小。
	if _获取窗口缩放系数() != 1.0:
		get_window().content_scale_size = _原始窗口维度*( 0.9 * _获取窗口缩放系数())


func _input(event: InputEvent) -> void:
	# 如果不是放大或缩小的动作，则不进行任何操作。
	if not (event.is_action_pressed("UI放大") or event.is_action_pressed("UI缩小")):
		return

	# 如果显示动画存在并且已运行超过0.2秒，则暂停动画并将节点颜色设置为白色。
	if (_显示动画 != null) and _显示动画.get_total_elapsed_time() > 0.2:
		_显示动画.pause()
		$".".modulate = Color.WHITE
		# 创建一个新的Tween动画，在2秒后继续播放显示动画。
		$".".create_tween().tween_callback(func():
			if _显示动画 != null and not _显示动画.is_running() and _显示动画.is_valid():
				_显示动画.play()).set_delay(2.0)

	# 如果没有正在运行的显示动画，则创建并配置一个新的Tween动画。
	if (_显示动画 == null) or (not _显示动画.is_running()):
		_显示动画 = $".".create_tween()
		
		# 配置Tween动画，从透明变为白色，持续0.2秒。
		_显示动画.tween_property($".","modulate",Color.WHITE,0.2)
		# 设置Tween动画间隔为3.0秒。
		_显示动画.tween_interval(3.0)
		# 配置Tween动画，从白色变回透明，持续0.5秒。
		_显示动画.tween_property($".","modulate",Color.TRANSPARENT,0.5)

	# 如果触发了放大动作。
	if event.is_action_pressed("UI放大"):
		# 获取当前窗口缩放系数。
		var 系数 = _获取窗口缩放系数()
		# 如果系数小于或等于最小值，则不进行操作。
		if 系数 <= 最小缩放倍数:
			_显示条.value = 系数
			return
		系数 -= 0.1 # 减小缩放系数。
		# 调整窗口内容的缩放大小。
		var 窗口 = get_window()
		窗口.content_scale_size = _原始窗口维度 * 系数
		# 保存新的缩放系数。
		_设置窗口缩放系数(系数)
		# 更新ProgressBar的值。
		_显示条.value = 系数
		# 更新检查窗口系数显示
		当前缩放倍数 = 系数

	# 如果触发了缩小动作。
	if event.is_action_pressed("UI缩小"):
		# 获取当前窗口缩放系数。
		var 系数 = _获取窗口缩放系数()
		# 如果系数大于或等于最大值，则不进行操作。
		if 系数 >= 最大缩放倍数:
			_显示条.value = 系数
			return
		# 增加缩放系数。
		系数 += 0.1
		# 调整窗口内容的缩放大小。
		var 窗口 = get_window()
		窗口.content_scale_size = _原始窗口维度 * 系数
		# 保存新的缩放系数。
		_设置窗口缩放系数(系数)
		# 更新ProgressBar的值。
		_显示条.value = 系数
		# 更新检查窗口系数显示
		当前缩放倍数 = 系数


# 获取窗口缩放系数的函数。
func _获取窗口缩放系数() -> float:
	# 如果存档文件夹不存在，则创建它。
	if not DirAccess.dir_exists_absolute(存档文件地址):
		DirAccess.make_dir_recursive_absolute(存档文件地址)

	# 如果缩放系数文件不存在，创建文件并写入默认值1.0。
	if not FileAccess.file_exists(存档文件地址 + "%s缩放系数.gxieja" % 场景):
		FileAccess.open(存档文件地址 + "%s缩放系数.gxieja" % 场景,FileAccess.WRITE).store_float(1.0)
		return 1.0

	# 读取并返回存储的缩放系数。
	return FileAccess.open(存档文件地址 + "%s缩放系数.gxieja" % 场景,FileAccess.READ).get_float()


# 设置窗口缩放系数的函数。
func _设置窗口缩放系数(系数: float) -> void:
	# 打开缩放系数文件，并写入新的缩放系数。
	FileAccess.open(存档文件地址 + "%s缩放系数.gxieja" % 场景,FileAccess.WRITE).store_float(系数)

