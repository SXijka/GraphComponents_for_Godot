class_name 书节点
extends 文本节点
## 代表书信等可展开或关闭的用于阅读的[节点]。是[文本节点]的扩展形式，面板底部拥有一个“使用”接口，[br]
## 在不指定接口配置文件时，连接至“使用”接口会使其展开，所有连接断开后会关闭。

@export_file("*.gd") var 接口配置: String ## 面板内[color=orange]“使用”接口[/color]的[连接配置]文件。
@export var 接口自动连接至: Array[接口] = [] ## 对[color=orange]使用[接口][/color]的

@export var 关闭时间: float = 1.0
@export var 当前页数: int = 0

@onready var _使用接口: 接口 = $"可调整边框/节点内容/面板背景/面板容器/面板/使用"
@onready var _上一页接口: 接口 = $"可调整边框/节点内容/面板背景/面板容器/面板/上一页"
@onready var _下一页接口: 接口 = $"可调整边框/节点内容/面板背景/面板容器/面板/下一页"


signal 已关闭


func _ready() -> void:
	super._ready()
	


## 节点的关闭方式：会根据[param 展开时间]播放一个动画，徐徐展开文本节点至[param 展开大小]。
func 关闭():
	节点大小 = 隐藏大小

	var 关闭动画 = 文本.create_tween()
	关闭动画.set_trans(Tween.TRANS_CUBIC)
	关闭动画.tween_property(self, "节点大小", Vector2(size.x, 隐藏大小.y), 关闭时间 * 2 / 3)
	关闭动画.parallel().tween_property(文本, "visible_ratio", 0, 关闭时间 * 2 / 3)
	关闭动画.tween_property(self, "节点大小", 隐藏大小, 关闭时间/3)
