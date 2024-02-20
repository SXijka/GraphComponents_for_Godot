extends Control
class_name 文本节点

@export var 自动展现: bool = true
@export var 展开大小: Vector2 = Vector2(300, 100)
@export var 隐藏大小: Vector2 = Vector2(100, 30)

@export_range(1.0, 10.0, 0.1) var 展开时间: float = 3
@export var 内容: String = "……"
@export var 名称: String = "文本"
@export var 颜色: Color = Color.ROYAL_BLUE
@export_file("*.txt") var 内容文件: String

@onready var 节点本体: 节点 = $"节点"
@onready var 文本框: ScrollContainer = 节点本体.获取_内容()[0]
@onready var 文本: RichTextLabel = 节点本体.获取_内容()[0].get_child(0)


func _ready() -> void:
	节点本体.名称 = 名称
	节点本体.标记颜色 = 颜色
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
	节点本体.节点大小 = 隐藏大小

	var 展开动画 = 文本.create_tween()
	展开动画.set_trans(Tween.TRANS_CUBIC)
	展开动画.tween_property(节点本体, "节点大小",Vector2(展开大小.x, 节点本体.size.y) ,展开时间/3)
	展开动画.tween_property(节点本体, "节点大小", 展开大小, 展开时间 * 2 / 3)
	展开动画.parallel().tween_property(文本, "visible_ratio", 1.0, 展开时间 * 2 / 3)

