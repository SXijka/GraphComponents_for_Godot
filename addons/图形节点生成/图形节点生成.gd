@tool
extends EditorPlugin

var 插件面板: Control

const _节点: = preload("res://addons/图形节点生成/组件/节点/节点.tscn")
const _人物节点 = preload("res://addons/图形节点生成/组件/人物节点/人物节点.tscn")
const _接口 = preload("res://addons/图形节点生成/组件/接口/接口.tscn")
const _节点盘 = preload("res://addons/图形节点生成/组件/节点盘/节点盘.tscn")
const _窗口缩放 = preload("res://addons/图形节点生成/组件/窗口缩放/窗口缩放.tscn")
const _区域 = preload("res://addons/图形节点生成/组件/区域/区域.tscn")
const _文本节点 = preload("res://addons/图形节点生成/组件/文本节点/文本节点.tscn")
const _可调整边框 = preload("res://addons/图形节点生成/组件/可调整边框/可调整边框.tscn")
const _点背景 = preload("res://addons/图形节点生成/组件/点背景/点背景.tscn")


func _enter_tree() -> void:
	加入插件面板功能()


func _exit_tree() -> void:
	remove_control_from_docks(插件面板)
	插件面板.free()


func 加入插件面板功能():
	插件面板 = preload("res://addons/图形节点生成/图形化节点.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, 插件面板)

	插件面板.find_child("节点").pressed.connect(func(): 生成(_节点))
	插件面板.find_child("人物节点").pressed.connect(func(): 生成(_人物节点))
	插件面板.find_child("接口").pressed.connect(func(): 生成(_接口))
	插件面板.find_child("节点盘").pressed.connect(func(): 生成(_节点盘))
	插件面板.find_child("窗口缩放").pressed.connect(func(): 生成(_窗口缩放))
	插件面板.find_child("区域").pressed.connect(func(): 生成(_区域))
	插件面板.find_child("文本节点").pressed.connect(func(): 生成(_文本节点))
	插件面板.find_child("可调整边框").pressed.connect(func(): 生成(_可调整边框))
	插件面板.find_child("点背景").pressed.connect(func(): 生成(_点背景))


func 生成(场景:PackedScene) -> void:
	var 场景根节点 := get_editor_interface().get_edited_scene_root()
	var 实例 = 场景.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	场景根节点.add_child(实例, true)
	实例.owner = 场景根节点

