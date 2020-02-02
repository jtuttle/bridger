extends Node

const _level_path = "res://objects/levels/"
const _level_prefix = "level_"
var _level_num = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_level_num(new_num : int):
	_level_num = new_num


func get_level_num():
	return _level_num


func get_level_name():
	return str(_level_prefix, str(_level_num))


func get_level_path():
	return str(_level_path, _level_prefix, str(_level_num))


func get_game():
	return get_node("/root/game")
