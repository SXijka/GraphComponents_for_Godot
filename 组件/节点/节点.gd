@tool
class_name 节点
extends Control


@export var 名称: String = "节点":
	set = _设置名称

@export_color_no_alpha var 标记颜色: Color = Color.ROYAL_BLUE:
	set = _设置标记颜色

@export var 背景颜色: Color = Color(0.15, 0.15, 0.15, 1.0):
	set = _设置背景颜色

@export var 背景点颜色: Color = Color(0.2, 0.2, 0.2, 1.0):
	set = _设置背景点颜色

@export_enum("点","叉","十","一") var 背景点图案: String = "十":
	set = _设置背景点图案

@export var 展开: bool = true

@onready var 节点名称: Label = $"可调整边框/节点内容/标题栏背景/标题栏边距/左右布局/节点名称"
@onready var 底部背景: Panel = $"可调整边框/节点内容/面板背景/面板容器/底部背景"
@onready var 标题栏背景: PanelContainer = $"可调整边框/节点内容/标题栏背景"
@onready var 面板背景: PanelContainer = $"可调整边框/节点内容/面板背景"
@onready var 背景点: 点背景 = $"可调整边框/节点内容/面板背景/背景容器/点背景"




func _init() -> void:
	add_to_group("节点")


func _ready() -> void:
	_设置名称(名称)
	_设置标记颜色(标记颜色)
	_设置背景颜色(背景颜色)
	_设置背景点图案(背景点图案)
	_设置背景点颜色(背景点颜色)


func _设置名称(新名称):
	名称 = 新名称
	if not 节点名称:
		return
	节点名称.text = 新名称


func _设置标记颜色(新颜色: Color):
	标记颜色 = 新颜色
	if not 标题栏背景:
		return
	if not 底部背景:
		return
	标题栏背景.self_modulate = 新颜色
	底部背景.modulate = 新颜色


func _设置背景颜色(新颜色: Color):
	背景颜色 = 新颜色
	if not 面板背景:
		return
	面板背景.self_modulate = 新颜色

func _设置背景点颜色(新颜色: Color):
	背景点颜色 = 新颜色
	if not 背景点:
		return
	(背景点 as 点背景).点颜色 = 新颜色

func _设置背景点图案(新图案: String):
	背景点图案 = 新图案
	if not 背景点:
		print("na")
		return
	背景点.图案 = 新图案
