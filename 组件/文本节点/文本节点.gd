@tool
class_name 文本节点
extends 节点

@export var 自动展现: bool = true
@export var 展开大小: Vector2 = Vector2(300, 100)
@export var 隐藏大小: Vector2 = Vector2(100, 30)

@export_range(1.0, 10.0, 0.1) var 展开时间: float = 3
@export var 内容: String = "……"
@export_file("*.txt") var 内容文件: String


@onready var 文本框: ScrollContainer = $"可调整边框/节点内容/面板背景/面板容器/面板/滚动框"
@onready var 文本: RichTextLabel = $"可调整边框/节点内容/面板背景/面板容器/面板/滚动框/富文本"


func _init() -> void:
	super._init()
	add_to_group("文本节点")


func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	if 内容文件:
		文本.text = FileAccess.open(内容文件, FileAccess.READ).get_as_text()
	else:
		文本.text = 内容
	隐藏()
	if 自动展现:
		展现()


func 隐藏():
	hide()
	文本.visible_ratio = 0


func 展现():
	show()
	节点大小 = 隐藏大小

	var 展开动画 = 文本.create_tween()
	展开动画.set_trans(Tween.TRANS_CUBIC)
	展开动画.tween_property(self, "节点大小",Vector2(展开大小.x, size.y) ,展开时间/3)
	展开动画.tween_property(self, "节点大小", 展开大小, 展开时间 * 2 / 3)
	展开动画.parallel().tween_property(文本, "visible_ratio", 1.0, 展开时间 * 2 / 3)
