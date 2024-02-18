extends Control

func _ready() -> void:
	var i := 点背景.new()
	var s := 可调整边框.new()
	add_child(i)
	add_child(s)
	s.连接到( i ,true)
	i.size = Vector2(200,200)

func a (k: Control):
	print(k)
